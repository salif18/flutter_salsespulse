import 'dart:async';
import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
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
  DateTime? selectedDate;
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

        if (!_streamController.isClosed) {
          _streamController.add(products); // Ajouter les produits au stream
        }
      } else {
        if (!_streamController.isClosed) {
          _streamController.addError("Failed to load products");
        }
      }
    } catch (e) {
      if (!_streamController.isClosed) {
        _streamController.addError("Error loading products");
      }
    }
  }

  //rafraichire la page en actualisanst la requete
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Vérifier si le widget est monté avant d'appeler setState()
      setState(() {
        _loadProducts(); // Rafraîchir les produits
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //benefice total
    beneficeTotal() {
      if (filteredArticles.isEmpty) return 0;
      return filteredArticles
          .map((article) =>
              (article.prixVente - article.prixAchat) * article.qty)
          .reduce((a, b) => a + b);
    }

    //quantite total de produit
    int nombreTotalDeProduit() {
      if (filteredArticles.isEmpty) return 0;
      return filteredArticles.map((a) => a.qty).reduce((a, b) => a + b);
    }

    //somme total
    //calcule somme total
    sommeTotal() {
      if (filteredArticles.isEmpty) return 0;
      return filteredArticles
          .map((x) => x.prixVente * x.qty)
          .reduce((a, b) => a + b);
    }

    return Scaffold(
      key: drawerKey,
      backgroundColor: const Color(0xfff0f1f5),
      body: RefreshIndicator(
        backgroundColor: Colors.transparent,
        color: Colors.grey[100],
        onRefresh: _refresh,
        displacement: 50,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xff001c30),
              expandedHeight: 100,
              pinned: true,
              floating: true,
              leading: IconButton(
                  onPressed: () {
                    drawerKey.currentState!.openDrawer();
                  },
                  icon: Icon(Icons.sort,
                      size: AppSizes.iconHyperLarge, color: Colors.white)),
              flexibleSpace: FlexibleSpaceBar(
                title: Text("Rapports",
                    style: GoogleFonts.roboto(
                        fontSize: AppSizes.fontLarge, color: Colors.white)),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xff001c30),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        constraints:
                            const BoxConstraints(maxWidth: 250, minHeight: 20),
                        child: DateTimeFormField(
                          decoration: InputDecoration(
                            hintText: 'Choisir pour une date',
                            hintStyle: GoogleFonts.roboto(
                                fontSize: 14, color: Colors.white),
                            fillColor: Color.fromARGB(255, 255, 136, 0),
                            // Color.fromARGB(255, 82, 119, 175),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 28),
                          ),
                          hideDefaultSuffixIcon: true,
                          mode: DateTimeFieldPickerMode.date,
                          initialValue: null,
                          onChanged: (DateTime? value) {
                            if (value != null) {
                              setState(() {
                                selectedDate = value;
                              });
                            }
                          },
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: Colors.white),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StreamBuilder<List<VentesModel>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Erreur de connexion verifier votre réseau : ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucun produit disponible.");
                  } else {
                    final List<VentesModel> articles = snapshot.data!;

                    // Filtrer les articles par la date sélectionnée
                    // Filtrer les articles par la date sélectionnée, sinon afficher tous les articles
                    filteredArticles = selectedDate == null
                        ? articles
                        : articles.where((article) {
                            // Vérifier si `article.dateVente` n'est pas null également
                            if (article.dateVente != null &&
                                selectedDate != null) {
                              return article.dateVente.year ==
                                      selectedDate!.year &&
                                  article.dateVente.month ==
                                      selectedDate!.month &&
                                  article.dateVente.day == selectedDate!.day;
                            }
                            return false;
                          }).toList();

                    if (filteredArticles.isEmpty) {
                      return const Text(
                          "Aucun article trouvé pour la date sélectionnée.");
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 235, 235, 235),
                        ),
                        child: DataTable(
                          columnSpacing: 1,
                          columns: [
                             
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                  color: Colors.orange,
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width,
                                  
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Name",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Categories",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Prix d'achat",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Prix de vente",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Quantités",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Somme",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Container(
                                   color: Colors.orange,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    "Benefices",
                                    style: GoogleFonts.roboto(
                                      fontSize: AppSizes.fontMedium,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white,
                                    ),
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
                                      "${article.prixAchat.toStringAsFixed(2)} XOF",
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
                                      "${article.prixVente.toStringAsFixed(2)} XOF",
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
                                      "${somme.toStringAsFixed(2)} XOF",
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
                                      "${benefices.toStringAsFixed(2)} XOF",
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          height: 150,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 248, 248),
              border: Border.all(
                  width: 1, color: const Color.fromARGB(255, 207, 212, 233))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Rapport du",
                        style:
                            GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                          selectedDate != null
                              ? DateFormat("dd MMM yyyy").format(selectedDate!)
                              : 'general',
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium)),
                    ),
                    IconButton(
                      onPressed: () {
                        _printReceipt(context, filteredArticles);
                      },
                      icon: const Icon(Icons.print, size: AppSizes.iconLarge),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.40,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Produit ",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(nombreTotalDeProduit().toString(),
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.40,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Total",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("${sommeTotal().toString()} XOF",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.40,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Benefices",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("${beneficeTotal().toString()} XOF",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _printReceipt(
      BuildContext context, List<VentesModel> rapport) async {
    final pdf = pw.Document();
    final store = Provider.of<AuthProvider>(context, listen: false).societeName;
    final date = DateFormat("dd MMM yyyy").format(selectedDate!);

    //somme total
    //calcule somme total
    sommeTotal() {
      if (rapport.isEmpty) return 0;
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
              pw.Text("Rapport du: $date",
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
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
