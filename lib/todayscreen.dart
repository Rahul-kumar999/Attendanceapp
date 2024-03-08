import 'dart:async';
import 'package:attendence/model/user.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  String CheckIn = "--/--";
  String CheckOut = "--/--";
  String location =" ";
  String scanResult = " ";
  String officeCode = " ";
  Color primary = const Color(0xffeef444c);
  void initState(){
    super.initState();
    _getRecord();
    _getOfficeCode();
  }
  void _getOfficeCode() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection("Attributes").doc("Office1").get();
    setState(() {
      officeCode = snap['code'];
    });
  }

  Future <void> scanQRandCheck() async{
    String result = " ";
    try{
      result = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff" ,"Cancel", false, ScanMode.QR,
      );

    } catch(e){
      print("Error");

    }
    setState(() {
      scanResult =result;
    });
    if(scanResult == officeCode) {
      if(User.lat != 0) {
        _getLocation();

        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection("Employee")
            .where('id', isEqualTo: User.EmployeeId)
            .get();

        DocumentSnapshot snap2 = await FirebaseFirestore.instance
            .collection("Employee")
            .doc(snap.docs[0].id)
            .collection("Record")
            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
            .get();

        try {
          String checkIn = snap2['checkIn'];

          setState(() {
            CheckOut = DateFormat('hh:mm').format(DateTime.now());
          });

          await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .update({
            'date': Timestamp.now(),
            'checkIn': checkIn,
            'checkOut': DateFormat('hh:mm').format(DateTime.now()),
            'checkInLocation': location,
          });
        } catch (e) {
          setState(() {
            CheckIn = DateFormat('hh:mm').format(DateTime.now());
          });

          await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .set({
            'date': Timestamp.now(),
            'checkIn': DateFormat('hh:mm').format(DateTime.now()),
            'checkOut': "--/--",
            'checkOutLocation': location,
          });
        }
      } else {
        Timer(const Duration(seconds: 3), () async {
          _getLocation();

          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("Employee")
              .where('id', isEqualTo: User.EmployeeId)
              .get();

          DocumentSnapshot snap2 = await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .get();

          try {
            String checkIn = snap2['checkIn'];

            setState(() {
              CheckOut = DateFormat('hh:mm').format(DateTime.now());
            });

            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .update({
              'date': Timestamp.now(),
              'checkIn': checkIn,
              'checkOut': DateFormat('hh:mm').format(DateTime.now()),
              'checkInLocation': location,
            });
          } catch (e) {
            setState(() {
              CheckIn = DateFormat('hh:mm').format(DateTime.now());
            });

            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .set({
              'date': Timestamp.now(),
              'checkIn': DateFormat('hh:mm').format(DateTime.now()),
              'checkOut': "--/--",
              'checkOutLocation': location,
            });
          }
        });
      }
    }
  }
  void _getLocation() async{
    List<Placemark> placemark= await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location = "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode},${placemark[0].country}";
    });
  }
  void  _getRecord() async{
    try{
      QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee")
          .where('id', isEqualTo: User.EmployeeId).get();

      DocumentSnapshot snap2 =await FirebaseFirestore.instance.
      collection("Employee").doc(snap.docs[0].id).collection("Record").doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).get();

      setState(() {
        CheckIn = snap2['CheckIn'];
        CheckOut = snap2['CheckOut'];
      });
    } catch(e){
      setState(() {
        CheckIn = "--/--";
        CheckOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin:const  EdgeInsets.only(top: 32),
                child: Text("Welcome",style: TextStyle(color: Colors.black54,
                  fontFamily: "NexaRegular", fontSize: screenWidth/20,),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 9),
                child: Text("Employee " + User.EmployeeId ,style: TextStyle(
                  fontFamily: "NexaBold", fontSize: screenWidth/18,),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 32),
                child: Text("Today's Status",style: TextStyle(
                  fontFamily: "NexaBold", fontSize: screenWidth/20,),
                ),
              ),
              Container(
                margin:  EdgeInsets.only(top: 12, bottom: 32),
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
                     Container(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [Text("Check In", style: TextStyle(fontFamily: "NexaRegular",
                           color: Colors.black54, fontSize: screenWidth/20, ),), Text(CheckIn ,style: TextStyle(fontFamily: "NexaBold",
                             fontSize: screenWidth/18,),),],)),
                     SizedBox(width: screenWidth/7,),
                     Container(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [Text("Check Out" ,style: TextStyle(fontFamily: "NexaRegular",
                           color: Colors.black54, fontSize: screenWidth/20, ),), Text(CheckOut, style: TextStyle(fontFamily: "NexaBold",
                             fontSize: screenWidth/18,),),],)),
                   ],
                 ),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                        text: DateTime.now().day.toString(), style: TextStyle(color: primary, fontSize: screenWidth/18, fontFamily: "NexaBold",),
                        children: [
                          TextSpan(
                              text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                              style: TextStyle(color: Colors.black, fontSize: screenWidth/20, fontFamily: "NexaBold",)
                          )
                        ]
                    ),
                  )
              ),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: "NexaRegular", fontSize: screenWidth/20, color: Colors.black54,
                      ),
                    ),
                  );
                }
              ),
              CheckOut == "--/--" ? Container(
                margin: const EdgeInsets.only(top: 24, bottom: 12),
                child: Builder(builder: (context) {
                  final GlobalKey<SlideActionState> key = GlobalKey();
                  return SlideAction(
                    text: CheckIn == "--/--" ? "Slide to Check In": "Slide to Check Out",
                    textStyle: TextStyle(color: Colors.black54, fontFamily: "NexaRegular", fontSize: screenWidth/20,),
                    outerColor: Colors.white,
                    innerColor: primary,
                    key: key,
                    onSubmit: ()async {
                      if(User.lat !=0){
                        _getLocation();

                        QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee")
                            .where('id', isEqualTo: User.EmployeeId).get();

                        DocumentSnapshot snap2 =await FirebaseFirestore.instance.
                        collection("Employee").doc(snap.docs[0].id).collection("Record").doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).get();

                        try{

                          String CheckIn = snap2['CheckIn'];
                          setState(() {
                            CheckOut = DateFormat('hh: mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance.collection("Employee").doc(snap.docs[0].id).collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).update({
                            'date': Timestamp.now(),
                            'CheckIn': CheckIn,
                            'CheckOut' : DateFormat('hh: mm').format(DateTime.now()),
                            'checkInLocation' : location,
                          });
                        } catch(e){
                          setState(() {
                            CheckIn = DateFormat('hh: mm').format(DateTime.now());
                          });
                          await FirebaseFirestore.instance.collection("Employee").doc(snap.docs[0].id).collection("Record")
                              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).set({
                            'date': Timestamp.now(),
                            'CheckIn': DateFormat('hh: mm').format(DateTime.now()),
                            'CheckOut' : "--/--",
                            'checkOutLocation' : location,
                          });
                        }
                        key.currentState!.reset();
                      } else{
                        Timer(const Duration(seconds: 3), () async {
                          _getLocation();

                          QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee")
                              .where('id', isEqualTo: User.EmployeeId).get();

                          DocumentSnapshot snap2 =await FirebaseFirestore.instance.
                          collection("Employee").doc(snap.docs[0].id).collection("Record").doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).get();

                          try{

                            String CheckIn = snap2['CheckIn'];
                            setState(() {
                              CheckOut = DateFormat('hh: mm').format(DateTime.now());
                            });
                            await FirebaseFirestore.instance.collection("Employee").doc(snap.docs[0].id).collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).update({
                              'date': Timestamp.now(),
                              'CheckIn': CheckIn,
                              'CheckOut' : DateFormat('hh: mm').format(DateTime.now()),
                              'checkInLocation' : location,
                            });
                          } catch(e){
                            setState(() {
                              CheckIn = DateFormat('hh: mm').format(DateTime.now());
                            });
                            await FirebaseFirestore.instance.collection("Employee").doc(snap.docs[0].id).collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now())).set({
                              'date': Timestamp.now(),
                              'CheckIn': DateFormat('hh: mm').format(DateTime.now()),
                              'CheckOut' : "--/--",
                              'CheckOutLocation' : location,
                            });
                          }
                          key.currentState!.reset();
                        });
                      }
                    },
                  );
                },),
              ): Container(margin:const EdgeInsets.only(top: 32, bottom: 32),
                child: Text("You Have Already Completed This Day!", style: TextStyle(fontFamily: "NexaRegular",
                  color: Colors.black54, fontSize: screenWidth/25, ),), ),
              const SizedBox(height: 30,),
              Text("Location ", style: TextStyle(fontFamily: "NexaBold", fontSize: screenWidth/18 ),),
              location != " " ? Text(location ?? " " ) : const SizedBox(),
              GestureDetector(
                onTap: (){
                  scanQRandCheck();
                },
                child: Container(
                  height: screenWidth / 2,
                  width: screenWidth / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(FontAwesomeIcons.expand, size: 70, color: primary,),
                          Icon(FontAwesomeIcons.camera, size: 25, color: primary,)
                        ],
                      ),
                      Container(margin:const EdgeInsets.only(top: 8,),
                        child: Text(CheckIn == "--/--" ? "Scan To Check In !":"Scan To Check Out !" , style: TextStyle(fontFamily: "NexaRegular",
                          color: Colors.black54, fontSize: screenWidth/25, ),), ),
                    ],
                  ),
                ),
              )

            ],
          ),
        )
    );
  }
}
