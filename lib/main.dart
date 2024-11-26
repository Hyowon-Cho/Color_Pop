import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(home: ColorPopGame()));
}

class ColorPopGame extends StatefulWidget {
  const ColorPopGame({Key? key}) : super(key: key);

  @override
  State<ColorPopGame> createState() => _ColorPopGameState();
}

class _ColorPopGameState extends State<ColorPopGame> {
  static const int rows = 8;
  static const int cols = 8;
  late List<List<Color>> board;
  int score = 0;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    final random = Random();
    board = List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => colors[random.nextInt(colors.length)],
      ),
    );
  }

  bool isValidPosition(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  List<List<int>> findConnectedBlocks(int row, int col, Color color) {
    List<List<int>> connected = [];
    Set<String> visited = {};

    void dfs(int r, int c) {
      if (!isValidPosition(r, c) ||
          visited.contains('$r,$c') ||
          board[r][c] != color) {
        return;
      }

      visited.add('$r,$c');
      connected.add([r, c]);

      // Check all 4 directions
      dfs(r - 1, c); // up
      dfs(r + 1, c); // down
      dfs(r, c - 1); // left
      dfs(r, c + 1); // right
    }

    dfs(row, col);
    return connected;
  }

  void popBlocks(List<List<int>> blocks) {
    if (blocks.length < 2) return; // Need at least 2 connected blocks

    setState(() {
      // Remove blocks
      for (var block in blocks) {
        int row = block[0];
        int col = block[1];
        board[row][col] = Colors.transparent;
      }

      // Update score
      score += blocks.length * 10;

      // Make blocks fall
      for (int col = 0; col < cols; col++) {
        List<Color> column = [];
        for (int row = rows - 1; row >= 0; row--) {
          if (board[row][col] != Colors.transparent) {
            column.add(board[row][col]);
          }
        }
        while (column.length < rows) {
          column.add(colors[Random().nextInt(colors.length)]);
        }
        for (int row = 0; row < rows; row++) {
          board[row][col] = column[rows - 1 - row];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Pop Game - Score: $score'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < rows; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < cols; j++)
                    GestureDetector(
                      onTap: () {
                        var blocks = findConnectedBlocks(i, j, board[i][j]);
                        popBlocks(blocks);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: board[i][j],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  score = 0;
                  initializeBoard();
                });
              },
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}