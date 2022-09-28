
import 'dart:convert';

import 'package:smart_attendance/models/Attendance.dart';
import 'package:smart_attendance/models/webservice.dart';

import '../utils.dart';

class AttendanceItem{
  final String date, datetime, matricNumber;
  final int _id;
  final double lat, long;

  // ['id',
  // 'attendance',
  // 'datetime',
  // 'lat'
  // ,'long',
  // 'commit',
  // 'matric_number',
  // 'attendance_image',
  // 'date']
  AttendanceItem(this._id, this.matricNumber,{this.date,this.datetime, this.lat=0.0, this.long=0.0 });


  factory AttendanceItem.fromMap(Map<String, dynamic> json){
    print(json);
    return AttendanceItem(json['id'],
        json['matric_number'],
        date:json['date'],
        datetime:json['datetime'],
        lat:double.parse(json['lat']),
        long:double.parse(json['long']));
  }

  int get id {
    return this._id;
  }
 static List<AttendanceItem> fromList(List<dynamic> _list){
    return _list.map((json) => AttendanceItem.fromMap(json)).toList();
 }
  static Resource<List<AttendanceItem>> all(dynamic id){

    return Resource(
        url :'${Constants.ACCESS_POINT}/attendance-view/$id',
        parse: (response) {
          final result = jsonDecode(response.body);
          Iterable list = result;
          return list.map((model)=>AttendanceItem.fromMap(model)).toList();
        }
    );
  }
}