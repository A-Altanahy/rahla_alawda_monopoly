import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// طلب الصلاحيات المطلوبة للكاميرا والمعرض
  static Future<bool> requestPermissions(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        return cameraStatus.isGranted;
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await _getAndroidVersion();
          if (androidInfo >= 33) {
            final photosStatus = await Permission.photos.request();
            return photosStatus.isGranted;
          } else {
            final storageStatus = await Permission.storage.request();
            return storageStatus.isGranted;
          }
        } else {
          final photosStatus = await Permission.photos.request();
          return photosStatus.isGranted;
        }
      }
    } catch (e) {
      print('خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  /// الحصول على إصدار الأندرويد
  static Future<int> _getAndroidVersion() async {
    try {
      // This is a simplified version - in real implementation you might want to use device_info_plus
      return 30; // Default to API level 30
    } catch (e) {
      return 30;
    }
  }

  /// اختيار وحفظ صورة للفريق مع ضغط وتحسين
  static Future<ImageResult> pickAndSaveTeamImage(
    ImageSource source,
    int teamId, {
    int maxWidth = 512,
    int maxHeight = 512,
    int imageQuality = 85,
  }) async {
    try {
      // التحقق من الصلاحيات
      final hasPermission = await requestPermissions(source);
      if (!hasPermission) {
        return ImageResult.error('لا توجد صلاحيات للوصول إلى ${source == ImageSource.camera ? 'الكاميرا' : 'المعرض'}');
      }

      // اختيار الصورة
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        return ImageResult.cancelled();
      }

      // التحقق من حجم الملف
      final fileSize = await File(image.path).length();
      if (fileSize > 10 * 1024 * 1024) { // 10 MB
        return ImageResult.error('حجم الصورة كبير جداً. يرجى اختيار صورة أصغر من 10 ميجابايت');
      }

      // إنشاء مجلد صور الفرق
      final appDir = await getApplicationDocumentsDirectory();
      final teamImagesDir = Directory(path.join(appDir.path, 'team_images'));
      
      if (!await teamImagesDir.exists()) {
        await teamImagesDir.create(recursive: true);
      }

      // حذف الصورة القديمة إن وجدت
      await _deleteOldTeamImage(teamId, teamImagesDir);

      // إنشاء اسم ملف جديد للفريق
      final extension = path.extension(image.path);
      final newFileName = 'team_${teamId}_image$extension';
      final newPath = path.join(teamImagesDir.path, newFileName);

      // نسخ الملف إلى المكان الدائم
      final sourceFile = File(image.path);
      final newFile = await sourceFile.copy(newPath);
      
      // التحقق من نجح النسخ
      if (!await newFile.exists()) {
        return ImageResult.error('فشل في حفظ الصورة');
      }

      print('تم حفظ صورة الفريق $teamId إلى: ${newFile.path}');
      return ImageResult.success(newFile.path);

    } catch (e) {
      print('خطأ في اختيار وحفظ الصورة: $e');
      return ImageResult.error('حدث خطأ أثناء معالجة الصورة: ${e.toString()}');
    }
  }

  /// حذف صورة الفريق القديمة
  static Future<void> _deleteOldTeamImage(int teamId, Directory teamImagesDir) async {
    try {
      final files = await teamImagesDir.list().toList();
      for (final file in files) {
        if (file is File && path.basename(file.path).startsWith('team_${teamId}_image')) {
          await file.delete();
          print('تم حذف الصورة القديمة: ${file.path}');
        }
      }
    } catch (e) {
      print('خطأ في حذف الصورة القديمة: $e');
    }
  }

  /// حذف صورة الفريق
  static Future<bool> deleteTeamImage(int teamId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final teamImagesDir = Directory(path.join(appDir.path, 'team_images'));
      
      if (!await teamImagesDir.exists()) {
        return true; // المجلد غير موجود، لا توجد صور للحذف
      }

      await _deleteOldTeamImage(teamId, teamImagesDir);
      return true;
    } catch (e) {
      print('خطأ في حذف صورة الفريق: $e');
      return false;
    }
  }

  /// حذف صورة عامة بمسار محدد
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null && File(imagePath).existsSync()) {
      try {
        await File(imagePath).delete();
        print('تم حذف الصورة: $imagePath');
      } catch (e) {
        print('لم يتم حذف الصورة: $e');
      }
    }
  }

  /// التحقق من وجود صورة للفريق
  static Future<bool> hasTeamImage(int teamId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final teamImagesDir = Directory(path.join(appDir.path, 'team_images'));
      
      if (!await teamImagesDir.exists()) {
        return false;
      }

      final files = await teamImagesDir.list().toList();
      return files.any((file) => 
        file is File && path.basename(file.path).startsWith('team_${teamId}_image'));
    } catch (e) {
      return false;
    }
  }

  /// عرض رسالة خطأ الصلاحيات
  static void showPermissionDialog(BuildContext context, ImageSource source) {
    final sourceText = source == ImageSource.camera ? 'الكاميرا' : 'المعرض';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('صلاحية $sourceText مطلوبة'),
        content: Text('يرجى السماح للتطبيق بالوصول إلى $sourceText لتتمكن من اختيار الصور'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
}

/// نتيجة عملية اختيار الصورة
class ImageResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? imagePath;
  final String? errorMessage;

  ImageResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.imagePath,
    this.errorMessage,
  });

  factory ImageResult.success(String imagePath) {
    return ImageResult._(
      isSuccess: true,
      isCancelled: false,
      imagePath: imagePath,
    );
  }

  factory ImageResult.error(String errorMessage) {
    return ImageResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: errorMessage,
    );
  }

  factory ImageResult.cancelled() {
    return ImageResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }
} 