import 'package:flutter/material.dart';
import 'package:smart_attendance/student/student_enroll.dart';

import 'join_attendance.dart';

class StudentHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: AssetImage('assets/image.png'),
                height: 100,
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Join a attendance"),
                ),
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context)=> StudentJoinAttendance()
                      )
                  );
                },
              ),
            ),

            Container(
              margin: EdgeInsets.all(16),
              child: ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Enroll as a new Student"),

                ),
                onPressed: (){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context)=> StudentEnrollment()
                      )
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
