import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'model/user.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String _month = DateFormat('MMMM').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin:const  EdgeInsets.only(top: 32),
                child: Text("My Attendance",style: TextStyle(
                  fontFamily: "NexaBold", fontSize: screenWidth/18,),
                ),
              ),

              Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin:const  EdgeInsets.only(top: 32),
                    child: Text(_month ,style: TextStyle(
                      fontFamily: "NexaBold", fontSize: screenWidth/18,),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin:const  EdgeInsets.only(top: 32),
                    child: GestureDetector(
                      onTap: ()async {
                        final month = await showMonthYearPicker(context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2099),
                        builder: (context, child){
                          return Theme(data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light( primary: primary, secondary:primary, onSecondary: Colors.white,),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(foregroundColor: primary),
                            ),
                            textTheme: const TextTheme(
                              headline4: TextStyle(fontFamily: "NexaBold",),
                              overline: TextStyle(fontFamily: "NexaBold"),
                              button: TextStyle(fontFamily: "NexaBold"),
                            ),
                          ),
                            child: child!,

                          );
                        }
                        );
                        if (month != null){
                          setState(() {
                            _month =DateFormat('MMMM').format(month);
                          });
                        }
                      },
                      child: Text("Pick a Month",style: TextStyle(
                      fontFamily: "NexaBold", fontSize: screenWidth/18,),
                    ),
                  ),
                  ),
                ],
              ),
              Container(
                height: screenHeight /1.45,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("Employee").doc(User.id)
                      .collection("Record").snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(snapshot.hasData){
                      final snap = snapshot.data!.docs;
                      return ListView.builder(itemCount: snap.length , itemBuilder: (context, index){
                        return DateFormat('MMMM').format(snap[index]['date'].toDate()) ==_month ? Container(
                          margin: EdgeInsets.only(top: index> 0? 12:0 , left: 6, right: 6,),
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              )
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(23)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:  [
                              Expanded(child: Container(margin: const EdgeInsets.all(10), decoration: BoxDecoration(
                                color: primary, borderRadius:const  BorderRadius.all(Radius.circular(20))
                              ),
                              child: Center(
                                child: Text(
                                  DateFormat('EE\ dd').format(snap[index]['date'].toDate()), style :TextStyle(fontFamily: "NexaBold",
                                  color: Colors.white, fontSize: screenWidth/18, ),

                                ),
                              ),)),
                              Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [Text("Check In", style: TextStyle(fontFamily: "NexaRegular",
                                      color: Colors.black54, fontSize: screenWidth/20, ),), Text(snap[index]['CheckIn'] ,style: TextStyle(fontFamily: "NexaBold",
                                      fontSize: screenWidth/18,),),],)),
                              SizedBox(width: screenWidth/10,),
                              Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [Text("Check Out" ,style: TextStyle(fontFamily: "NexaRegular",
                                      color: Colors.black54, fontSize: screenWidth/20, ),), Text(snap[index]['CheckOut'], style: TextStyle(fontFamily: "NexaBold",
                                      fontSize: screenWidth/18,),),],)),
                              SizedBox(width: screenWidth/25,),
                            ],
                          ),
                        ): const SizedBox();

                      },);
                    } else{
                      return const SizedBox();

                    }
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}
