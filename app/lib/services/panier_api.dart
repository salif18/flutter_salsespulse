import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:salespulse/https/domaine.dart';
import 'package:salespulse/utils/app_size.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/providers/panier_provider.dart';

const String domaineName = Domaine.domaineURI;

class ServicesPanier {
  Dio dio = Dio();
  //AJOUTER DES COMMANDES
  Future<Response> postOrders(Map<String, dynamic> data, String token) async {
    var uri = "$domaineName/ventes";
    return await dio.post(
      uri,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  //OBTENIR COMMANDES PAR USER
  getUserOrders(userId) async {
    var uri = "$domaineName/orders/$userId";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR TOUS LES COMMANDES
  getAllOrders() async {
    var uri = "$domaineName/orders";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR TOUS LES COMMANDES LIVRER
  getAllOrdersyDelivery() async {
    var uri = "$domaineName/orders/delibery";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

//OBTENIR UN SEUL ARTICLE
  getOneProduct(data) async {
    var uri = "$domaineName/orders/{}";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //MIS A JOURS DU STATUT DE LIVRAISON
  updateStatutOrders(data) async {
    var uri = "$domaineName/orders/statut/{}";
    return await http.put(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //SUPPRIMER UNE COMMANDE
  deleteOrder(data) async {
    var uri = "$domaineName/orders/{}";
    return await http.delete(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

//OBTENIR LES COORDONNEES DE LOCALISATION DUNE COMMANDE
  getOneOrderPositions(id) async {
    var uri = "$domaineName/orders/positions/$id";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

//AJOUTER UN LIVREUR AU COMMANDES
  postLiveryIdToOrders(data, id) async {
    var uri = "$domaineName/orders/livreurId/$id";
    return await http.put(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR COMMANDES PAR USER
  updateOrderPositions(data, id) async {
    var uri = "$domaineName/orders/positions/$id";
    return await http.put(
      Uri.parse(uri),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR COMMANDES LIVRER PAR LIVREUR
  getDeliveryOrdersLivrer(userId) async {
    var uri = "$domaineName/orders/livrer/$userId";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR COMMANDES EN ATTENTE
  getAllOrdersEnCours() async {
    var uri = "$domaineName/orders/status/En attente";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //OBTENIR COMMANDES LIVRER
  getAllOrdersLivrer() async {
    var uri = "$domaineName/orders/status/Livrer";
    return await http.get(
      Uri.parse(uri),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
      },
    );
  }

  //message en cas de succès!
  Future<void> showSnackBarSuccessPersonalized(
      BuildContext context, String message) {
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une réception'),
          content: Text(
            message,
            style: GoogleFonts.aBeeZee(
                fontSize: AppSizes.fontLarge, color: Colors.green),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                panierProvider.clearCart();
                Navigator.of(context).pop();
              },
              child: const Text('Retour'),
            ),
            IconButton(
                onPressed: () {
                  _printReceipt(context);
                },
                icon: const Icon(
                  Icons.print_rounded,
                  size: AppSizes.iconLarge,
                  color: Colors.blue,
                ))
          ],
        );
      },
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final pdf = pw.Document();
    // Utiliser Consumer pour récupérer les données du panier
    final store = Provider.of<AuthProvider>(context, listen: false).societeName;
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);
    final panier = panierProvider.myCart;
    int total = panierProvider.total;
    final now = DateTime.now();
    final date = DateFormat("dd MMM yyyy").format(now);

    // final String date = "2024-09-09";
    // Ajouter les détails du reçu au PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(store,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Date: $date", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text("Détails du reçu :",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ['Produit', 'Prix Unitaire', 'Quantité', 'Somme'],
                data: panier.map((product) {
                  return [
                    product.nom,
                    "${product.prixVente} \$",
                    "${product.qty}",
                    "$total \$"
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text(
                "Total: $total \$",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    // Utiliser le package `printing` pour imprimer ou sauvegarder le PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        // Sauvegarder le PDF
        final pdfFile = pdf.save();
        // Effacer le panier après la sauvegarde
        panierProvider.clearCart();
        return pdfFile;
      },
    );
  }

  //message en cas d'erreur!
  void showSnackBarErrorPersonalized(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400)),
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
