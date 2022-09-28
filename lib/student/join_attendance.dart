import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_attendance/models/course.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/student/image_capture.dart';
import 'package:smart_attendance/utils/http_service.dart';
import 'package:smart_attendance/widgets/my_button.dart';
import 'package:http/http.dart' as http;

class StudentJoinAttendance extends StatefulWidget {
  @override
  _StudentJoinAttendanceState createState() => _StudentJoinAttendanceState();
}

class _StudentJoinAttendanceState extends State<StudentJoinAttendance> {
  CameraController _controller;
  List<CameraDescription> cameras;
  String _matric_number = '';
  String _attendance_code = '';
  Course _course;
  String _current_state = "validate";
  bool hasCamera = false;
  File _file;


  Map <String, String> attendancePosition ={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
        child: _renderAppropriateWidget(context),
      ),
    );
  }

  Widget _renderAppropriateWidget(BuildContext context) {
    switch (_current_state) {
      case 'validate':
        return _getStudentID(context);
        break;
      case 'verify':
        return _showDetails(context);
        break;
      case 'uploading':
        return _uploading(context);
        break;
      default:
        return _getStudentID(context);
        break;
    }
  }

  Future<void> _showDialog(BuildContext context, String title, String body,
      {List<Widget> actions}) async {
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
            actions: (actions != null)
                ? actions
                : [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"))
                  ],
          );
        });
  }

  Widget _getStudentID(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Joining an Attendance",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 8,
          ),
          TextField(
            controller: TextEditingController()..text=_matric_number,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: "Matric Number",
                labelText: "Matric Number"),
            onChanged: (value) {
              this._matric_number = value;
            },
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            controller: TextEditingController()..text=_attendance_code,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: "Attendance Code",
                labelText: "Attendance Code"),
            onChanged: (value) {
              this._attendance_code = value;
            },
          ),
          MyButton(
            "Next",
            onPress: () {

              _getInfoFromServer(context);
            },
          )
        ],
      ),
    );
  }

  Future<void> _getInfoFromServer(context) async {
    HttpService service = await HttpService.getInstance();

    try {
      http.Response response = await service.post(
          url: '/attendance-view/validate/',
          data: <String, String>{
            'matric_number': _matric_number,
            'attendance_code': _attendance_code
          });
      print(response.body);
      Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        _course = Course.fromMap(data['course']);
        _current_state = "verify";
        attendancePosition['lat'] = data['lat'];
        attendancePosition['long'] = data['long'];

      });
    } on HTTPException catch (error) {
      if (error.status == 500) {
        print("Error-----------------------------------Server**");
        print(error.response.body);
        _showDialog(
            context, "Oops", "Something went wrong on the server, sorry");
      } else {
        print("Error-----------------------------------Not 2**");
        print(error.response.body);

        Map<String, dynamic> data = jsonDecode(error.response.body);
        _showDialog(context, "Error", data['message']);
      }
    } catch (error) {
      print("Error ------------------------------------Network");
      print(error);
    }
  }

  Widget _showDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
          ),
          Text(
            _course.title,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            _course.code,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 46,
          ),
          Text(
            "Student Matric Number",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            _matric_number,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 16,
          ),
          MyButton(
            "Join Attendance",
            onPress: () async {
              if (hasCamera == true) {
                if (cameras.length < 1) {
                  _showDialog(context, "Oops",
                      "Could not get access to the device camera");
                }
              }
              try {
                XFile file = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (c) => ImageCapture(
                          camera: cameras.last,
                        )));
                if (file != null) {
                  _file = File(file.path);
                  setState(() {
                    _current_state = "uploading";
                    _uploadAttendance(context, attendancePosition);
                  });
                }
              } catch (error) {}
            },
          )
        ],
      ),
    );
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // [ANDROID]
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best,);
  }

  Widget _uploading(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 16,
            ),
            Text("Attending Please wait...")
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAttendance(BuildContext context, Map<String, String> position2) async{
    HttpService service = await HttpService.getInstance();

    Position position = await _determinePosition();
    print("________________Position___________________");
    print(position);

    if (position.longitude > 0){

      double distanceInMeters = Geolocator.distanceBetween(position.latitude, position.longitude, double.parse(position2['lat']), double.parse(position2['long']));
      print("________________Distance___________________");
      print(distanceInMeters);


      if ( distanceInMeters < 1000 ){

        HttpService service = await HttpService.getInstance();

        try{
          http.Response response = await service.postFiles('/attendance-view/attend/',data: {
            'distance' : distanceInMeters.toString(),
            'lat': position.latitude.toString(),
            'long': position.longitude.toString(),
            'attendance_code': _attendance_code,
            'matric_number' : _matric_number
          },files: {
            'image': _file
          });
          print("________________________response________________");
          print(response.body);
          
          _showDialog(context, "Success", "You have been added to the attendance list",
          actions: [
            TextButton(onPressed: (){
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            }, child: Text("OK"))
          ]);
        }on HTTPException catch(e){
          if ( e.status == 500){
            print("__________error_______________server");
            _showDialog(context, "Server error", "something went wrong on the server");
          }else{
            print("__________error_______________client");
            print(e.response.body);
            var data = json.decode(e.response.body);
            _showDialog(context, "Oops", data['message']);
          }

          _file = null;
          setState(() {
            _current_state = "validate";
          });
        }catch(error){
          print("__________error_______________device");
          print(error);
          _showDialog(context, "Error", "something went wrong ");
        }

      }else{
        _showDialog(context, "Opps", "Your to far away, please come closer to the lecturer and retry", actions: [
          TextButton(onPressed: (){
            setState(() {
              _current_state ="verify";
            });
          }, child: Text("Ok"))
        ]);
      }

    }

  }
}
