import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/student/image_capture.dart';
import 'package:smart_attendance/utils/http_service.dart';
import 'package:http/http.dart' as http;

class StudentEnrollment extends StatefulWidget {
  @override
  _StudentEnrollmentState createState() => _StudentEnrollmentState();
}

class _StudentEnrollmentState extends State<StudentEnrollment> {
  String matric_number = '';
  List<CameraDescription> cameras;
  XFile _file;
  bool hasCamera = false;
  bool _next_allow = false;

  bool finishEnrollmentLoading = false;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    availableCameras().then(
      (cams) {
        cameras = cams;

        setState(() {
          hasCamera = true;
        });
      },
    ).whenComplete(() {
      print(
          "Good Cameras ${cameras.length} ++++++++++++++++++++++++++++++++++++++++++++++=");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: (_file != null)
              ? _enrollWidget(context)
              : _matricCapturingWidget(context)),
    );
  }

  Widget _matricCapturingWidget(BuildContext context) {
    return Container(
      height: double.maxFinite,
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (value) {
              matric_number = value;
              setState(() {
                _next_allow = false;
              });
            },
            decoration: InputDecoration(
                labelText: "Student Identification Number",
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
              onPressed: () {
                if (!_next_allow && matric_number != '') {
                  _verifyMatricNumber(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Text("Next"),
              )),
          SizedBox(
            height: 16,
          ),
          if (!_next_allow)
            (ElevatedButton(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Text("Upload Image"),
              ),
            )),
          if (_next_allow)
            (ElevatedButton(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Upload Image"),
                ),
                onPressed: () async {
                  if (cameras.isNotEmpty) {
                    final XFile file = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageCapture(
                                  camera: cameras.last,
                                )));

                    if (file != null) {
                      print("Got a response ---------------------------------");
                      print(file.path);
                      setState(() {
                        _file = file;
                      });
                    }
                  }
                })),
        ],
      ),
    );
  }

  Widget _enrollWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.file(
              File(_file.path),
              // fit: BoxFit.fitWidth,
            )),
        Center(
          child: Text(
            "Student identification Number",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Center(
          child: Text(
            matric_number,
            style: TextStyle(fontSize: 32),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        if(! finishEnrollmentLoading)Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
              onPressed: () async{
                setState(() {
                  finishEnrollmentLoading = true;
                });
                await enrollRequest(context);
                setState(() {
                  finishEnrollmentLoading = false;
                });
              },
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text("Finish Enrollment"))),
        ),
        if(finishEnrollmentLoading)Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text("Finish Enrollment"))),
        ),
       if(!finishEnrollmentLoading) Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
              onPressed: () {
                setState(() {
                  this._next_allow = false;
                  this._file = null;
                  this.matric_number = '';
                });
              },
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text("Cancel Enrollment"))),
        )
      ],
    );
  }

  Future<void> _verifyMatricNumber(BuildContext context) async {
    try {
      HttpService httpService = await HttpService.getInstance();
      http.Response response = await httpService
          .get('/student-view/check?matric_number=${this.matric_number}');

      _showDialog(context, "Opps", "This student has already enrolled");
    } on HTTPException catch (e) {
      print(e.response.body);
      Map<String, dynamic> data = jsonDecode(e.response.body);
      switch (e.status) {
        case 404:
          setState(() {
            this._next_allow = true;
          });
          break;
        case 500:
          // Internal Server error
          print("Internal Server Error occurred");
          break;
      }
      print(e);
    } catch (error) {
      print(error);
    }
  }

  Future<void> _showDialog(
      BuildContext context, String title, String body, {List<Widget> actions}) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(body)],
              ),
            ),
            actions: (actions != null)? actions:
            [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }

  Future<void> enrollRequest(BuildContext context) async {
    HttpService httpService = await HttpService.getInstance();

   try{
     http.Response response = await httpService.postFiles("/student-view/",
         files: {'image': File(_file.path)},
         data: {'matric_number': matric_number});

     _showDialog(context, "Success", "Your face has been successfully enrolled into the system",
     actions:  [
       TextButton(onPressed: (){
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed("/");
       }, child: Text("Close"))
     ]);
   }on HTTPException catch(error){
     print("Http Response Error");
     print(error.status);
     print(error.response.body);
     if ( error.status != 500){
       Map<String, dynamic> data = json.decode(error.response.body);
       _showDialog(context, "Oops", data['message']);
     }else{
       _showDialog(context, "Error", "Something went wrong on the server");
     }
   }catch(error){
     _showDialog(context, "Error", "Something went wrong please try again");
   }
  }
}
