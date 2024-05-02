import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'postPage.dart';
import 'package:video_player/video_player.dart';
import 'loginPage.dart';
import 'main.dart'; // ファイル名を正しく指定



class Body extends StatefulWidget {
final List<String> items;
final List<String> userNames;
final List<String> descriptions;
final List<String> userIcon;

const Body({super.key, required this.items, required this.userNames, required this.descriptions, required this.userIcon});

@override
_BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late List<VideoPlayerController> _controllers;
  List<bool> _isInitialized = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(widget.items.length, (index) {
      return VideoPlayerController.asset(widget.items[index])
        ..initialize().then((_) {
          setState(() {
            _isInitialized[index] = true;
            _controllers[index].setLooping(true);
            _controllers[index].pause();
          });
        });
    });
    _isInitialized = List.filled(widget.items.length, false);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
  Padding(
  padding: const EdgeInsets.all(20.0),
  child: InkWell(
     // タップされたときのアクション
        onTap: (){

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeRealStyleCameraPage()),
          );
        },
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: Colors.black,  // テキストの背景色
      border: Border.all(color: Colors.white, width: 2),  // 白い枠線
      borderRadius: BorderRadius.circular(10),  // 枠の角を丸く
    ),
    child: Text("投稿する", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
  ),
),),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(widget.userIcon[index]),
                      ),
                      title: Text(widget.userNames[index], style: TextStyle(color: Colors.white)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_isInitialized[index]) {
                            if (_controllers[index].value.isPlaying) {
                              _controllers[index].pause();
                            } else {
                              _controllers[index].play();
                            }
                          }
                        });
                      },

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            // decoration: BoxDecoration(
                            //   color: Colors.black,
                            //   // border: Border.all(color: Colors.white, width: 1),
                            //   // borderRadius: BorderRadius.circular(10),
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: _isInitialized[index]
                                    ? VideoPlayer(_controllers[index])
                                    : Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                          if (!_controllers[index].value.isPlaying)
                            Icon(Icons.play_arrow, size: 50, color: Colors.white),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.descriptions[index], style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage(this.user);
   final User user;
  // const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      'images/test.mov',
      'images/test.mov',
      'images/test.mov',
      'images/test_video.mp4',
      'images/test_video.mp4',
    ];

    final List<String> userNames = [
      'User One',
      'User Two',
      'User Three',
      'User Four',
      'User Five',
    ];

    final List<String> userIcon = [
      'images/image.jpeg',
      'images/image.jpeg',
      'images/image.jpeg',
      'images/image.jpeg',
      'images/image.jpeg',
    ];

    final List<String> descriptions = [
      'Description for test1',
      'Description for test2',
      'Description for test3',
      'Description for test4',
      'Description for test5',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:AppBar(
      title: Text('${user.email}'),
      backgroundColor: Colors.black,
    ),
      body: Body(items: items, userNames: userNames, descriptions: descriptions, userIcon: userIcon),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await FirebaseAuth.instance.signOut();

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
