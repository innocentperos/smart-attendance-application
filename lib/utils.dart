

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHandler{

  FileHandler._privateConstructor();

  static final FileHandler instance = FileHandler._privateConstructor();

  static File _file;

  static final String _fileName = "user_data.enp";

  Future<File> get file async{
    if ( _file != null ) return _file;
    _file = await _initFile();

    return _file;
  }

  Future<File> _initFile() async {
    final _directory = await getApplicationDocumentsDirectory();
    final _path = _directory.path;
    return File('$_path/$_fileName');
  }

  Future<void> writeToken(String token) async {
    final File f1 = await file;

    // final  obj = <String, String>{
    //   'token':token
    // };

    await f1.writeAsString(token);
  }

  Future<String> readToken() async{
    final File f1 = await file;

    final data = await f1.readAsString();

    return data;
  }
}

class Constants{
  static const String BASE_URL = "https://jj-smart-attendance.herokuapp.com";

  static const String ACCESS_POINT = "$BASE_URL/api";

}