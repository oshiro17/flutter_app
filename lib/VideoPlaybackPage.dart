import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackPage extends StatefulWidget {
  final File file;

  const VideoPlaybackPage({Key? key, required this.file}) : super(key: key);

  @override
  _VideoPlaybackPageState createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {}); // ビデオが初期化された後、UIを更新
        _controller?.play(); // ビデオの再生を自動的に開始
      });
  }

  @override
  void dispose() {
    _controller?.dispose(); // コントローラのリソースを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Playback'),
      ),
      body: Center(
        child: _controller == null || !_controller!.value.isInitialized
          ? CircularProgressIndicator() // ビデオがロードされる間はローディングインジケータを表示
          : AspectRatio(
              aspectRatio: _controller!.value.aspectRatio, // ビデオのアスペクト比を維持
              child: VideoPlayer(_controller!), // ビデオプレイヤーウィジェット
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller!.value.isPlaying) {
            _controller?.pause(); // 再生中なら一時停止
          } else {
            _controller?.play(); // 停止中なら再生
          }
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
