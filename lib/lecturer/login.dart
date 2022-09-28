import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/utils.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';

import '../main.dart';

  Future<http.Response> login_request (String email, String password) async{
    try{
      http.Response response = await http.post(
          Uri.parse("${Constants.ACCESS_POINT}/login"),
          headers: <String, String>{
            'Content-Type': 'application/json'
          },
          body: jsonEncode(<String, String>{
            'email':email,
            'password': password
          })
      );
      print(response.statusCode);
      return response;
    }catch(error){
      print("000000000000000000000");
      print(error);
      throw error;
    }
    return null;
  }

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();

}

class _LoginState extends State<Login> {

  String email ="";
  String password = '';
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FileHandler.instance.readToken().then((token) {
      if ( token != ''){
        print("login token: ${token}");
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Logging previous account"),
            content: Container(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });

        get_user_type_request(token).then(
                (response){
              String code = response.statusCode.toString();
              print("response login");
              print(response.body);
              if ( code.startsWith("2")){
                Map<String,dynamic> res = jsonDecode(response.body);

                if ( res['type'] == 'LECTURER'){

                  Navigator.of(context).pushNamed( "/lecturer-home");
                }

              }else{
                print(response.body);
              }
            }, onError: (error){
                  print("login error");
                  print(error);
        }
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage('assets/image.png'),
                    height: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("Lecturer login", style: TextStyle(
                      fontSize: 24
                    ),),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Email Address",
                      border: OutlineInputBorder()
                  ),
                  onChanged: (value){
                    this.email = value;
                  },
                ),
                SizedBox(height: 16,),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Password",
                    border: OutlineInputBorder()
                  ),
                  onChanged: (value){
                    this.password = value;
                  },
                ),
                ElevatedButton(
                  child: !loading ? Text("Login"): CircularProgressIndicator(backgroundColor:Colors.white),
                  onPressed: () async{
                    if (loading) return;

                    if( email.isEmpty || password.isEmpty){
                      DialogMaster.MyshowDialog(context, "Missing Required Field", "Please provide Course Title and Code");
                      return;
                    }
                    setState(() {
                      loading = true;
                    });
                      try{
                        var response = await login_request(email, password);
                        var data = jsonDecode(response.body);

                        String status = (response.statusCode.toString());
                        if ( status.startsWith('2')){
                          await FileHandler.instance.writeToken(data['session']);
                          String session = await FileHandler.instance.readToken();
                          Navigator.pushNamed(context,"/lecturer-home");

                        }else{
                          switch(response.statusCode){
                            case 406:

                          }
                        }
                      }catch(error){
                        print("Something went wrong");
                        print(error);

                      }
                      setState(() {
                        loading = false;
                      });
                  },
                ),
                if(!loading) ElevatedButton(
                  child: Text("Register"),
                  onPressed: ()=>{
                    Navigator.pushNamed(context, '/lecturer-signup')
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
