import 'package:flutter/material.dart';

class DialogMaster {
  static Future<void> loadingDialog(BuildContext context,
      {String title = "Loading"}){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Center(
          child: Container(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    });
  }
  static Future<void> MyshowDialog(
      BuildContext context, String title, String body,
      {List<Widget> actions,Function onCloseClick}) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {

          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(body)],
              ),
            ),
            actions: (actions != null)
                ? actions
                : [
                    TextButton(
                        onPressed: () {

                          Navigator.of(context).pop();
                          if (onCloseClick != null){
                            onCloseClick();
                          }
                        },
                        child: const Text("Close"))
                  ],
          );
        });
  }
}
