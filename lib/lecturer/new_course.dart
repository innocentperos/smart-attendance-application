import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/utils.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';


Future<http.Response> add_course_request(title, code) async {
  String token = await FileHandler.instance.readToken();
  print("token");
  print(token);
  return http.post(
      Uri.parse("${Constants.ACCESS_POINT}/course-view/" ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'code': code
      })
  );
}

Future<void> showSuccessDialog (BuildContext context) async{
  return showDialog<void>(context: context, builder: (BuildContext context){
    return AlertDialog(
      title:const Text("Successful"),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text("The course was successfully added")
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: (){
        }, child: const Text("View")),
        TextButton(onPressed: (){
          Navigator.of(context).pop();
          Navigator.of(context).pop();

        }, child: const Text("Close"))
      ],
    );
  });
}
class NewCourse extends StatefulWidget {
  @override
  _NewCourseState createState() => _NewCourseState();
}

class _NewCourseState extends State<NewCourse> {

  String title = '',
      code = '';
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add A new Course",
                      style: TextStyle(
                        fontSize: 24,
                      )),
                  Text("to collect this course attendance",
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Course Title"
                ),
                onChanged: (value) {
                  this.title = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Course Code"
                ),
                onChanged: (value) {
                  this.code = value;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: !_loading ? Text(
                    "Add Course"
                ): CircularProgressIndicator(backgroundColor: Colors.white,),

              ),
                  onPressed: () async {
                    if(_loading) return;

                    if ( title.trim().isEmpty || code.trim().isEmpty){
                      DialogMaster.MyshowDialog(context, "Missing Required Field", "Please provide Course Title and Code");
                      return;
                    }
                    setState(() {
                      _loading = true;
                    });
                    try {
                      var response = await add_course_request(
                          this.title, this.code);

                      String code = response.statusCode.toString();

                      print("Response");
                      print(response.body);
                      if (code.startsWith("2")){
                        DialogMaster.MyshowDialog(context, "New Course Added", "Your course was successfully added",actions:[
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacementNamed("/lecturer-courses");

                          }, child: Text("Close"))
                        ]);
                      }

                    } catch (error) {
                      print("Error Occurred");
                      print(error);
                    }
                    setState(() {
                      _loading = false;
                    });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
