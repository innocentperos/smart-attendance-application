import 'package:http/http.dart' as http;

class Resource<T>{
  final String url;
  T Function(http.Response response) parse;

  Resource({this.url, this.parse});
  Resource.noParser(String _url):
    this.url = _url,
    this.parse = null;

}

class Webservice{

  Future<T> load<T>(Resource<T> resource, String token) async {

    final response = await http.get(Uri.parse(resource.url),
    headers: <String, String>{
      "Authorization" : 'Token $token'
    });
    print("Resource response -----------------------");
    print(resource.url);
    print(response.body);
    if ( response.statusCode.toString().startsWith("2")){

      return resource.parse(response);
    }else{
      throw Exception('Failed to load Data');
    }
  }

  Future<dynamic> post<T>(Resource<T> resource,Map<String, dynamic> data, String token) async{

    final response = await http.post(Uri.parse(resource.url),
        headers: <String, String>{
          "Authorization" : 'Token $token'
        },
      body: data
    );

    print("Call Intecept ++++++++++++++++++++++++++++++++++++++");
    print(response.statusCode);
    print(response.body);
    if ( response.statusCode.toString().startsWith("2")){


      if (resource.parse == null){
        return response;
      }else{
        return resource.parse(response);
      }
    }else{
      throw HTTPException(response.statusCode, response, "Something went wrong with the response");
    }
  }
}

class HTTPException implements Exception {
  final int _status;
  final http.Response _response;
  final String _message;

  HTTPException(this._status, this._response, this._message);

  http.Response get response {
      return this._response;
  }
  int get status {
    return this._status;
  }
  String toString () {
    return _message;
  }

}