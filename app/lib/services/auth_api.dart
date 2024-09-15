import "dart:convert";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "package:http/http.dart" as http;
import 'package:dio/dio.dart';
import "package:salespulse/https/domaine.dart";


 const String domaineName = Domaine.domaineURI;

class ServicesAuth{
  Dio dio = Dio();
  // fonction de connection
  postLoginUser(data)async{
    var url = "$domaineName/auth/login";
    return await http.post(Uri.parse(url), 
    body:jsonEncode(data), 
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
    });
  }

// fonction de creation de compte
  postRegistreUser(data)async{
     var url = "$domaineName/auth/signup";
      return await http.post(Uri.parse(url), 
    body:jsonEncode(data), 
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
    });
  
  }

//fontion de modification de passeword
  postUpdateUser(data,token, userId) async {
    var uri = "$domaineName/auth/update_user/$userId";
    return await http.post(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer $token"
      },
    );
  }
 
  //fontion de modification de passeword
  postUpdatePassword(data,token, userId) async {
    var uri = "$domaineName/auth/update_password/$userId";
    return await http.post(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer $token"
      },
    );
  }

  //fontion de reinitialisation de password
  postResetPassword(data) async {
    var uri = "$domaineName/reset/reset_token";
    return await http.post(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //fontion de validation de mot de password reinitialiser
  postValidatePassword(data) async {
    var uri = "$domaineName/reset/reset_valid";
    return await http.post(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }


  //message en cas de succès!
  void showSnackBarSuccessPersonalized(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w400)),
      backgroundColor: Color.fromARGB(255, 255, 157, 11),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: "",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

   //message en cas d'erreur!
  void showSnackBarErrorPersonalized(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400)),
      backgroundColor: const Color.fromARGB(255, 32, 19, 54),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: "",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}