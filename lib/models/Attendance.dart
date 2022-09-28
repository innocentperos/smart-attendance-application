import 'dart:convert';
import '../models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:http/http.dart' as http;

import 'course.dart';

class Attendance {
  final String date, datetime, courseTitle, courseCode;

  final int _id;
  final double lat, long;
  final bool isOpen, isCommitted;
  final int attendances;

  // ['id','course','datetime','lat','long','code','is_open','commit','attendances']

  Attendance(
    this._id, {
    this.date,
    this.datetime,
    this.courseCode,
    this.courseTitle,
    this.lat = 0.0,
    this.long = 0.0,
    this.attendances = 0,
    this.isOpen = false,
    this.isCommitted = false,
  });

  factory Attendance.fromMap(Map<String, dynamic> json) {

    return Attendance(json['id'],
        date: json['date'],
        datetime: json['datetime'],
        lat: double.parse(json['lat']),
        long: double.parse(json['long']),
        attendances: json['attendances'],
        isOpen: json['is_open'],
        isCommitted: json['commit'],
        courseTitle:
            json.containsKey("course_title") ? json['course_title'] : '',
        courseCode:
            json.containsKey("course_code") ? json['course_code'] : "");
  }

  int get id {
    return this._id;
  }

  static Resource<List<Attendance>> all(Course course) {
    return Resource(
        url:
            '${Constants.ACCESS_POINT}/attendance-view/${course.id}/attendances',
        parse: (response) {
          final result = json.decode(response.body);
          Iterable list = result;
          return list.map((model) => Attendance.fromMap(model)).toList();
        });
  }
}
