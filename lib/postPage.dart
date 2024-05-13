import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/VideoPlaybackPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class BeRealStyleCameraPage extends StatefulWidget {
  const BeRealStyleCameraPage({super.key});

  @override
  _BeRealStyleCameraPageState createState() => _BeRealStyleCameraPageState();
}

class _BeRealStyleCameraPageState extends State<BeRealStyleCameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _cameraController?.stopVideoRecording().then((file) {
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
        }
        // 動画を再生するページにナビゲートする（ビデオ再生ページは別途実装が必要です）
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VideoPlaybackPage(videoFile: file),
        //   ),
        // );
      });
    } else {
      _cameraController?.startVideoRecording().then((_) {
        if (mounted) {
          setState(() {
            _isRecording = true;
          });
        }
      });
    }
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // 角を丸くする
      child: CameraPreview(_cameraController!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4, // 縦横比を4:3に設定
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 角を丸くする
                    border: Border.all(color: Colors.white, width: 3), // 白い枠を追加
                  ),
                  child: _buildCameraPreview(), // カメラプレビューを追加
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              child: Icon(_isRecording ? Icons.stop : Icons.camera),
              onPressed: _toggleRecording,
            ),
          ),
        ],
      ),
    );
  }
}
