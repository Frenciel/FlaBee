import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/barrier.dart';
import 'package:flutter_application_1/bee.dart';

// to do
// 1. fix barrier hit bug
//    done

// 2. add sound / music
//    api tried: soundpool, audioplayer, audiocache
//    Error: To set up CocoaPods for ARM macOS, run: arch -x86_64 sudo gem install ffi
//    already installed using brew

// 3. add different height of barrier
//     done!

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bee variables
  static double beeY = 0;
  double initialPos = beeY;
  double height = 0;
  double time = 0;
  double gravity = -0.045; // how strong the gravity is
  double velocity = 0.32; // how strong the jump is
  double beeWidth = 0.1; // out of 2 (2 is the phone size)
  double beeHeight = 0.1; // out of 2

  // game settings
  bool gameHasStarted = false;
  int score = 0;
  int highscore = 0;

  // barrier variables
  double moveSpeed = 0.005;
  static List<double> barrierX = [1.5, 3.0, 4.5, 6.0, 7.5];
  static double barrierWidth = 0.5; // out of 2
  List<List<double>> barrierHeight = [
    // out of 2 (entire height of screen)
    // [topHeight, bottomHeight]
    [0.6, 0.4],
    [0.4, 0.6],
    [0.5, 0.2],
    [0.2, 0.8],
    [0.7, 0.4],
  ];

  void initGame() {
    setState(() {
      // bee variables
      beeY = 0;
      initialPos = beeY;
      height = 0;
      time = 0;
      gravity = -0.045; // how strong the gravity is
      velocity = 0.35; // how strong the jump is
      beeWidth = 0.1;
      beeHeight = 0.1;

      // game settings
      gameHasStarted = false;
      score = 0;

      // barrier variables
      moveSpeed = 0.005;
      barrierX = [1.5, 3.0, 4.5, 6.0, 7.5];
      barrierWidth = 0.5; // out of 2
      barrierHeight = [
        // out of 2 (entire height of screen)
        // [topHeight, bottomHeight]
        [0.6, 0.4],
        [0.4, 0.6],
        [0.5, 0.2],
        [0.2, 0.8],
        [0.7, 0.4],
      ];
    });
  }

  void startGame() {
    gameHasStarted = true;

    Timer.periodic(Duration(milliseconds: 5), (timer) {
      // a real physical jump follows the arc of a parabola
      // according to a simple quadratic equation
      height = gravity * time * time + velocity * time;

      setState(() {
        beeY = initialPos - height;
      });

      // check if bee is dead
      if (beeIsDead()) {
        timer.cancel();
        _showDialog();
      }

      // move map (barriers)
      moveMap();

      // keep the time going
      time += 0.05;
    });
  }

  void moveMap() {
    if (score == 10 || score == 20 || score == 30) {
      setState(() {
        moveSpeed += 0.000005;
      });
    }
    for (int i = 0; i < barrierX.length; i++) {
      // move barriers
      setState(() {
        barrierX[i] -= moveSpeed;
      });

      // if barrier exit map, loop
      if (barrierX[i] < -1.5) {
        score += 1;
        // 5 for 5 types of barrier and 2.0 for if check above
        barrierX[i] += 5 * 1.5;
      }
    }
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = beeY;
    });
  }

  void resetGame() {
    setState(() {
      if (score > highscore) {
        highscore = score;
      }
    });

    initGame();
  }

  void _showDialog() {
    showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            // backgroundColor: Colors.brown,
            title: Center(
              child: Text(
                "G A M E  O V E R",
              ),
            ),
            content: Center(
              child: Text(
                "Score: " + score.toString(),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text("Play again"),
                  onPressed: () {
                    Navigator.of(context).pop(); //dismiss alert dialog
                    resetGame();
                  }),
              CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  }),
            ],
          );
        });
  }

  bool beeIsDead() {
    // check if bee hits top or bottom of screen
    if (beeY <= -1 || beeY + beeHeight >= 1) {
      return true;
    }

    // if bee hits barrier
    // check if bee is within x and y coordinates of barrier
    for (int i = 0; i < barrierX.length; i++) {
      // check x
      if (barrierX[i] <= beeWidth &&
          barrierX[i] + (barrierWidth) >= -beeWidth &&
          // check y
          // top barrier
          (beeY <= -1 + barrierHeight[i][0] ||
              // bottom barrier
              beeY + beeHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(children: [
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.blue.shade400,
              child: Center(
                child: Stack(
                  children: [
                    // the bee
                    MyBee(
                      beeY: beeY,
                      beeHeight: beeHeight,
                      beeWidth: beeWidth,
                    ),

                    // Top barrier 0
                    MyBarrier(
                      barrierX: barrierX[0],
                      barrierHeight: barrierHeight[0][0],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: false,
                    ),

                    // Bottom barrier 0
                    MyBarrier(
                      barrierX: barrierX[0],
                      barrierHeight: barrierHeight[0][1],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: true,
                    ),

                    // Top barrier 1
                    MyBarrier(
                      barrierX: barrierX[1],
                      barrierHeight: barrierHeight[1][0],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: false,
                    ),

                    // Bottom barrier 1
                    MyBarrier(
                      barrierX: barrierX[1],
                      barrierHeight: barrierHeight[1][1],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: true,
                    ),

                    // Top barrier 2
                    MyBarrier(
                      barrierX: barrierX[2],
                      barrierHeight: barrierHeight[2][0],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: false,
                    ),

                    // Bottom barrier 2
                    MyBarrier(
                      barrierX: barrierX[2],
                      barrierHeight: barrierHeight[2][1],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: true,
                    ),

                    // Top barrier 3
                    MyBarrier(
                      barrierX: barrierX[3],
                      barrierHeight: barrierHeight[3][0],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: false,
                    ),

                    // Bottom barrier 3
                    MyBarrier(
                      barrierX: barrierX[3],
                      barrierHeight: barrierHeight[3][1],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: true,
                    ),

                    // Top barrier 4
                    MyBarrier(
                      barrierX: barrierX[4],
                      barrierHeight: barrierHeight[4][0],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: false,
                    ),

                    // Bottom barrier 4
                    MyBarrier(
                      barrierX: barrierX[4],
                      barrierHeight: barrierHeight[4][1],
                      barrierWidth: barrierWidth,
                      isThisBottomBarrier: true,
                    ),

                    Container(
                      alignment: Alignment(0, -0.5),
                      child: Text(
                        gameHasStarted ? '' : 'T A P   T O   P L A Y',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 15,
            color: Colors.green,
          ),
          Expanded(
            child: Container(
              color: Colors.brown.shade600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "S C O R E",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Text(
                        score.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "B E S T",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Text(
                        highscore.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
