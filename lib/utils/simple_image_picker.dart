import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/game_service.dart';
import '../models/team.dart';

class SimpleImagePicker {
  static Future<void> showImagePickerDialog(
    BuildContext context, 
    Team team, 
    GameService gameService
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(team.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current team image/icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: team.color,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: team.imagePath != null && File(team.imagePath!).existsSync()
                      ? Image.file(
                          File(team.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          team.icon,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text('اختر صورة للفريق'),
              const SizedBox(height: 8),
              if (team.imagePath != null)
                Text(
                  'يوجد صورة حالياً',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('اختر صورة'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _pickAndSetImage(context, team, gameService);
              },
            ),
            if (team.imagePath != null)
              TextButton(
                child: const Text('إزالة الصورة'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _removeImage(context, team, gameService);
                },
              ),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _pickAndSetImage(
    BuildContext context, 
    Team team, 
    GameService gameService
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Simply set the image path - let the original updateTeamImage handle the copying
        gameService.updateTeamImage(team.id, image.path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث صورة الفريق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> _removeImage(
    BuildContext context, 
    Team team, 
    GameService gameService
  ) async {
    try {
      gameService.updateTeamImage(team.id, null);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إزالة صورة الفريق'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('Error removing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إزالة الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 