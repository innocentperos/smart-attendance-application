import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';
import 'package:smart_attendance/models/Attendance.dart';
import 'package:smart_attendance/models/course.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/utils/exporter.dart';
import 'package:smart_attendance/utils/http_service.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';
import 'package:url_launcher/url_launcher.dart';
class LecturerCourseAttendance extends StatefulWidget {
  @override
  _LecturerCourseAttendanceState createState() => _LecturerCourseAttendanceState();

}



class _LecturerCourseAttendanceState extends State<LecturerCourseAttendance> {

  List<Attendance> _attendances = [];
  String _mark = '';
  bool _exporting = false;
  @override
  Widget build(BuildContext context) {

    final  arg = ModalRoute.of(context).settings.arguments as Course;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.import_export),
        onPressed: (){

          showDialog(context: context, builder: (context){
            return AlertDialog(
              title:Text("Enter Attendance Mark"),
              content: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder()
                ),
                keyboardType: TextInputType.number,
                onChanged: (value){
                  _mark = value;
                },
              ),
              actions: [
                if (!_exporting ) TextButton(
                  child: Text("Generate"),
                  onPressed: () async{
                    setState(() {
                      _exporting = true;
                    });
                    File file = await Exporter.exportAll(arg, context, _mark);
                    ShareExtend.share(file.path, "xlsx");
                    setState(() {
                      _exporting = false;
                    });

                    // Navigator.of(context).pop();
                  },
                ),
                if (_exporting) TextButton(
                  child: Text("exporting")
                ),
                TextButton(
                  child: Text("Close"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        },
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          onPressed: (){
            Navigator.pushNamed(context, "/new-attendance", arguments: arg);
          },

          style: ButtonStyle(

          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  "Take a new Attendance"
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getAttendances(arg,context:context),
        builder: (context, snapShot){
          if (snapShot.hasData){
            return SafeArea(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(arg.title,
                        style: TextStyle(
                            fontSize: 22
                        ),
                      ),
                    ),
                  ),
                  _attendancesList()
                ],
              ),
            );
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }

  Widget _attendancesList (){
    if ( _attendances.length < 1){
      return Center(
        child: Text(
          "No attendances"
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
          itemCount: _attendances.length,
          itemBuilder: (context, index){
            return Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
              child: InkWell(
                splashColor: Colors.lightBlue.withAlpha(100),
                highlightColor: Colors.lightBlue.shade300.withAlpha(10),
                onTap: (){
                  Navigator.of(context).pushNamed( "/attendance-viewer", arguments: _attendances[index]);

                },

                child: Container(

                  decoration: BoxDecoration(

                      color: (){
                        Attendance at = _attendances[index];
                        if ( at.isOpen){
                          return Colors.tealAccent;
                        }else{
                          return Colors.amberAccent;
                        }
                      }(),

                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom:12),
                          child: Text("Date: ${_attendances[index].date.split(";")[0]}",
                            style: TextStyle(
                                fontSize: 22
                            ),),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom:6),
                          child: Text("Time: ${_attendances[index].date.split(";")[1]}",
                            style: TextStyle(
                                fontSize: 16
                            ),),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("Attendance Count ${_attendances[index].attendances.toString()}",
                            style: TextStyle(
                                fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),),
                        ),
                        SizedBox(height: 16,),
                        ElevatedButton(onPressed: () async{
                          try {
                            File file = await Exporter.exportAttendance(_attendances[index], context);
                              setState(() {
                              _exporting = false;
                            });
                            ShareExtend.share(file.path, "application/xlsx");

                          } on Exception catch (e) {
                            // TODO
                            DialogMaster.MyshowDialog(context, "Error Exporting", "Could not export list");
                          }
                        }, child:
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text("Export"),
                            ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange.withAlpha(200),
                            elevation: 0
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Future<List<Attendance>> _getAttendances(Course course,{BuildContext context}) async{
    String token = await FileHandler.instance.readToken();
     try {
       List<Attendance> attendances = await Webservice().load(Attendance.all(course), token);
       this._attendances = attendances;
       return attendances;
     } catch (e) {
       print("Error-----------------------------------------");
       print(e);
       // TODO
       throw e;
     }


  }

  Future<void> _export(BuildContext context, Attendance attendance) async {
    try {
      // String token = await FileHandler.instance.readToken();
      //
      HttpService service = await HttpService.getInstance();

      http.Response response =
      await service.get("/attendance-view/${attendance.id}/export");

      Map<String, dynamic> data = jsonDecode(response.body);
      DialogMaster.MyshowDialog(context, "Export Success",
          "Your attendance list is ready for download",
          actions: [
            TextButton(
              child: Text("Download"),
              onPressed: () async {
                String url = '${Constants.BASE_URL}${data["url"]}';
                // _exportDownload(context, url, attendance);
                try {
                  await launch(url);
                } on Exception catch (e) {
                  // TODO
                  print("Could not launch share");
                  print(e);
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    } on HTTPException catch (error) {
      http.Response response = error.response;

      if (error.status == 500) {
        DialogMaster.MyshowDialog(
            context, "Server Error", "Something went wrong on the server");
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        DialogMaster.MyshowDialog(context, "Oops", data['message']);
      }

      return null;
    } on IOException catch (error) {
      DialogMaster.MyshowDialog(
          context, "Authentication Failed", "Please login", onCloseClick: () {
        Navigator.of(context).pushReplacementNamed("/lecturer-login");
      });
    } finally {

    }
  }

  Future<void> _exportAll(BuildContext context, Course course) async {
    int mark =0;
    try {
      mark = int.parse(_mark);
    } catch (e) {
      // TODO
      DialogMaster.MyshowDialog(context, "Invalid Mark", "please provide a valid number");
      return;
    }
    try {
      // String token = await FileHandler.instance.readToken();
      //
      HttpService service = await HttpService.getInstance();

      http.Response response =
      await service.get("/attendance-view/${course.id}/export_all?mark=$mark");

      Map<String, dynamic> data = jsonDecode(response.body);
      DialogMaster.MyshowDialog(context, "Export Success",
          "Your compiled attendance list is ready for download as an excel file",
          actions: [
            TextButton(
              child: Text("Download"),
              onPressed: () async {
                String url = '${Constants.BASE_URL}${data["url"]}';
                // _exportDownload(context, url, attendance);
                try {
                  await launch(url);
                } on Exception catch (e) {
                  // TODO
                  print("Could not launch share");
                  print(e);
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    } on HTTPException catch (error) {
      http.Response response = error.response;
      print(response.body);
      if (error.status == 500) {
        DialogMaster.MyshowDialog(
            context, "Server Error", "Something went wrong on the server");
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        DialogMaster.MyshowDialog(context, "Oops", data['message']);
      }

      return null;
    } on IOException catch (error) {
      DialogMaster.MyshowDialog(
          context, "Authentication Failed", "Please login", onCloseClick: () {
        Navigator.of(context).pushReplacementNamed("/lecturer-login");
      });
    } finally {

    }
  }

}
