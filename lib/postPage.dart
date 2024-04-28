import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class BeRealStyleCameraPage extends StatefulWidget {
  @override
  _BeRealStyleCameraPageState createState() => _BeRealStyleCameraPageState();
}

class _BeRealStyleCameraPageState extends State<BeRealStyleCameraPage> {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  String? videoPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _handleVideoRecording() async {
    try {
      if (_cameraController!.value.isRecordingVideo) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    } catch (e) {
      print('Error handling video recording: $e');
    }
  }

  Future<void> _startRecording() async {
    final directory = await getTemporaryDirectory();
    final path = join(directory.path, "${DateTime.now()}.mp4");
    await _cameraController!.startVideoRecording();
    videoPath = path;
  }

  Future<void> _stopRecording() async {
    final videoFile = await _cameraController!.stopVideoRecording();
    videoFile.saveTo(videoPath!);
    _videoPlayerController = VideoPlayerController.file(File(videoPath!))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _videoPlayerController!.play();
          });
        }
      });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BeReal Style Camera')),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),
          ),
          if (_videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized)
            Container(
              padding: EdgeInsets.all(4),
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.camera_alt),
              iconSize: 60,
              onPressed: _handleVideoRecording,
            ),
          ),
        ],
      ),
    );
  }
}
