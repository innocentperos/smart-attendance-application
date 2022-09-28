import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImageCapture extends StatefulWidget {
  const ImageCapture({
    Key key,
    this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  XFile _file;
  bool _flash = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.low,
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
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: (_flash)? Icon(Icons.flash_on): Icon(Icons.flash_off),
              onPressed: (){
                setState(() {
                  _flash = !_flash;

                  if (_flash){
                    _controller.setFlashMode(FlashMode.auto);
                  }else{
                    _controller.setFlashMode(FlashMode.off);
                  }
                });
              },
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CameraPreview(_controller),
                  SizedBox(
                    height: 30,
                  ),
                  if (_file == null)
                    Container(
                      margin: EdgeInsets.all(16),
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Capture"),
                        ),
                        onPressed: () async {
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Attempt to take a picture and then get the location
                            // where the image file is saved.
                            _controller.setFlashMode(FlashMode.off);
                            final image = await _controller.takePicture();
                            setState(() {
                              this._file = image;
                            });
                            _controller.pausePreview();
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                      ),
                    ),
                  if (_file != null)
                    Container(
                      margin: EdgeInsets.all(16),
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Recapture"),
                        ),
                        onPressed: () {
                          setState(() {

                            this._file = null;
                          });
                          _controller.resumePreview();
                        },
                      ),
                    ),
                  if (_file != null)
                    Container(
                      margin: EdgeInsets.all(16),
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("Continue"),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(_file);
                        },
                      ),
                    )
                ],
              ),
            ),
          );
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
