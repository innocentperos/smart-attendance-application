# smart_attendance

A Flutter application which is used to take attendance by using face authentication and distance proximity.

This application works by first verifying that the current user is the registed user by using face authentication, after the student has been verified, the phone distance is calculated from the lectures location to determine if the phone is within the lecture hall or not.

The lecture can have multiple courses with each have multiple attendance which can be exported as an excel file.

## Setting Up the Server

The server code is written in python using django web framework

A copy of the server was hosted on heroku with the access url : <https://jj-smart-attendance.herokuapp.com>
To make an instance ot the server

1) clone the server code [Here](https://github.com/innocentperos/smart-attendance-server).
2) Open it in any editor (preferable: VSCODE)
3) Install Python into the system
4) Open the folder on the terminal in vscode, or navigate to the folder on any terminal (command line, bash or powershell)
5) install the required dependances by running the following command in the open terminal

a) pip install -r requirements.txt

b) python manage.py migrate

 c) python manage.py runserver

Note: The current server code uses a heroku postgrel add-on for the database server, so

 change the database engine in the django setting.py to use a database of your choice, as
 the current database settings will not be usable, and the command (b) and (c) will not execute

## Setting up the application project

1) copy the URL the command (c) will return when run successful
Note: Add the Url to the django settings ALLOW_HOST

2) Clone this project to a different folder
3) Open the project folder in Android Studio (with flutter and dart installed and already setup on the system and Android Studio)
4) inside the lib/utils.dart set the BASE_URL to the url you coppied in (6)
 and rebuid the app.

## A build copy has already been provided in the /build directory for quick trial
