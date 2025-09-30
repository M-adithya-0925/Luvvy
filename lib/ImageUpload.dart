import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'match_swipe_screen.dart';
import 'services/FirebaseService.dart';

class PhotoUploadScreen extends StatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File?> uploadedPhotos = List.filled(6, null);
  List<File?> uploadedVideos = List.filled(2, null);
  List<VideoPlayerController?> videoControllers = List.filled(2, null);
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose video controllers
    for (var controller in videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _showMediaPicker(int index, {bool isVideo = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      isVideo ? 'Add Video' : 'Add Photo',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isVideo
                          ? 'Share a short video to show your personality'
                          : 'Choose your best photo to make a great impression',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerOption(
                            icon: Icons.photo_library_outlined,
                            label: isVideo ? 'Gallery' : 'Gallery',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              isVideo
                                  ? _pickVideo(ImageSource.gallery, index)
                                  : _pickImage(ImageSource.gallery, index);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPickerOption(
                            icon: isVideo ? Icons.videocam_outlined : Icons.camera_alt_outlined,
                            label: 'Camera',
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              isVideo
                                  ? _pickVideo(ImageSource.camera, index)
                                  : _pickImage(ImageSource.camera, index);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          uploadedPhotos[index] = File(pickedFile.path);
        });
        _showSuccessMessage('Photo added successfully! 📸');
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source, int index) async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );
      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);

        // Dispose previous controller if exists
        videoControllers[index]?.dispose();

        // Create new video controller
        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();

        setState(() {
          uploadedVideos[index] = videoFile;
          videoControllers[index] = controller;
        });

        _showSuccessMessage('Video added successfully! 🎥');
      }
    } catch (e) {
      _showErrorMessage('Failed to pick video: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      uploadedPhotos[index] = null;
    });
    _showSuccessMessage('Photo removed');
  }

  void _removeVideo(int index) {
    videoControllers[index]?.dispose();
    setState(() {
      uploadedVideos[index] = null;
      videoControllers[index] = null;
    });
    _showSuccessMessage('Video removed');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMediaOptions(int index, {bool isVideo = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      isVideo ? 'Video Options' : 'Photo Options',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit, color: Colors.blue.shade600),
                      ),
                      title: Text('Replace ${isVideo ? "Video" : "Photo"}'),
                      onTap: () {
                        Navigator.pop(context);
                        _showMediaPicker(index, isVideo: isVideo);
                      },
                    ),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete, color: Colors.red.shade600),
                      ),
                      title: Text('Remove ${isVideo ? "Video" : "Photo"}'),
                      onTap: () {
                        Navigator.pop(context);
                        isVideo ? _removeVideo(index) : _removePhoto(index);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int get uploadedPhotoCount => uploadedPhotos.where((photo) => photo != null).length;
  int get uploadedVideoCount => uploadedVideos.where((video) => video != null).length;
  int get totalMediaCount => uploadedPhotoCount + uploadedVideoCount;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      // Save photos and videos to Firebase
      // await FirebaseService().uploadUserMedia(uploadedPhotos, uploadedVideos);

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate to next screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchSwipeScreen()),
        );
      }
    } catch (e) {
      _showErrorMessage('Failed to upload media: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        bool hasPhoto = uploadedPhotos[index] != null;
        return GestureDetector(
          onTap: () {
            hasPhoto ? _showMediaOptions(index) : _showMediaPicker(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: hasPhoto ? null : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasPhoto ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                width: hasPhoto ? 2 : 1.5,
              ),
              boxShadow: hasPhoto ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ] : null,
              image: hasPhoto
                  ? DecorationImage(
                image: FileImage(uploadedPhotos[index]!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasPhoto
                ? Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid() {
    return Row(
      children: List.generate(2, (index) {
        bool hasVideo = uploadedVideos[index] != null;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 0 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                hasVideo ? _showMediaOptions(index, isVideo: true) : _showMediaPicker(index, isVideo: true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 140,
                decoration: BoxDecoration(
                  color: hasVideo ? Colors.black : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasVideo ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                    width: hasVideo ? 2 : 1.5,
                  ),
                  boxShadow: hasVideo ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                ),
                child: hasVideo
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: videoControllers[index] != null
                          ? AspectRatio(
                        aspectRatio: videoControllers[index]!.value.aspectRatio,
                        child: VideoPlayer(videoControllers[index]!),
                      )
                          : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 18,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_camera_back_outlined,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Video ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max 30 seconds',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade200,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Show your best self',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text("📸", style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Upload your best photos and videos to create an amazing profile that shows your personality.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Media stats
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library, color: Colors.blue.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Photos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$uploadedPhotoCount/6',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: uploadedPhotoCount > 0 ? Colors.blue.shade600 : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam, color: Colors.purple.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Videos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$uploadedVideoCount/2',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: uploadedVideoCount > 0 ? Colors.purple.shade600 : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Photos section
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.blue.shade600, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: uploadedPhotoCount > 0 ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: uploadedPhotoCount > 0 ? Colors.green.shade200 : Colors.orange.shade200,
                            ),
                          ),
                          child: Text(
                            uploadedPhotoCount > 0 ? 'Required ✓' : 'At least 1 required',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: uploadedPhotoCount > 0 ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildPhotoGrid(),

                    const SizedBox(height: 32),

                    // Videos section
                    Row(
                      children: [
                        Icon(Icons.videocam, color: Colors.purple.shade600, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Short Videos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildVideoGrid(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: uploadedPhotoCount > 0 && !_isLoading
                        ? _handleContinue
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: uploadedPhotoCount > 0 ? 2 : 0,
                    ),
                    child: _isLoading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Uploading media...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      totalMediaCount > 0
                          ? "Continue ($totalMediaCount items)"
                          : "Add at least 1 photo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: uploadedPhotoCount > 0 ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
