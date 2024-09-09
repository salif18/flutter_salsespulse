import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/models/categories_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/services/categ_api.dart';
import 'package:salespulse/utils/app_size.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  ServicesCategories api = ServicesCategories();
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final StreamController<List<CategoriesModel>> _listCategories =
      StreamController<List<CategoriesModel>>();
  final _categorieName = TextEditingController();

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  void dispose() {
    _listCategories.close();
    _categorieName.dispose();
    super.dispose();
  }

  // OBTENIR LES CATEGORIES API
  Future<void> _getCategories() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    try {
      final res = await api.getCategories(userId, token);
      final body = res.data;
      if (res.statusCode == 200) {
        setState(() {
          final products = (body["results"] as List)
              .map((json) => CategoriesModel.fromJson(json))
              .toList();
          _listCategories.add(products);
        });
      }
    } catch (e) {
      Exception(e); // Ajout d'une impression pour le debug
    }
  }

//SUPPRIMER CATEGORIE API
  Future<void> _removeCategories(id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final res = await api.deleteCategories(id, token);
      final body = res.data;
      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        api.showSnackBarSuccessPersonalized(context, body["message"]);
        _getCategories(); // Actualiser la liste des catégories
      } else {
        // ignore: use_build_context_synchronously
        api.showSnackBarErrorPersonalized(context, body["message"]);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      api.showSnackBarErrorPersonalized(context, e.toString());
    }
  }

//AJOUTER CATEGORIE API
  Future<void> _sendToserver(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (_globalKey.currentState!.validate()) {
      final data = {
        "userId": userId,
        "name": _categorieName.text,
      };
      try {
        showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        final res = await api.postCategories(data, token);
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Fermer le dialog

        if (res.statusCode == 200) {
          // ignore: use_build_context_synchronously
          api.showSnackBarSuccessPersonalized(context, res.data["message"]);
          _getCategories();
        } else {
          // ignore: use_build_context_synchronously
          api.showSnackBarErrorPersonalized(context, res.data["message"]);
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Fermer le dialog
        // ignore: use_build_context_synchronously
        api.showSnackBarErrorPersonalized(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: "Les rapports",
        color: const Color(0xff001c30),
        titleColore: Colors.white,
        drawerkey: drawerKey,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: StreamBuilder<List<CategoriesModel>>(
          stream: _listCategories.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Pas de données disponibles"));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index) {
                  CategoriesModel categorie = snapshot.data![index];
                  return Dismissible(
                    key: Key(categorie.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeCategories(categorie.id);
                    },
                    confirmDismiss: (direction) async {
                      return await showRemoveCategorie(context);
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_outline,
                              color: Colors.white, size: AppSizes.iconLarge),
                          SizedBox(width: 50),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(255, 245, 245, 245)))),
                      child: ListTile(
                        title: Text(
                          categorie.name,
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1D1A30),
        onPressed: () {
          _addCateShow(context);
        },
        child: const Icon(
          Icons.add,
          size: AppSizes.iconLarge,
          color: Colors.white,
        ),
      ),
    );
  }

//FENETRE POUR AJOUTER CATEGORIE
  void _addCateShow(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Ajouter categories",
              style: GoogleFonts.roboto(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _globalKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _categorieName,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer une categorie';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Nom de la categorie",
                        hintStyle:
                            GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                        prefixIcon: const Icon(
                          Icons.category_rounded,
                          size: AppSizes.iconMedium,
                          color: Colors.purpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _sendToserver(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1A30),
                        minimumSize: const Size(400, 50),
                      ),
                      child: Text(
                        "Enregistrer",
                        style: GoogleFonts.roboto(
                          fontSize: AppSizes.fontSmall,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
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

// FENTRE DIALOGUE POUR CONFIRMER LA SUPPRESSION
  Future<bool> showRemoveCategorie(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette catégorie ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Annuler",
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Supprimer",
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium)),
            ),
          ],
        );
      },
    );
  }
}
