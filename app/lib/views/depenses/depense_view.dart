import 'dart:async';
import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/models/depenses_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/services/depense_api.dart';
import 'package:salespulse/utils/app_size.dart';

class DepensesView extends StatefulWidget {
  const DepensesView({super.key});

  @override
  State<DepensesView> createState() => _DepensesViewState();
}

class _DepensesViewState extends State<DepensesView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  // Clé Key du formulaire
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  ServicesDepense api = ServicesDepense();
  final StreamController<List<DepensesModel>> _streamController =
      StreamController();

  final _montantController = TextEditingController();
  final _motifController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Charger les produits au démarrage
  }

  @override
  void dispose() {
    _montantController.dispose();
    _motifController.dispose();
    _streamController
        .close(); // Fermer le StreamController pour éviter les fuites de mémoire
    super.dispose();
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

  Future<void> _loadProducts() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await api.getAllDepenses(token, userId);
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final depenses = (body["results"] as List)
            .map((json) => DepensesModel.fromJson(json))
            .toList();

        if (!_streamController.isClosed) {
          _streamController.add(depenses); // Ajouter les dépenses au stream
        }
      } else {
        if (!_streamController.isClosed) {
          _streamController.addError("Failed to load depenses");
        }
      }
    } catch (e) {
      if (!_streamController.isClosed) {
        _streamController.addError("Error loading depenses");
      }
    }
  }

  // Envoie des donnees vers le server
  Future<void> _sendNewDepenseToServer() async {
    if (_globalKey.currentState!.validate()) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;

      final data = {
        "userId": userId,
        "montants": _montantController.text,
        "motifs": _motifController.text
      };

      try {
        final res = await api.postNewDepenses(data, token);
        if (res.statusCode == 201) {
          // ignore: use_build_context_synchronously
          api.showSnackBarSuccessPersonalized(context, res.data["message"]);
        } else {
          // ignore: use_build_context_synchronously
          api.showSnackBarErrorPersonalized(context, res.data["message"]);
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        api.showSnackBarErrorPersonalized(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f1f5),
      appBar: AppBarWidget(
        title: "Les Depenses",
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
          child: Column(
            children: [
              Container(
                color: const Color(0xff001c30),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Total",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "3666666 XOF",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      constraints:
                          const BoxConstraints(maxWidth: 250, minHeight: 30),
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
              Container(
                padding: const EdgeInsets.all(8),
                child: StreamBuilder<List<DepensesModel>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Erreur : ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("Aucun produit disponible.");
                    } else {
                      return ListView.builder(
                        shrinkWrap: true, // Pour éviter un overflow
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          DepensesModel depenses = snapshot.data![index];
                          return Container(
                            height: 110,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: const Border(
                                bottom: BorderSide(
                                    color: Color.fromARGB(255, 235, 235, 235)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              depenses.motifs,
                                              style: GoogleFonts.roboto(
                                                fontSize: AppSizes.fontMedium,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "${depenses.montants.toString()} XOF", // Conversion du montant en String
                                              style: GoogleFonts.roboto(
                                                fontSize: AppSizes.fontMedium,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () {
            _addDepenses(context);
          },
          child: const Icon(
            Icons.add,
            size: AppSizes.iconLarge,
          )),
    );
  }

  void _addDepenses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Form(
            key: _globalKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Enregistrer vos depenses",
                      style: GoogleFonts.roboto(
                          fontSize: AppSizes.fontMedium,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _montantController,
                    decoration: const InputDecoration(
                        labelText: "Somme depensée",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le nom du produit est requis";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _motifController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        labelText: "Motif du depense",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La description est requise";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1A30),
                        minimumSize: const Size(400, 50)),
                    onPressed: () {
                      _sendNewDepenseToServer();
                      Navigator.pop(context);
                    },
                    child: Text("Enregistrer",
                        style: GoogleFonts.roboto(
                            fontSize: AppSizes.fontMedium,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
