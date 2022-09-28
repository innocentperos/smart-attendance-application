import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smart_attendance/models/course.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:smart_attendance/utils/http_service.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';
import 'package:smart_attendance/widgets/my_button.dart';

class LecturerNewAttendance extends StatefulWidget {
  @override
  _LecturerNewAttendanceState createState() => _LecturerNewAttendanceState();
}

class _LecturerNewAttendanceState extends State<LecturerNewAttendance> {
  bool stop = false;
  Position _currentPosition;
  bool _locationChecked = false;

  String _code = '';
  bool _comitted = false;

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context).settings.arguments as Course;
    final style = MediaQuery.of(context);
    final size = style.size;

    return Scaffold(
        body: FutureBuilder(
      future: ()async {
        return _new_attendance_request(arg);
      }(),
      builder: (context, snapShot) {
        if (snapShot.hasError) {
          print(snapShot.error);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Text(
                snapShot.error.toString(),
                maxLines: 10,
              ))
            ],
          );
        }

        if (snapShot.hasData == false) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Container(child: CircularProgressIndicator())),
              Text("Please Wait")
            ],
          );
        }
        _code = snapShot.data['code'];

        return SafeArea(child: _createContent(arg, size));
      },
    ));
  }

  Widget _createContent(arg, Size size) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.teal, Colors.deepOrange]),
              color: Colors.lightBlue.withAlpha(40)),
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              "New Attendance",
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  arg.title,
                  style: TextStyle(fontSize: 22),
                ),
                Text(
                  arg.code,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 30),

        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "Attendance Code",
          style: TextStyle(fontSize: 20, color: Colors.lightBlue),
        ),
        Text(
          _code,
          style: TextStyle(fontSize: 56),
        ),
        if(_comitted == false )MyButton(
          "Pause",
          onPress: () {
            _close();
          },
          style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
        ),
        if(_comitted == false )MyButton(
          "Resume",
          onPress: () {
            _open();
          },
          style: ElevatedButton.styleFrom(primary: Colors.green),
        ),
        if(_comitted == false ) MyButton(
          "Commit",
          onPress: () async{
            setState(() {
              this.stop = true;
              this._commit();
            });
          },
          style: ElevatedButton.styleFrom(primary: Colors.teal),
        ),
        if (_comitted ) MyButton(
          "Close",
          onPress: () async{
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(primary: Colors.teal),
        )
      ],
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
    return await Geolocator.getCurrentPosition();
  }

  Map<String, dynamic> _data;

  Future<Map<String, dynamic>> _new_attendance_request(Course course) async {
    if (_data != null) {
      return _data;
    }

    try {
      String token = await FileHandler.instance.readToken();
      Position pos = await _determinePosition();
      _locationChecked = true;
      _currentPosition = pos;
      http.Response response = await http.post(
          Uri.parse("${Constants.ACCESS_POINT}/attendance-view/"),
          headers: {
            "Authorization": "Token $token"
          },
          body: {
            'lat': pos.latitude.toString(),
            'long': pos.longitude.toString(),
            'course': course.id.toString()
          });

      if (response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(response.body);
        _data = data;
        return data;
      } else {
        _data = null;
        return null;
      }
    } catch (e) {
      // TODO
      print(e);
      throw e;
    }
  }

  Future<void> _commit () async {
    if (_data == null && !_data.containsKey('id')){

      return;
    }

    HttpService service = await HttpService.getInstance();

    try {
      http.Response response = await service.get('/attendance-view/${_data["id"]}/commit');
      print(response.body);
      setState(() {
        _comitted = true;
      });

    } on HTTPException catch (e) {
      if ( e.status == 500){
        DialogMaster.MyshowDialog(context, "Error", "Something went wrong on the server");
      }else{
        dynamic data = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Error", data['message']);
      }
      // TODO
    }

  }

  Future<void> _open () async {
    if (_data == null && !_data.containsKey('id')){

      return;
    }

    HttpService service = await HttpService.getInstance();

    try {
      http.Response response = await service.get('/attendance-view/${_data["id"]}/open');
      print(response.body);
      stop = false;

    } on HTTPException catch (e) {
      if ( e.status == 500){
        DialogMaster.MyshowDialog(context, "Error", "Something went wrong on the server");
      }else{
        dynamic data = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Error", data['message']);
      }
      // TODO
    }

  }

  Future<void> _close () async {
    if (_data == null && !_data.containsKey('id')){

      return;
    }

    HttpService service = await HttpService.getInstance();

    try {
      http.Response response = await service.get('/attendance-view/${_data["id"]}/close');
      print(response.body);
      stop = true;
      Map data = jsonDecode(response.body);
      print(response.body);
      print("___________________");
      DialogMaster.MyshowDialog(context, "Student Count", "The list contains ${data['attendances']} entries");
    } on HTTPException catch (e) {

      if ( e.status == 500){
        DialogMaster.MyshowDialog(context, "Error", "Something went wrong on the server");
      }else{
        dynamic data = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Error", data['message']);
      }
      // TODO
    }

  }
}
