import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/game_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, gameService, child) {
        final squares = gameService.boardSquares;

        if (squares.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSize = constraints.maxWidth;

                    return Stack(
                      children: [
                        // Board background image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: gameService.hasCustomBoardImage
                              ? Image.file(
                                  File(gameService.customBoardImagePath!),
                                  width: boardSize,
                                  height: boardSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fall back to default asset if custom image fails
                                    return Image.asset(
                                      'assets/images/board.jpg',
                                      width: boardSize,
                                      height: boardSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: boardSize,
                                          height: boardSize,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Text(
                                              'Board image not found\nPlease ensure board.jpg is in assets/images/',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/board.jpg',
                                  width: boardSize,
                                  height: boardSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: boardSize,
                                      height: boardSize,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Text(
                                          'Board image not found\nPlease ensure board.jpg is in assets/images/',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Team circles overlay
                        ..._buildAllTeamCircles(
                          context,
                          gameService,
                          boardSize,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAllTeamCircles(
    BuildContext context,
    GameService gameService,
    double boardSize,
  ) {
    final teams = gameService.teams;
    List<Widget> teamWidgets = [];

    // Group teams by position
    Map<int, List<Team>> teamsByPosition = {};
    for (var team in teams) {
      if (!teamsByPosition.containsKey(team.position)) {
        teamsByPosition[team.position] = [];
      }
      teamsByPosition[team.position]!.add(team);
    }

    // Create team widgets for each position
    for (var entry in teamsByPosition.entries) {
      final position = entry.key;
      final teamsAtPosition = entry.value;

      teamWidgets.add(
        _buildTeamCirclesOnSquare(
          context,
          position,
          teamsAtPosition,
          boardSize,
          gameService,
        ),
      );
    }

    return teamWidgets;
  }

  Widget _buildTeamCirclesOnSquare(
    BuildContext context,
    int position,
    List<Team> teams,
    double boardSize,
    GameService gameService,
  ) {
    final squarePosition = _getSquarePositionOnImage(position, boardSize);
    final teamCircleSize = boardSize * 0.045; // Bigger circles for better visibility

    // Add offsets for specific rows to improve circle positioning
    double topOffset = squarePosition.dy - (teamCircleSize * 1.5);
    double leftOffset = squarePosition.dx - (teamCircleSize * 1.5);
    
    if (position >= 21 && position <= 29) {
      // Top row: move down and slightly right
      topOffset += teamCircleSize * 1.0; // Move circles down by 100% of circle size
      leftOffset += teamCircleSize * 0.12; // Move circles right by 12% of circle size
    } else if (position >= 11 && position <= 19) {
      // Left side: move slightly right
      leftOffset += teamCircleSize * 0.3; // Move circles right by 12% of circle size
    } else if (position >= 1 && position <= 9) {
      // Left side: move slightly right
      leftOffset += teamCircleSize * 0.1; // Move circles right by 12% of circle size
    }

    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: SizedBox(
        width: teamCircleSize * 3,
        height: teamCircleSize * 3,
        child: Stack(
          children: teams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;

            // Calculate circular position around the center
            final offset = _getTeamCircularOffset(
              index,
              teams.length,
              teamCircleSize,
            );

            return Positioned(
              left: (teamCircleSize * 1.5) + offset.dx - (teamCircleSize / 2),
              top: (teamCircleSize * 1.5) + offset.dy - (teamCircleSize / 2),
              child: GestureDetector(
                onTap: () => _showEnhancedTeamMenu(context, team),
                child: Container(
                  width: teamCircleSize,
                  height: teamCircleSize,
                  decoration: BoxDecoration(
                    color: team.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: team.imagePath != null ? Colors.white : Colors.transparent, 
                      width: 2
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Team image or icon
                      team.imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(team.imagePath!),
                                fit: BoxFit.cover,
                                width: teamCircleSize,
                                height: teamCircleSize,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: teamCircleSize * 0.6,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: teamCircleSize * 0.6,
                            ),
                      
                      // Custom image indicator
                      if (team.imagePath != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: teamCircleSize * 0.3,
                            height: teamCircleSize * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              color: Colors.white,
                              size: teamCircleSize * 0.15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Offset _getTeamCircularOffset(
    int teamIndex,
    int totalTeams,
    double circleSize,
  ) {
    if (totalTeams == 1) {
      return Offset.zero;
    }

    final angle = (teamIndex * 2 * pi) / totalTeams;

    double radius;
    if (totalTeams == 2) {
      radius = circleSize * 0.3;
    } else if (totalTeams <= 4) {
      radius = circleSize * 0.5;
    } else {
      radius = circleSize * 0.7;
    }

    return Offset(radius * cos(angle), radius * sin(angle));
  }

  // Map square positions to coordinates on the board image
  Offset _getSquarePositionOnImage(int index, double boardSize) {
    final squareWidth = boardSize / (9 + 1.73 + 1.73);
    final cornerSize = squareWidth * 1.73;

    if (index <= 10) {
      if (index == 0) {
        return Offset(
          boardSize - (cornerSize / 2),
          boardSize - (cornerSize / 2),
        );
      } else if (index == 10) {
        return Offset(cornerSize / 2, boardSize - (cornerSize / 2));
      } else {
        return Offset(
          boardSize -
              cornerSize -
              ((index - 1) * squareWidth) -
              (squareWidth / 2),
          boardSize - (squareWidth / 2),
        );
      }
    } else if (index <= 20) {
      if (index == 20) {
        return Offset(cornerSize / 2, cornerSize / 2);
      } else {
        return Offset(
          squareWidth / 2,
          boardSize -
              cornerSize -
              ((index - 11) * squareWidth) -
              (squareWidth / 2),
        );
      }
    } else if (index <= 30) {
      if (index == 30) {
        return Offset(boardSize - (cornerSize / 2), cornerSize / 2);
      } else {
        return Offset(
          cornerSize + ((index - 21) * squareWidth) + (squareWidth / 2),
          squareWidth / 2,
        );
      }
    } else {
      return Offset(
        boardSize - (squareWidth / 2),
        cornerSize + ((index - 31) * squareWidth) + (squareWidth / 2),
      );
    }
  }

  /// عرض قائمة الفريق المبسطة
  void _showEnhancedTeamMenu(BuildContext context, Team team) {
    final gameService = Provider.of<GameService>(context, listen: false);
    final TextEditingController stepsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Team info with editable name
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Editable team name
                      GestureDetector(
                        onTap: () => _showEditNameDialog(context, team, gameService),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الموقع: ${team.position}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Team image moved to the right
                Container(
                  width: 60,
                  height: 60,
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
                              return const Icon(Icons.person, color: Colors.white, size: 30);
                            },
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
                         // Image buttons
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: () => _handleImageSelection(context, team, gameService, ImageSource.gallery),
                     icon: const Icon(Icons.photo_library),
                     label: const Text('المعرض'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: () => _handleImageSelection(context, team, gameService, ImageSource.gallery),
                     icon: const Icon(Icons.camera_alt),
                     label: const Text('الكاميرا (Gallery)'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
               ],
             ),
            
            if (team.imagePath != null) ...[
              const SizedBox(height: 12),
                               SizedBox(
                   width: double.infinity,
                   child: ElevatedButton.icon(
                     onPressed: () => _showRemoveImageConfirmation(context, team, gameService),
                     icon: const Icon(Icons.delete),
                     label: const Text('حذف الصورة'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.red,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
            ],
            
            const SizedBox(height: 24),
            
            // Movement controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stepsController,
                                         decoration: const InputDecoration(
                       labelText: 'عدد الخطوات',
                       border: OutlineInputBorder(),
                       hintText: 'رقم موجب للأمام، سالب للخلف',
                     ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final steps = int.tryParse(stepsController.text);
                    if (steps != null && steps != 0) {
                      gameService.moveTeam(team.id, steps);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: team.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  child: const Text('تحريك'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// عرض حوار تعديل اسم الفريق
  void _showEditNameDialog(BuildContext context, Team team, GameService gameService) {
    final TextEditingController nameController = TextEditingController(text: team.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل اسم الفريق'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفريق الجديد',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                gameService.updateTeamName(team.id, nameController.text.trim());
                Navigator.pop(context);
                Navigator.pop(context); // Close team panel to see updated name
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  /// معالجة اختيار الصورة
  Future<void> _handleImageSelection(BuildContext context, Team team, GameService gameService, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        gameService.updateTeamImage(team.id, image.path);
        Navigator.pop(context);
      }
      
    } catch (e) {
      print('خطأ في اختيار الصورة: $e');
    }
  }

  /// عرض تأكيد حذف الصورة
  void _showRemoveImageConfirmation(BuildContext context, Team team, GameService gameService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف الصورة الحالية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameService.updateTeamImage(team.id, null);
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض رسالة خطأ بسيطة
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
