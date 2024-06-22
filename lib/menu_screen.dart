import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:time_to_score/game/components/Player.dart';
import 'package:time_to_score/game/game%20file/football_evade.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundOn = true;
  bool isSoundOn2 = true;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await audioPlayer.play(AssetSource('background.wav'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
      if (isSoundOn) {
        _playBackgroundMusic();
      } else {
        audioPlayer.stop();
      }
    });
  }

  void _toggleSound2() {
    setState(() {
      if (isSoundOn2) {
        print('sound on');
      } else {
        print('sound off');
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  AudioPlayer audioPlayer2 = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_menu.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleSound,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 60.0,
                        height: 60.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/button1.png',
                            ),
                            Icon(
                              isSoundOn ? Icons.music_note : Icons.music_off,
                              color: Colors.black,
                              size: 25.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSoundOn2 = !isSoundOn2;
                        });
                        _toggleSound2();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 60.0,
                        height: 60.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/button1.png',
                            ),
                            Icon(
                              isSoundOn2 ? Icons.volume_up : Icons.volume_off,
                              color: Colors.black,
                              size: 25.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 500,
                      height: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/button2.png'),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "TIME TO SCORE",
                          style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameWidget(
                              gameController: GameController(
                                spaceship: Player(150, 150, 10, 10, 0, true),
                                isSoundOn2: isSoundOn2,
                                playGoalMusic: _playGoalMusic,
                                initialPlayerSpeed: 5,
                              ),
                              isSoundOn2: isSoundOn2,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/play.png',
                        width: 350,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playGoalMusic() async {
    await audioPlayer2.play(AssetSource('goal.wav'));
    audioPlayer2.setReleaseMode(ReleaseMode.release);
  }
}
