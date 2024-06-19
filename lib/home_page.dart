import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File ? _selectedImage;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double valorOpacidad = 0.5;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      const CameraDescription(name: '', lensDirection: CameraLensDirection.back, sensorOrientation: 2),
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CamDraw'),
        actions: [
          IconButton(
              onPressed: () => _pickImageFromGallery(),
              icon: const Icon(Icons.photo),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          SizedBox(
            width: size.width,
            height: size.height,
            child: _selectedImage != null
                ? Opacity(
                  opacity: valorOpacidad,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2,
                    child: Image.file(_selectedImage!),
                  )
                )
                : const Text('Please, select an image'),
          ),

          Column(
            children: [
              Spacer(),
              Slider(
                value: valorOpacidad,
                label: valorOpacidad.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    valorOpacidad = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }
}
