import 'package:smart_attendance/models/webservice.dart';
import 'package:smart_attendance/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class RequestPayload<T> {}

class HttpService {
  final String token;
  List<Future> runningRequests;

  HttpService._privateConstructor(this.token);

  static HttpService _instance;

  static Future<HttpService> getInstance() async {
    if (_instance != null) {
      return _instance;
    }
    try {
      String token = await FileHandler.instance.readToken();
      _instance = HttpService._privateConstructor(token);
      return _instance;
    } catch (e) {
      throw e;
    }
  }

  Future<http.Response> get(String url) async {
    try {
      http.Response response = await http.get(
          Uri.parse("${Constants.ACCESS_POINT}$url"),
          headers: {'Authorization': 'Token ${this.token}'});

      if (response.statusCode.toString().startsWith("2")) {
        return response;
      } else {
        throw HTTPException(
            response.statusCode, response, "Something went wrong 2");
      }
    } catch (e) {
      throw e;
    }
  }

  Future<http.Response> post({String url, Map<String, dynamic> data}) async {
    try {
      http.Response response = await http.post(

          Uri.parse("${Constants.ACCESS_POINT}$url"),
          body: data,
          headers: <String, String>{
            'ContentType': 'application/json',
            'Authorization': 'Token $token'
          });

      if (response.statusCode.toString().startsWith("2")) {
        return response;
      } else {
        throw HTTPException(
            response.statusCode, response, "Something went wrong");
      }
    } catch (e) {
      throw e;
    }
  }

  Future<http.Response> postFiles(String url,
      {Map<String, String> data, Map<String, File> files}) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("${Constants.ACCESS_POINT}$url"));
    request.headers['Authorization'] = "Token ${this.token}";

    if (files != null && files.length > 0) {
      files.forEach((fieldName, file) async {
        request.files
            .add(await http.MultipartFile.fromPath(fieldName, file.path));
      });
    }

    if (data != null && data.length > 0) {
      request.fields.addAll(data);
    }

    try {
      http.Response response =
          await http.Response.fromStream(await request.send());

      if (response.statusCode.toString().startsWith("2")) {
        return response;
      } else {
        throw HTTPException(
            response.statusCode, response, "Something went Wrong");
      }
    } catch (error) {
      throw error;
    }
  }
}
