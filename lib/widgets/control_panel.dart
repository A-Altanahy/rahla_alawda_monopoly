import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/game_service.dart';
import '../services/image_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        return Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.purple.shade50,
                Colors.pink.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.control_camera, color: Colors.blue.shade600, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'لوحة التحكم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${gameService.teams.length} فرق',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Teams grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: gameService.teams.length,
                    itemBuilder: (context, index) {
                      final team = gameService.teams[index];
                      return _buildTeamQuickCard(context, team);
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.refresh,
                        label: 'إعادة تعيين',
                        color: Colors.orange,
                        onTap: () => _showResetConfirmation(context, gameService),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        icon: Icons.camera_alt,
                        label: 'إدارة الصور',
                        color: Colors.blue,
                        onTap: () => _showImageManagementPanel(context, gameService),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء بطاقة فريق سريعة
  Widget _buildTeamQuickCard(BuildContext context, Team team) {
    return GestureDetector(
      onTap: () => _showQuickTeamActions(context, team),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: team.color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Team image/icon
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: team.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: team.imagePath != null
                    ? Image.file(
                        File(team.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Team name (abbreviated)
            Text(
              team.name.split(' ').last, // Show last word of team name
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Position indicator
            Text(
              'الموقع ${team.position}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
              ),
            ),
            
            // Custom image indicator
            if (team.imagePath != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'صورة',
                  style: TextStyle(
                    fontSize: 6,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// بناء زر إجراء سريع
  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// عرض إجراءات الفريق السريعة
  void _showQuickTeamActions(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Team image preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: team.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: team.imagePath != null
                    ? Image.file(
                        File(team.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text('الموقع الحالي: ${team.position}'),
            
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showImageSelectionForTeam(context, team);
            },
            child: const Text('تغيير الصورة'),
          ),
        ],
      ),
    );
  }

  /// اختيار صورة للفريق من اللوحة
  void _showImageSelectionForTeam(BuildContext context, Team team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختيار صورة لـ ${team.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Camera option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Colors.green.shade700),
              ),
              title: const Text('الكاميرا'),
              subtitle: const Text('التقط صورة جديدة'),
              onTap: () {
                Navigator.pop(context);
                _handleQuickImageSelection(context, team, ImageSource.camera);
              },
            ),
            
            // Gallery option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: Colors.blue.shade700),
              ),
              title: const Text('المعرض'),
              subtitle: const Text('اختر من الصور المحفوظة'),
              onTap: () {
                Navigator.pop(context);
                _handleQuickImageSelection(context, team, ImageSource.gallery);
              },
            ),
            
            // Remove option (only if image exists)
            if (team.imagePath != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete, color: Colors.red.shade700),
                ),
                title: const Text('حذف الصورة'),
                subtitle: const Text('العودة للأيقونة الافتراضية'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageRemoval(context, team);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// معالجة اختيار الصورة السريع
  Future<void> _handleQuickImageSelection(BuildContext context, Team team, ImageSource source) async {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('جاري معالجة الصورة...')),
          ],
        ),
      ),
    );
    
    try {
      final result = await ImageService.pickAndSaveTeamImage(source, team.id);
      
      // إخفاء مؤشر التحميل
      Navigator.pop(context);
      
      if (result.isSuccess && result.imagePath != null) {
        // تحديث صورة الفريق
        final gameService = Provider.of<GameService>(context, listen: false);
        await gameService.updateTeamImageWithCleanup(team.id, result.imagePath);
        
        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الصورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        
      } else if (!result.isCancelled) {
        // عرض رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'حدث خطأ غير متوقع'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      // إخفاء مؤشر التحميل
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء معالجة الصورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// معالجة حذف الصورة
  Future<void> _handleImageRemoval(BuildContext context, Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف الصورة الحالية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final gameService = Provider.of<GameService>(context, listen: false);
        await ImageService.deleteTeamImage(team.id);
        await gameService.updateTeamImageWithCleanup(team.id, null);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الصورة بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء حذف الصورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// عرض تأكيد إعادة التعيين
  void _showResetConfirmation(BuildContext context, GameService gameService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين اللعبة'),
        content: const Text('هل تريد إعادة تعيين مواقع جميع الفرق إلى البداية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameService.resetGame();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين اللعبة'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  /// عرض لوحة إدارة الصور
  void _showImageManagementPanel(BuildContext context, GameService gameService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة صور الفرق'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: gameService.teams.length,
            itemBuilder: (context, index) {
              final team = gameService.teams[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: team.color,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: team.imagePath != null
                        ? Image.file(
                            File(team.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, color: Colors.white, size: 20);
                            },
                          )
                        : Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
                title: Text(team.name),
                subtitle: Text(team.imagePath != null ? 'صورة مخصصة' : 'صورة افتراضية'),
                trailing: team.imagePath != null
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _handleImageRemoval(context, team),
                      )
                    : IconButton(
                        icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                        onPressed: () => _showImageSelectionForTeam(context, team),
                      ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
} 