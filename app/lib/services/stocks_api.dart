
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:salespulse/https/domaine.dart';

   const String domaineName = Domaine.domaineURI;

class ServicesStocks{
  Dio dio = Dio();
  //ajouter depense
  postNewProduct(data, token) async {
    var uri = "$domaineName/products";
    return await dio.post(
      uri,
      data: data,
      options: Options(headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer $token"
      },)
    );
  }

  //ajouter depense
  updateProduct(data,token, id) async {
    var uri = "$domaineName/products/single/$id";
    return await dio.put(
      uri,
      data: data,
      options: Options(headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
         "Authorization": "Bearer $token"
      },)
    );
  }

  //obtenir depenses
  getAllProducts(token,userId) async {
    var uri = "$domaineName/products/$userId";
    return await http.get(
      Uri.parse(uri),
     headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer $token"
      });
  }



  //delete
  deleteProduct(id,token) async {
    var uri = "$domaineName/products/single/$id";
    return await http.delete(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer $token"
      },
    );
  }

  //messade d'affichage de reponse de la requette recus
  void showSnackBarSuccessPersonalized(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w400)),
      backgroundColor:const Color.fromARGB(255, 101, 255, 122),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    ));
  }

//messade d'affichage des reponse de la requette en cas dechec
  void showSnackBarErrorPersonalized(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.roboto(fontSize: 16,fontWeight: FontWeight.w400)),
      backgroundColor: const Color.fromARGB(255, 255, 35, 19),
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
