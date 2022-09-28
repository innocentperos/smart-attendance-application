import 'package:flutter/material.dart';
import 'course_attendance.dart';
import '../models/course.dart';
import '../models/webservice.dart';
import '../utils.dart';

class LecturerCourses extends StatefulWidget {
  @override
  _LecturerCoursesState createState() => _LecturerCoursesState();
}

class _LecturerCoursesState extends State<LecturerCourses> {
  List<Course> _courses = [];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _populateCourses();
  }

  void _populateCourses() {
    FileHandler.instance.readToken().then((token) {
      try {
        Webservice().load(Course.all, token).then((courses) => {
              setState(()  {_courses = courses; loading = false;})

            });
      } catch (error) {

      } finally {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Center(
          child: Container(
              margin: EdgeInsets.all(22),

              child: Text(
                "My Courses",
                style: TextStyle(fontSize: 18),
              ),),
        ),
        _courseListView(context, this._courses, this.loading),
      ],
    )));
  }
  List<Widget> header(){
    if ( loading){
      return [
        CircularProgressIndicator(),
        Text(
        "My Courses",
        style: TextStyle(fontSize: 18),
      )];
    }else{
      return [
        Text(
          "My Courses",
          style: TextStyle(fontSize: 18),
        ),
      ];
    }
  }
  Widget _courseListView(BuildContext context, List<Course> list, loading) {
    if (loading) {
      return SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(),
      );
    } else {
        return _waitAhead(list);
    }
  }

  Widget _waitAhead(List<Course> list) {
    if (list.length<1){
      return Center(
        child: Text("No Courses")
      );
    }
    return Expanded(
      child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/course-attendance", arguments: list[index]);
                  },
                  child: Container(
                    child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(list[index].title,
                                  style: TextStyle(fontSize: 22)),
                              Container(
                                margin: EdgeInsets.only(top: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      list[index].code,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${list[index].attendances} Attendances',
                                      style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
