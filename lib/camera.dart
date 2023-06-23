
/*
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main () async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(
    camera:firstCamera
  ));
}

class MyApp extends StatelessWidget {

  const MyApp({
    super.key, 
    required this.camera,
    });
  
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Products',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Products'),
          backgroundColor: Colors.blue.shade700,
        ),
      body: const MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(//Barcode
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.barcode_reader),
                labelText: "Barcode"
              ),
              validator: (value) {
                if (value == null || value.isEmpty){
                  return "Enter Barcode";
                }
                if (double.tryParse(value) == null){
                  return "Invalid Barcode";
                }
                return null;
              },
            ),
          ),

          Padding(//Submit
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (){
                if(_formKey.currentState!.validate()){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing...'))
                  );
                }
              }, 
              child: const Text('Submit')
            ),
          )

        ],
      ),
    );
  }
}


class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera
    });

    final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    //To display the current camera output
    // create a Camera controller 
    _controller = CameraController(
      //get the specific camera
      widget.camera,
      //define the resolution
      ResolutionPreset.medium
      );
    //initialize the controller. This returns a Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take pictures'),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            //if the future is done display the preview
            return CameraPreview(_controller);
          } else{
            //Otherwise display a loading indicator
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Take a picture in a try / catch block. If anything goes wrong
          // catch the error
          try{
            await _initializeControllerFuture;
            final image = await _controller.takePicture();

            if(!mounted) return;
            
            //if the picture was taken, display it on a new screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context)=> DisplayPictureScreen(
                  imagePath: image.path
                ),
                ),
            );
          }
          catch (e){
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
        
      ),
      

    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

*/