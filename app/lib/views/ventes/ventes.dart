import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/models/ventes_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/services/vente_api.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/populaires/populaire_view.dart';

class VenteView extends StatefulWidget {
  const VenteView({super.key});

  @override
  State<VenteView> createState() => _VenteViewState();
}

class _VenteViewState extends State<VenteView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  ServicesVentes api = ServicesVentes();

  final StreamController<List<VentesModel>> _streamController =
      StreamController();

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

  //rafraichire la page en actualisanst la requete
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Vérifie que le widget est toujours monté avant de mettre à jour l'état
      setState(() {
        _loadProducts();
      });
    }
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
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
        } else {
          print("StreamController is closed, cannot add products.");
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

  Future<void> _removeArticles(article) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final res = await api.deleteVentes(article.venteId, token);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        api.showSnackBarSuccessPersonalized(context, body["message"]);
      } else {
        // ignore: use_build_context_synchronously
        api.showSnackBarErrorPersonalized(context, body["message"]);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      api.showSnackBarErrorPersonalized(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f1f5),
      appBar: AppBarWidget(
        title: "Liste des ventes",
        color: const Color(0xff001c30),
        titleColore: Colors.white,
        drawerkey: drawerKey,
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.transparent,
        color: Colors.grey[100],
        onRefresh: _refresh,
        displacement: 50,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                color: const Color(0xff001c30),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Image.asset(
                    //     "assets/logos/logo3.jpg",
                    //     width: 100,
                    //     height: 100,
                    //   ),
                    // ),
                    IconButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const PopulaireView()));
                    }, 
                    color: Colors.orange,
                    tooltip: "Les plus achetés",
                    icon: const Icon(Icons.workspace_premium, size:35)
                    )
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
                            // DataColumn(
                            //   label: Container(
                            //     padding: const EdgeInsets.all(5),
                            //     child: Text(
                            //       "Photo",
                            //       style: GoogleFonts.roboto(
                            //         fontSize: AppSizes.fontMedium,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                  "Date",
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
                                  "Actions",
                                  style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: articles.map((article) {
                            return DataRow(
                              cells: [
                                // DataCell(
                                //   Container(
                                //     padding: const EdgeInsets.all(5),
                                //     child: article.image.isEmpty
                                //         ? Image.asset(
                                //             "assets/images/defaultImg.png",
                                //             width: 50,
                                //             height: 50,
                                //           )
                                //         : Image.network(
                                //             article.image,
                                //             width: 50,
                                //             height: 50,
                                //           ),
                                //   ),
                                // ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      article.nom,
                                      style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontSmall,
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
                                        fontSize: AppSizes.fontSmall,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      "${article.prixVente} XOF",
                                      style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontSmall,
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
                                        fontSize: AppSizes.fontSmall,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      DateFormat("dd MMM yyyy")
                                          .format(article.dateVente),
                                      style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontSmall,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Annuler",
                                          style: GoogleFonts.roboto(
                                              fontSize: AppSizes.fontSmall,
                                              color: Colors.blue),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.move_down_outlined,
                                              color: Colors.blue),
                                          onPressed: () {
                                            _showAlertDelete(context, article);
                                          },
                                        ),
                                      ],
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showAlertDelete(BuildContext context, article) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Annulation de vente"),
          content: const Text(
              "Êtes-vous sûr de vouloir annuler la vente et retourner cet article dans vos stocks ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => _removeArticles(article),
              child: const Text("Valider"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Quitter"),
            ),
          ],
        );
      },
    );
  }
}
