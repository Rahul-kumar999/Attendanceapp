import 'package:attendence/calenderscreen.dart';
import 'package:attendence/model/user.dart';
import 'package:attendence/profilescreen.dart';
import 'package:attendence/services/location_service.dart';
import 'package:attendence/todayscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;


  Color primary = const Color(0xffeef444c);
  int currentIndex = 1;
  List<IconData> navigationIcons =[
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];
  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }
  void _getProfilePic() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
    setState(() {
      User.profilePicLink = doc['profilePic'];
    });
  }
  void _getCredentials() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User.id).get();
      setState(() {
        User.conEdit = doc['canEdit'];
        User.firstName = doc['firstName'];
        User.lastName = doc['lastName'];
        User.birthDate = doc['birthDate'];
        User.address = doc['address'];
      });
    } catch(e) {
      return;
    }
  }
  
  void _startLocationService()async {
    LocationService().initialize();
    LocationService().getLongitude().then((value){
      setState(() {
        User.long = value!;
      });
      LocationService().getLatitude().then((value){
        setState(() {
          User.long = value!;
        });
      });
    });

  }
  Future <void> getId() async{
    QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee").
    where('id', isEqualTo: User.EmployeeId).get();
    setState(() {
      User.id =snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children:  [
          new CalenderScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: EdgeInsets.only(left: 12, right: 12, bottom: 24,),
        decoration:  const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow:[BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(2,2),
          ),],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i =0; i<navigationIcons.length; i++)...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      width: screenWidth,height: screenHeight,color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(navigationIcons[i], color: i == currentIndex ? primary: Colors.black54,
                            size: i == currentIndex ? 30:26,),
                            i == currentIndex ? Container(margin: EdgeInsets.only(top: 6),
                              height: 3,
                              width: 22,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius:const BorderRadius.all(Radius.circular(40)),
                              ),
                            )  :const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              }

            ],
          ),
        ),

      ),
    );
  }
}
