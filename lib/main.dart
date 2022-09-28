import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_attendance/lecturer/attendance_viewer.dart';
import 'package:smart_attendance/lecturer/course_attendance.dart';
import 'package:smart_attendance/lecturer/home.dart';
import 'package:smart_attendance/lecturer/lecturer_courses.dart';
import 'package:smart_attendance/lecturer/new_attendance.dart';
import 'package:smart_attendance/lecturer/new_course.dart';
import 'package:smart_attendance/lecturer/signup.dart';
import 'package:smart_attendance/student/student_enroll.dart';
import 'package:smart_attendance/student/student_home.dart';
import 'package:smart_attendance/utils.dart';

import 'lecturer/login.dart';
import 'package:http/http.dart' as http;


Future<http.Response> get_user_type_request (String token) {

  return http.get(
      Uri.parse("${Constants.ACCESS_POINT}/user"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      }
  );
}
class MyHttpOverrides extends HttpOverrides{

  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
  }
}


Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  print("Loading location");
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
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}

Future<void> main() async{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());


}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Lecture Attendance',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white
      ),
      initialRoute: '/',
      routes: {
    '/': (context) => MyHomePage(),
    '/lecturer-login' : (context) => Login(),
    '/lecturer-signup': (context) => SignupLecturer(),
    '/lecturer-home': (context) => LecturerHome(),
    '/new-course': (context) => NewCourse(),
    "/lecturer-courses": (context) => LecturerCourses(),
    "/course-attendance": (context) => LecturerCourseAttendance(),
    "/new-attendance" : (context) => LecturerNewAttendance(),
    "/student-home" : (context)=> StudentHome(),
        "/attendance-viewer": (context) =>AttendanceViewer()
      },

    );
  }



}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.white
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: AssetImage('assets/image.png'),
                  height: 100,
                ),
              ),
              Center(child: Text("Smart Attendance Application")),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text("Lecturer"),
                  ),
                  onPressed: ()=>{
                    Navigator.pushNamed(context, '/lecturer-login')
                  },
                ),

              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text("Student"),
                  ),
                  onPressed: ()=>{
                    Navigator.of(context).pushNamed("/student-home")
                  },
                ),

              )
            ],
          ),
        ),
      ),
    );
  }


}
