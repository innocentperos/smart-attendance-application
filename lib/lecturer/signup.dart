import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/utils.dart';
import 'package:smart_attendance/widgets/dialog_alert.dart';

Future<http.Response> signup_request (String email, String password){

  print("${Constants.ACCESS_POINT}/lecturer-view/signup/");
  return http.post(
    Uri.parse("${Constants.ACCESS_POINT}/lecturer-view/signup/"),
    headers: <String, String>{
      'Content-Type': 'application/json'
    },
    body: jsonEncode(<String, String>{
      'email':email,
      'password': password
    })
  );
}


class SignupLecturer extends StatefulWidget {
  @override
  _SignupLecturerState createState() => _SignupLecturerState();
}

class _SignupLecturerState extends State<SignupLecturer> {

  String email ='';
  String password ='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                    child: Text("Lecturer Registration", style: TextStyle(
                        fontSize: 24
                    ),),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Email Address"
                  ),
                  onChanged: (value){
                    this.email = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Password"
                  ),
                  onChanged: (value){
                      this.password = value;
                  },
                ),
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Register"),
                    ),
                    onPressed:  () async{
                      if ( email.trim().isEmpty || password.trim().isEmpty){
                        DialogMaster.MyshowDialog(context, "Missing Required Field", "Please provide an email address and password");
                        return;
                      }
                      DialogMaster.loadingDialog(context);

                      signup_request(this.email, this.password).then((response) {
                        Navigator.of(context).pop();
                        if ( response.body !=''){
                          final Map<String, dynamic> res = jsonDecode(response.body);

                          switch(response.statusCode){
                            case 200:
                              FileHandler.instance.writeToken(res['session']).then((value){
                                print("session stored");
                                 FileHandler.instance.readToken().then((value) {
                                  print(value);
                                });
                                 DialogMaster.MyshowDialog(context, "Registration success", "your rgistration was successful",actions:[
                                   TextButton(onPressed: (){
                                     Navigator.of(context).pop();
                                     Navigator.of(context).pushNamed("/lecturer-home");

                                   }, child: Text("Close"))
                                 ]);
                              }, onError: (error){
                                print("error signing in");
                                print(error);
                              });
                              break;
                            default:
                              print(response.statusCode);
                              print(response.body);
                          }
                        }


                      }, onError: (error){
                        DialogMaster.MyshowDialog(context, "Error", "Something wrong, probability a network connection issue");
                      });


                    },

                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top:16),
                  child: ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Login"),
                    ),
                    onPressed: ()=>{
                      Navigator.pushNamed(context, '/lecturer-login')
                    },
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
