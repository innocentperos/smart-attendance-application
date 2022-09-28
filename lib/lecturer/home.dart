import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';
import '../utils.dart';


class LecturerHome extends StatefulWidget {
  @override
  _LecturerHomeState createState() => _LecturerHomeState();
}

class _LecturerHomeState extends State<LecturerHome> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Container(
              margin: EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/lecturer-courses");
                  },
                  child: Container(
                    child: Card(

                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text("My Course Attendance",
                        style: TextStyle(
                          fontSize: 26
                        ),
                        )
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/new-course");
                  },
                  child: Container(
                    child: Card(

                      child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text("New Course",
                            style: TextStyle(
                                fontSize: 26
                            ),
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: (){
                    FileHandler.instance.writeToken('');
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: Container(
                    child: Card(

                      child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text("Logout",
                            style: TextStyle(
                                fontSize: 26
                            ),
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
