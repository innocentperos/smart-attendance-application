import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_attendance/models/Attendance.dart';
import 'package:smart_attendance/models/attendance_item.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/utils/http_service.dart';
import 'package:smart_attendance/utils/exporter.dart';

import 'package:smart_attendance/widgets/dialog_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_extend/share_extend.dart';

class AttendanceViewer extends StatefulWidget {
  @override
  _AttendanceViewerState createState() => _AttendanceViewerState();
}

class _AttendanceViewerState extends State<AttendanceViewer> {
  @override
  List<AttendanceItem> _attendances;
  bool _exporting = false;

  Widget build(BuildContext context) {
    final Attendance _attendance =
        ModalRoute.of(context).settings.arguments as Attendance;
    return Scaffold(
      appBar: AppBar(
        title: Text("Course attendance"),
      ),
      floatingActionButton: FloatingActionButton(
        child: (!_exporting)
            ? Icon(Icons.import_export)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
        onPressed: () async {
          if (!_exporting) {
            setState(() {
              _exporting = true;
            });
            try {
              File file = await Exporter.exportAttendance(_attendance, context);
              setState(() {
                _exporting = false;
              });
              ShareExtend.share(file.path, "application/xlsx");

            } on Exception catch (e) {
              // TODO
              DialogMaster.MyshowDialog(context, "Error Exporting", "Could not export list");
            }
          }
        },
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _loadList(context, _attendance),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              _attendances = snapshot.data;

              if (_attendances == null) {
                return Center(
                  child: Text("Nothing to present"),
                );
              } else {
                return ListView.builder(
                    itemCount: _attendances.length + 1,
                    itemBuilder: (context, pos) {
                      if (pos == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Student List'),
                        );
                      }
                      AttendanceItem studentAttendance = _attendances[pos - 1];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              studentAttendance.matricNumber,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          )
                        ],
                      );
                    });
              }
            }
          },
        ),
      ),
    );
  }

  Future<dynamic> _loadList(BuildContext context, Attendance attendance) async {
    print("Loading list");
    try {
      HttpService service = await HttpService.getInstance();
      http.Response response = await service
          .get("/attendance-view/${attendance.id}/attendance_list");
      List<dynamic> data = jsonDecode(response.body);
      print("Attendance List --------------------");
      List<AttendanceItem> attendanceList = AttendanceItem.fromList(data);

      return attendanceList;
    } on HTTPException catch (e) {
      if (e.status == 500) {
        DialogMaster.MyshowDialog(
          context,
          "Server Error",
          "Something went wrong on the server, please try again later",
          onCloseClick: () {
            Navigator.of(context).pop();
          },
        );
      } else {
        Map<String, dynamic> data = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Oops", data['message'],
            onCloseClick: () {
          Navigator.of(context).pop();
        });
      }
      return null;
    } catch (e) {
      print(e);
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
      setState(() {
        _exporting = false;
      });
    }
  }

  Future<void> _exportDownload(
      BuildContext context, String url, Attendance attendance) async {
    try {
      String token = await FileHandler.instance.readToken();
      http.Response response = await http.get(Uri.parse(url), headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json"
      });

      if (response.statusCode.toString().startsWith("2")) {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;

        File file = new File(
            "$tempPath/${attendance.courseCode}-${attendance.date.split(';')[0]}.xlsx");
        await file.writeAsBytes(response.bodyBytes);
        if (Platform.isAndroid) {
          Directory public = await getExternalStorageDirectory();
          print(public.parent);
          String copyPath = public.parent.parent.parent.parent.path +
              "/download/${file.path.split('/')[file.path.split('/').length - 1]}";
          await file.copy(copyPath);
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<bool> _requestPermission() async {}
}
