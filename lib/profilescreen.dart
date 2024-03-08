import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'model/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String birth = "Date of birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void pickUploadPP() async {
    final image =await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 512, maxWidth: 512, imageQuality: 90,);
    Reference ref = FirebaseStorage.instance
        .ref().child("${User.EmployeeId.toLowerCase()}_profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePicLink = value;
      });

      await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
        'profilePic': value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body:SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap:  () {
                pickUploadPP();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink ==" " ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 80,
                  ): ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(User.profilePicLink)),

                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
                child:Text("Employee ${User.EmployeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18
                ),),),
            const SizedBox(height: 24,),
            User.conEdit ? textFeild("First Name", "First name", firstNameController): field("First Name", User.firstName),
            User.conEdit ? textFeild("Last Name", "Last name", lastNameController): field("Last Name", User.lastName),

            User.conEdit ? GestureDetector(
              onTap: (){
                showDatePicker(context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
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
                ).then((value) {
                  setState(() {
                    birth = DateFormat("MM/dd/yyyy").format(value!);
                  });
                });
              },
              child: field("Date Of Birth", birth),
            ): field("Date Of Birth", User.birthDate),
            User.conEdit ? textFeild("Address", "Address", addressController) : field("Address", User.address),
            User.conEdit ? GestureDetector(
              onTap: () async {
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String birthDate = birth;
                String address = addressController.text;
                if(User.conEdit) {
                  if(firstName.isEmpty){
                    showSnackBar("Please enter your First name!");
                  } else if(lastName.isEmpty){
                    showSnackBar("Please enter your Last name!");
                  }  else if(birthDate.isEmpty){
                    showSnackBar("Please enter your Birth Date!");
                  } else if(address.isEmpty) {
                    showSnackBar("Please enter your Address!");
                  } else{
                    await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
                      'firstName': firstName,
                      'lastName': lastName,
                      'birthDate': birthDate,
                      'address': address,
                      'canEdit': false,
                    }).then((value) {
                      setState(() {
                        User.conEdit = false;
                        User.firstName = firstName;
                        User.lastName = lastName;
                        User.birthDate = birthDate;
                        User.address = address;
                      });
                    });

                  }
                } else {
                  showSnackBar("You Cannot edit details Anymore, please contact Support");
                }

              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: const  Center(
                child: Text(
                  "SAVE",
                  style:  TextStyle(
                    color: Colors.white,
                    fontFamily: "NexaBold",
                    fontSize: 16,
                  ),
                ),
              ),
              ),
            ) :const SizedBox(),

          ],
        ),
      )
    );
  }
  Widget field(String title, String text){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style:const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.black54,
              )
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child:  Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget textFeild(String title, String hint, TextEditingController controller){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style:const  TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
                  hintStyle: const TextStyle(
                color: Colors.black54,
              fontFamily: "NexaBold"
            ), enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54,
              ),
            ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black54,
                ),
              )
            ),
          ),
        ),
      ],
    );
  }
  void showSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar( behavior: SnackBarBehavior.floating, content: Text(text,),),);
  }
}
