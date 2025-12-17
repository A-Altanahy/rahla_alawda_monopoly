import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'services/game_service.dart';
import 'services/image_service.dart';
import 'widgets/board_widget.dart';
import 'widgets/load_game_screen.dart';
import 'widgets/close_confirmation_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop platforms
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رحلة العودة - مونوبولي',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        fontFamily: 'Arial', // Better Arabic support
      ),
      home: ChangeNotifierProvider(
        create: (context) => GameService(),
        child: const AppRoot(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WindowListener {
  bool _showLoadScreen = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkForSavedGames();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkForSavedGames() async {
    final hasSaves = await GameService.hasSavedGames();
    setState(() {
      _showLoadScreen = hasSaves;
      _isLoading = false;
    });
  }

  @override
  Future<void> onWindowClose() async {
    if (!mounted) return;
    
    final shouldClose = await handleCloseAction(context);
    if (shouldClose) {
      await windowManager.destroy();
    }
  }

  void _startNewGame() {
    setState(() {
      _showLoadScreen = false;
    });
  }

  Future<void> _loadGame(String saveId) async {
    final gameService = Provider.of<GameService>(context, listen: false);
    final success = await gameService.loadGame(saveId);
    
    if (success) {
      setState(() {
        _showLoadScreen = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحميل اللعبة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showLoadScreen) {
      return LoadGameScreen(
        onNewGame: _startNewGame,
        onLoadGame: _loadGame,
      );
    }

    return const GameScreen();
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade100,
                  Colors.orange.shade100,
                  Colors.red.shade50,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: const BoardWidget(),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                onPressed: () => _showChangeBoardDialog(gameService),
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('تغيير اللوحة', style: TextStyle(color: Colors.white)),
                heroTag: "changeBoardButton",
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                onPressed: () => _showSaveDialog(gameService),
                backgroundColor: Colors.green,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('حفظ', style: TextStyle(color: Colors.white)),
                heroTag: "saveButton",
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSaveDialog(GameService gameService) async {
    final TextEditingController nameController = TextEditingController();
    final now = DateTime.now();
    nameController.text = "لعبة ${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save, color: Colors.green),
            SizedBox(width: 8),
            Text('حفظ اللعبة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أدخل اسماً لحفظ اللعبة الحالية:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم اللعبة المحفوظة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.gamepad),
              ),
              maxLength: 50,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await gameService.saveGame(name);
                  Navigator.of(dialogContext).pop(true);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ اللعبة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('فشل في حفظ اللعبة: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChangeBoardDialog(GameService gameService) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.image, color: Colors.blue),
            SizedBox(width: 8),
            Text('تغيير اللوحة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر صورة جديدة للوحة اللعبة:'),
            const SizedBox(height: 16),
            if (gameService.hasCustomBoardImage)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('يوجد لوحة مخصصة حالياً', 
                         style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            if (gameService.hasCustomBoardImage) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBoardImageSelection(
                      dialogContext, gameService, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('من المعرض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBoardImageSelection(
                      dialogContext, gameService, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('من الكاميرا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (gameService.hasCustomBoardImage) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _resetBoardImage(dialogContext, gameService),
                  icon: const Icon(Icons.restore),
                  label: const Text('استعادة اللوحة الافتراضية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBoardImageSelection(
    BuildContext dialogContext, 
    GameService gameService, 
    ImageSource source
  ) async {
    Navigator.of(dialogContext).pop(); // Close dialog first
    
    // Show loading dialog
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
             final result = await ImageService.pickAndSaveBoardImage(source);
      
      // Hide loading dialog
      Navigator.pop(context);
      
      if (result.isSuccess && result.imagePath != null) {
        await gameService.updateBoardImage(result.imagePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تغيير اللوحة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
      } else if (!result.isCancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'حدث خطأ غير متوقع'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
    } catch (e) {
      // Hide loading dialog
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء معالجة الصورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetBoardImage(BuildContext dialogContext, GameService gameService) async {
    Navigator.of(dialogContext).pop(); // Close dialog first
    
    final success = await gameService.resetBoardImage();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'تم استعادة اللوحة الافتراضية'
            : 'فشل في استعادة اللوحة الافتراضية'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

}
