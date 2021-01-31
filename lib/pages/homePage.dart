import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicai/Utils/aiUtils.dart';
import 'package:musicai/model/music.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:alan_voice/alan_voice.dart';

class HomePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<HomePage> {
  List<MyMusic> radio;
  MyMusic _selectedMusic;
  Color _selectedColor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchMusic();
    setupAlan();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "0e6de081d7efa23aa6c97875228e4ebb2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedMusic.url);

        break;
      default:
        print("command was ${response["command"]}");
        break;
    }
  }

  fetchMusic() async {
    final radiojson = await rootBundle.loadString("assets/radio.json");
    radio = MyMusicList.fromJson(radiojson).radio;
    _selectedMusic = radio[0];
    _selectedColor = Color(int.tryParse(_selectedMusic.color));
    print(radio);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedMusic = radio.firstWhere((element) => element.url == url);
    print(_selectedMusic.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    Colors.blue[800],
                    _selectedColor ?? Colors.black,

                    // AIcolors.primaryColor4,
                    // AIcolors.primaryColor3,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
                  title: "musicAI".text.xl4.bold.white.make().shimmer(
                      primaryColor: Vx.purple300, secondaryColor: Vx.white),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  centerTitle: true)
              .h(100.0)
              .p16(),
          radio != null
              ? VxSwiper.builder(
                  itemCount: radio.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    // final color = radio[index].color;
                    _selectedColor = Colors
                        .primaries[Random().nextInt(Colors.primaries.length)];
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final red = radio[index];
                    return VxBox(
                            child: ZStack(
                      [
                        Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                              child: red.category.text.uppercase.white
                                  .make()
                                  .px16(),
                            )
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10.0)
                                .make()),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              red.name.text.xl3.white.bold.make(),
                              5.heightBox,
                              red.tagline.text.sm.semiBold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: [
                              Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "double tap to play".text.gray300.make()
                            ].vStack())
                      ],
                    ))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(red.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .withRounded(value: 60.0)
                        .border(color: Colors.black, width: 5.0)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(red.url);
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
                  alignment: Alignment.bottomCenter,
                  child: [
                    if (_isPlaying)
                      "Playing Now - ${_selectedMusic.name}"
                          .text
                          .white
                          .makeCentered(),
                    Icon(
                      _isPlaying
                          ? CupertinoIcons.stop_circle
                          : CupertinoIcons.play_circle,
                      color: Colors.white,
                      size: 50.0,
                    ).onInkTap(() {
                      if (_isPlaying) {
                        _audioPlayer.stop();
                      } else {
                        _playMusic(_selectedMusic.url);
                      }
                    })
                  ].vStack())
              .pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
