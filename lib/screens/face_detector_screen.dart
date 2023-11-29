import 'package:face_recognization/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? imageFile;
  List<Face> _faces = [];

  /// Function to detect faces in an image
  Future<void> _detectFaces() async {
    if (imageFile == null) return;

    final inputImage = InputImage.fromFile(imageFile!);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final faces = await faceDetector.processImage(inputImage);

    setState(() {
      _faces = faces;
      if (_faces.isNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return HomeScreen();
            }),
          );
          _faces = [];
          imageFile = null;
          setState(() {});
        });
      }
    });

    faceDetector.close(); // Don't forget to close the detector when done
  }

  /// Function to pick an image from the gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });

      if (imageFile != null) {
        _detectFaces(); // Detect faces in the selected image
      }
    }
  }

  /// Function to pick an image from the camera
  Future<void> captureImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });

      if (imageFile != null) {
        _detectFaces(); // Detect faces in the selected image
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: pickImage,
            child: const Icon(Icons.image,),
          ),
          const SizedBox(height: 20,),
          FloatingActionButton(
            onPressed: captureImage,
            child: const Icon(Icons.camera,),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              imageFile != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  SizedBox(
                      child: Image.file(imageFile!,height: 180,),),
                  const SizedBox(height: 20.0),
                  Text(
                    'Detected Faces: ${_faces.length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),

                  // for (Face face in _faces)
                  //   Container(
                  //     margin: EdgeInsets.all(5.0),
                  //     height: 30,
                  //     width: 30,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         color: Colors.red,
                  //         width: 2.0,
                  //       ),
                  //     ),
                  //     // child: Text("${face.landmarks}"),
                  //   ),
                ],
              )
                  : const Text('No image selected.'),

            ],
          ),
        ),
      ),
    );
  }
}