import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'match_swipe_screen.dart'; // Adjust the path as necessary


class PhotoUploadScreen extends StatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File?> uploadedPhotos = List.filled(6, null);

  void _showImagePicker(int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, index);
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, index);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF8B5CF6), size: 30),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        uploadedPhotos[index] = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Photo added successfully!'),
        backgroundColor: Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _removePhoto(int index) {
    setState(() {
      uploadedPhotos[index] = null;
    });
  }

  int get uploadedCount => uploadedPhotos.where((photo) => photo != null).length;

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Photo Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit, color: Color(0xFF8B5CF6)),
                title: Text('Replace Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePicker(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto(index);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Show your best self',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Text('📸', style: TextStyle(fontSize: 28)),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Upload up to six of your best photos to make a fantastic first impression. Let your personality shine.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
              ),
              SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    bool hasPhoto = uploadedPhotos[index] != null;
                    return GestureDetector(
                      onTap: () {
                        hasPhoto ? _showPhotoOptions(index) : _showImagePicker(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasPhoto ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasPhoto ? Color(0xFF8B5CF6) : Colors.grey[300]!,
                            width: 1.5,
                          ),
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
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.check, size: 16, color: Color(0xFF8B5CF6)),
                              ),
                            ),
                          ],
                        )
                            : Icon(Icons.add, size: 40, color: Colors.grey[400]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                margin: EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: uploadedCount > 0 ? () => print('Uploaded $uploadedCount photos') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: uploadedCount > 0 ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Upload',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: PhotoUploadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
