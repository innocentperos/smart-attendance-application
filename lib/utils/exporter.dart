
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:smart_attendance/models/Attendance.dart';
import 'package:smart_attendance/models/attendance_item.dart';
import 'package:smart_attendance/models/course.dart';
import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:smart_attendance/utils/http_service.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';


class Exporter{

  static Future<File> exportAttendance(Attendance attendance, BuildContext context) async{
    HttpService httpService = await HttpService.getInstance();

    try {
      DialogMaster.loadingDialog(context, title: "Exporting");
      http.Response response  = await httpService.get("/attendance-view/${attendance.id}/attendance_list");
      List<dynamic> data = jsonDecode(response.body);
      List<AttendanceItem> attendanceList = AttendanceItem.fromList(data);

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      CellStyle cellStyle = CellStyle(fontFamily : getFontFamily(FontFamily.Calibri));
      // cellStyle.underline = Underline.Single; // or Underline.Double
      var cell = sheetObject.cell(CellIndex.indexByString("A1"));
      cell.value = 8; // dynamic values support provided;
      cell.cellStyle = cellStyle;

      attendanceList.asMap().forEach((key, att) {
        print(att.matricNumber);
        var cell = sheetObject.cell(CellIndex.indexByString("A${key+1}"));
        cell.value = att.matricNumber; // dynamic values support provided;
        cell.cellStyle = cellStyle;
      });
      excel.rename("Sheet1", 'Attendance of ${attendance.date.split(";")[0]}');
      List<int> bytes = await excel.encode();
      String path = (await getExternalStorageDirectories())[0].path;
      print(await getExternalStorageDirectories());
      String filename = "$path/output.xlsx";
      print(filename);
      File _file =new File(filename);
      _file.writeAsBytes(bytes, flush: true);
      Navigator.of(context).pop();

      return _file;

    } on HTTPException catch (e) {
      // TODO
      print("Network error");
      Navigator.of(context).pop();

      if(e.status == 500){
        DialogMaster.MyshowDialog(context, "Server error", "Something went wrong on the server");
      }else{
        Map<String, dynamic> res = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Oops", res['message']);
      }
      print(e);
    }catch(e){
      Navigator.of(context).pop();
      DialogMaster.MyshowDialog(context, "Network Error", "please make sure your connected to the internet");

    }


  }

  static Future<File> exportAll(Course course, BuildContext context, dynamic mark) async {
    HttpService httpService = await HttpService.getInstance();
    try {

      DialogMaster.loadingDialog(context, title:"exporting");

      http.Response response = await httpService.get("/attendance-view/${course.id}/export_all?mark=$mark");

      Map<String, dynamic> data = jsonDecode(response.body);

      Map<String, dynamic> attendanceSheet= data['attendance_sheet'];
      Map<String, dynamic> scoreSheet= data['score_sheet'];

      print(scoreSheet);

      var excel = Excel.createExcel();

      Sheet excelAttendanceSheet = excel['Sheet1'];
      CellStyle cellStyle = CellStyle(fontFamily : getFontFamily(FontFamily.Calibri));
      // cellStyle.underline = Underline.Single; // or Underline.Double
      attendanceSheet.forEach((key, value) {
        var cell = excelAttendanceSheet.cell(CellIndex.indexByString(key));
        cell.value =value.toString(); // dynamic values support provided;
        cell.cellStyle = cellStyle;
      });
      excel.rename("Sheet1", "Attendance List");

      Sheet excelScoreSheet = excel['Score Sheet'];

      scoreSheet.forEach((key, value) {
        var cell = excelScoreSheet.cell(CellIndex.indexByString(key));
        cell.value =value.toString(); // dynamic values support provided;
        cell.cellStyle = cellStyle;
      });

      List<int> bytes = await excel.encode();
      String path = (await getExternalStorageDirectories())[0].path;
      print(await getExternalStorageDirectories());
      var now = new DateTime.now();
      String date = now.toString().substring(0,10);

      String filename = "$path/output-${date}.xlsx";

      print(filename);
      File _file =new File(filename);
      _file.writeAsBytes(bytes, flush: true);

      Navigator.of(context).pop();
      return _file;

    } on HTTPException catch (e) {
      // TODO
      print("Network error");
      if(e.status == 500){
          DialogMaster.MyshowDialog(context, "Server error", "Something went wrong on the server");
      }else{
        Map<String, dynamic> res = jsonDecode(e.response.body);
        DialogMaster.MyshowDialog(context, "Oops", res['message']);
      }
      print(e);
      Navigator.of(context).pop();

    }catch(e){
      Navigator.of(context).pop();
      DialogMaster.MyshowDialog(context, "Network Error", "please make sure your connected to the internet");

    }

  }

}