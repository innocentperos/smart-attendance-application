
import 'dart:convert';
import '../models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:http/http.dart' as http;
class Course {
  final String title, code;
  final int attendances, _id;

  Course(this._id,{this.title, this.code, this.attendances, });

  factory Course.fromMap(Map<String, dynamic> json){
    return Course(json['id'],title:json['title'], code:json['code'], attendances:json['attendances']);
  }
  int get id {
    return this._id;
}
  static Resource<List<Course>> get all{

    return Resource(
        url :'${Constants.ACCESS_POINT}/course-view',
        parse: (response) {
          final result = json.decode(response.body);
          Iterable list = result;
          return list.map((model)=>Course.fromMap(model)).toList();
        }
    );
  }
}
