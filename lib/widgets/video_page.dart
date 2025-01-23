import 'dart:core';
import 'package:flutter/material.dart';

import '../widgets/organising_tasks.dart';

import 'package:video_player/video_player.dart';


class VideoPageFramework extends StatefulWidget {
  const VideoPageFramework({super.key});

  @override
  VideoPageInterface createState() => VideoPageInterface();
}

class VideoPageInterface extends State<VideoPageFramework> {
  late VideoPlayerController _videoPlayerController;
  String currentVideo = "assets/videos/priority.mp4"; // default  path

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(currentVideo);
  }

  void _initializeVideoPlayer(String videoPath) {
    _videoPlayerController = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play(); // Automatically play the video
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose(); // Dispose of the controller
    super.dispose();
  }

  void _changeVideo(String videoPath) {
    setState(() {
      currentVideo = videoPath;
      _videoPlayerController.dispose(); // Dispose the previous controller
      _initializeVideoPlayer(videoPath); // Load the new video
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFC6BA), // Beige background
      body: Stack(
        children: [
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          // Logo
          Positioned(
            top: 16,
            right: 16,
            child: Image.asset(
              'assets/images/sign_up.png',
              width: 50,
              height: 50,
            ),
          ),
          // Video player and buttons
          Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Video player w pause/play
              GestureDetector(
                onTap: () {
                  if (_videoPlayerController.value.isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                  setState(() {}); // play/pause state
                },
                child: Container(
                  width: 800,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _videoPlayerController.value.isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                            if (!_videoPlayerController.value.isPlaying)
                              const Icon(
                                Icons.play_arrow,
                                size: 80,
                                color: Colors.white,
                              ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
              const SizedBox(height: 20),
                // Video selection buttons
                Wrap(
                  spacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _changeVideo("assets/videos/priority.mp4"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("PRIORITY"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _changeVideo("assets/videos/multi-level.mp4"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("MLQ"),
                    ),
                    ElevatedButton(
                      onPressed: () => _changeVideo("assets/videos/fcfs.mp4"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("FCFS"),
                    ),
                    ElevatedButton(
                      onPressed: () => _changeVideo("assets/videos/sjf.mp4"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("SJF"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _changeVideo("assets/videos/round-robin.mp4"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("ROUND ROBIN"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Next button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CategoryOrganisationFramework(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


