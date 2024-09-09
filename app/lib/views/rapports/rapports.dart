import 'dart:async';
import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/models/ventes_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/services/vente_api.dart';
import 'package:salespulse/utils/app_size.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

class RapportView extends StatefulWidget {
  const RapportView({super.key});

  @override
  State<RapportView> createState() => _RapportViewState();
}

class _RapportViewState extends State<RapportView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  DateTime selectedDate = DateTime.now();
  ServicesVentes api = ServicesVentes();
  final StreamController<List<VentesModel>> _streamController =
      StreamController();

  List<VentesModel> filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Charger les produits au démarrage
  }

  @override
  void dispose() {
    _streamController
        .close(); // Fermer le StreamController pour éviter les fuites de mémoire
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await api.getAllVentes(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final products = (body["results"] as List)
            .map((json) => VentesModel.fromJson(json))
            .toList();
        _streamController.add(products); // Ajouter les produits au stream
      } else {
        _streamController.addError("Failed to load products");
      }
    } catch (e) {
      _streamController.addError("Error loading products");
    }
  }

  @override
  Widget build(BuildContext context) {
    //benefice total
    beneficeTotal() {
      return filteredArticles.map((article) {
        return ((article.prixVente - article.prixAchat) * article.qty);
      }).reduce((a, b) => a + b);
    }

    //quantite total de produit
    int nombreTotalDeProduit() {
      return filteredArticles.map((a) => a.qty).reduce((a, b) => a + b);
    }

    //somme total
    //calcule somme total
    sommeTotal() {
      return filteredArticles
          .map((x) => x.prixVente * x.qty)
          .reduce((a, b) => a + b);
    }

    return Scaffold(
      backgroundColor: const Color(0xfff0f1f5),
      appBar: AppBarWidget(
        title: "Les rapports",
        color: const Color(0xff001c30),
        titleColore: Colors.white,
        drawerkey: drawerKey,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color: const Color(0xff001c30),
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/logos/logo3.jpg",
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    constraints:
                        const BoxConstraints(maxWidth: 300, minHeight: 30),
                    child: DateTimeFormField(
                      decoration: InputDecoration(
                        hintText: 'Ajouter une date',
                        hintStyle: GoogleFonts.roboto(fontSize: 20),
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.calendar_month_rounded,
                            color: Color.fromARGB(255, 255, 136, 128),
                            size: 28),
                      ),
                      hideDefaultSuffixIcon: true,
                      mode: DateTimeFieldPickerMode.date,
                      initialValue: DateTime.now(),
                      onChanged: (DateTime? value) {
                        if (value != null) {
                          setState(() {
                            selectedDate = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<VentesModel>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                      "Erreur lors du chargement des produits : ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Aucun produit disponible.");
                } else {
                  final List<VentesModel> articles = snapshot.data!;
                  filteredArticles = articles;
                  // articles.where((article) {
                  //   // Comparer les dates en ignorant l'heure
                  //   return DateFormat("dd MMM yyyy")
                  //           .format(article.dateVente) ==
                  //       DateFormat("dd MMM yyyy").format(selectedDate);
                  // }).toList();
                  // Calculer le bénéfice total

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: DataTable(
                        columnSpacing: 10,
                        columns: [
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Name",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Categories",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Prix d'achat",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Prix de vente",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Quantités",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Somme",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                "Benefices",
                                style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: filteredArticles.map((article) {
                          final somme = article.prixVente * article.qty;
                          final benefices =
                              somme - (article.prixAchat * article.qty);

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    article.nom,
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    article.categories,
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    article.prixAchat.toStringAsFixed(2),
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    article.prixVente.toStringAsFixed(2),
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    article.qty.toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    somme.toStringAsFixed(2),
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    benefices.toStringAsFixed(2),
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
            Container(
                padding: const EdgeInsets.all(8),
                height: 200,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "rapport du",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium),
                          ),
                          Text(DateFormat("dd MMM yyyy").format(selectedDate),
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  color: Colors.red)),
                          IconButton(
                              onPressed: () {
                                _printReceipt(context, filteredArticles);
                              },
                              icon: const Icon(
                                Icons.print,
                                size: AppSizes.iconLarge,
                              ))
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text("Nbr de produit vendue",
                                    style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontMedium))),
                            Text(nombreTotalDeProduit().toString(),
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    color: Colors.red))
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text("Total:",
                                    style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontMedium))),
                            Text("${sommeTotal().toString()} XOF",
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    color: Colors.green))
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text("Benefice",
                                    style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontMedium))),
                            Text("${beneficeTotal().toString()} XOF",
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    color: Colors.blue))
                          ],
                        )
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<void> _printReceipt(
      BuildContext context, List<VentesModel> rapport) async {
    final pdf = pw.Document();
    final store = Provider.of<AuthProvider>(context, listen: false).societeName;
    final date = DateFormat("dd MMM yyyy").format(selectedDate);

    //somme total
    //calcule somme total
    sommeTotal() {
      return rapport.map((x) => x.prixVente * x.qty).reduce((a, b) => a + b);
    }

    // Calculer le bénéfice total
    calculBenefice() {
      return rapport.map((article) {
        return ((article.prixVente - article.prixAchat) * article.qty);
      }).reduce((a, b) => a + b);
    }

    //quantite total de produit
    int nombreTotalDeProduit() {
      return rapport.map((a) => a.qty).reduce((a, b) => a + b);
    }

    // Ajouter les détails du reçu au PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                store,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Rapport du: $date", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'Nom',
                  'Catégorie',
                  'Prix Achat',
                  'Prix Vente',
                  'Quantité',
                  'Total',
                  'Bénéfices'
                ],
                data: rapport.map((article) {
                  final somme = article.prixVente * article.qty;
                  final benefice = somme - (article.prixAchat * article.qty);
                  return [
                    article.nom,
                    article.categories,
                    article.prixAchat.toStringAsFixed(2),
                    article.prixVente.toStringAsFixed(2),
                    article.qty.toString(),
                    somme.toStringAsFixed(2),
                    benefice.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Nombre de produit total: ${nombreTotalDeProduit().toStringAsFixed(2)}",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Somme total: ${sommeTotal().toStringAsFixed(2)} XOF",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Bénéfice total: ${calculBenefice().toStringAsFixed(2)} XOF",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    // Impression ou exportation du PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
