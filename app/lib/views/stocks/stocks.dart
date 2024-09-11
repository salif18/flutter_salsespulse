import 'dart:async'; // Pour StreamController
import 'dart:convert';
import 'dart:io';
import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/models/categories_model.dart';
import 'package:salespulse/models/stocks_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/providers/panier_provider.dart';
import 'package:salespulse/services/categ_api.dart';
import 'package:salespulse/services/stocks_api.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/categories/categories_view.dart';
import 'package:salespulse/views/fournisseurs/fournisseurs_view.dart';
import 'package:salespulse/views/search/search_view.dart';

class StocksView extends StatefulWidget {
  const StocksView({super.key});

  @override
  State<StocksView> createState() => _StocksViewState();
}

class _StocksViewState extends State<StocksView> {

  ServicesStocks api = ServicesStocks();
  ServicesCategories apiCatego = ServicesCategories();
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  // Clé Key du formulaire
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final StreamController<List<StocksModel>> _streamController =
      StreamController();
  List<CategoriesModel> _listCategories = [];
  String? _categorieValue;

  // configuration de selection image depuis gallerie
  final ImagePicker _picker = ImagePicker();
  XFile? _articleImage;

// configuration des champs de formulaires pour le controller
  final _nameController = TextEditingController();
  String? _categoryController;
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _stockController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    _loadProducts(); // Charger les produits au démarrage
    _getCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prixAchatController.dispose();
    _prixVenteController.dispose();
    _stockController.dispose();
    _streamController
        .close(); // Fermer le StreamController pour éviter les fuites de mémoire
  
    super.dispose();
  }

  //rafraichire la page en actualisanst la requete
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _loadProducts();
      _getCategories();
    });
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadProducts() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await api.getAllProducts(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final products = (body["produits"] as List)
            .map((json) => StocksModel.fromJson(json))
            .toList();
        _streamController.add(products); // Ajouter les produits au stream
      } else {
        _streamController.addError("Failed to load products");
      }
    } catch (e) {
      _streamController.addError("Error loading products");
    }
  }

  // OBTENIR LES CATEGORIES API
  Future<void> _getCategories() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    try {
      final res = await apiCatego.getCategories(userId, token);
      final body = res.data;
      if (res.statusCode == 200) {
        setState(() {
          _listCategories = (body["results"] as List)
              .map((json) => CategoriesModel.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      Exception(e); // Ajout d'une impression pour le debug
    }
  }

  // obtenir l"image depuis gallerie du telephone
  Future<void> _getImageToGalleriePhone() async {
    final XFile? imagePicked =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (imagePicked != null) {
        _articleImage = imagePicked;
      }
    });
  }

// Envoie des donnees vers le server
  Future<void> _sendNewStocksToServer() async {
    if (_globalKey.currentState!.validate()) {
      if (_categoryController == null) {
        api.showSnackBarErrorPersonalized(
            context, "Veuillez sélectionner  une catégorie.");
        return;
      }
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;

      FormData formData = FormData.fromMap({
        "userId": userId,
        "nom": _nameController.text,
        "image": _articleImage != null
            ? await MultipartFile.fromFile(_articleImage!.path,
                filename: _articleImage!.path.split("/").last)
            : "",
        "categories": _categoryController,
        "prix_achat": _prixAchatController.text,
        "prix_vente": _prixVenteController.text,
        "stocks": _stockController.text,
        "date_achat": selectedDate.toIso8601String(),
      });

      try {
        final res = await api.postNewProduct(formData, token);
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

// Envoie des donnees vers le server
  Future<void> _sendUpdateStockToServer(article) async {
    if (_globalKey.currentState!.validate()) {
      if (_articleImage == null || _categoryController == null) {
        api.showSnackBarErrorPersonalized(
            context, "Veuillez sélectionner une image et une catégorie.");
        return;
      }
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;

      FormData formData = FormData.fromMap({
        "userId": userId,
        "nom": _nameController.text,
        "image": await MultipartFile.fromFile(_articleImage!.path,
            filename: _articleImage!.path.split("/").last),
        "categories": _categoryController,
        "prix_achat": _prixAchatController.text,
        "prix_vente": _prixVenteController.text,
        "stocks": _stockController.text,
        "date_achat": selectedDate.toIso8601String(),
      });

      try {
        final res = await api.updateProduct(formData, token, article.productId);
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

  Future<void> _removeArticles(article) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final res = await api.deleteProduct(article.productId, token);
      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        api.showSnackBarErrorPersonalized(context, res.data["message"]);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      api.showSnackBarErrorPersonalized(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    PanierProvider cartProvider =
        Provider.of<PanierProvider>(context, listen: false);
    void Function(StocksModel, int) addToCart = cartProvider.addToCart;

    return RefreshIndicator(
      backgroundColor: Colors.transparent,
      color: Colors.grey[100],
      onRefresh: _refresh,
      displacement: 50,
      child: Scaffold(
        backgroundColor: const Color(0xfff0f1f5),
        appBar: AppBarWidget(
          title: "Stocks",
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
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                        minHeight: 30,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _categorieValue,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Categories",
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                        items: _listCategories.map((categorie) {
                          return DropdownMenuItem<String>(
                            value: categorie.name,
                            child: Text(categorie.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categorieValue = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "La catégorie est requise";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<List<StocksModel>>(
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
                    final articles = snapshot.data!;
                    final filteredArticles = _categorieValue != null
                        ? articles
                            .where((article) =>
                                article.categories == _categorieValue)
                            .toList()
                        : articles;
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
                                  "Photo",
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
                          rows: filteredArticles.map((article) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    child: article.image.isEmpty
                                        ? Image.asset(
                                            "assets/images/defaultImg.png",
                                            width: 50,
                                            height: 50,
                                          )
                                        : Image.network(
                                            article.image,
                                            width: 50,
                                            height: 50,
                                          ),
                                  ),
                                ),
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
                                      "${article.prixAchat} XOF",
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
                                      article.stocks.toString(),
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
                                          .format(article.dateAchat),
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
                                        if (article.stocks > 0)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_shopping_cart_rounded,
                                                color: Colors.blue),
                                            onPressed: () {
                                              // Action pour éditer le produit
                                              addToCart(article, 1);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  "Article ajouté",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 16),
                                                ),
                                                // backgroundColor: const Color.fromARGB(255, 255, 35, 19),
                                                duration:
                                                    const Duration(seconds: 1),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 39, 58, 90),
                                                action: SnackBarAction(
                                                  label: "",
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                  },
                                                ),
                                              ));
                                            },
                                          ),
                                        if (article.stocks > 0)
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color.fromARGB(
                                                    255, 53, 146, 30)),
                                            onPressed: () {
                                              // Action pour supprimer le produit
                                              _editStocks(context, article);
                                            },
                                          ),
                                        if (article.stocks == 0)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.highlight_remove_rounded,
                                                color: Color.fromARGB(
                                                    255, 255, 67, 67)),
                                            onPressed: () {
                                              // Action pour éditer le produit
                                              _showAlertDelete(
                                                  context, article);
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()));
                },
                child: const Icon(Icons.search, size: AppSizes.iconLarge)),
            ElevatedButton(
                onPressed: () {
                  _addStokcs(context);
                },
                child: const Icon(Icons.add, size: AppSizes.iconLarge)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoriesView()));
              },
              icon: const Icon(Icons.category, size: AppSizes.iconLarge),
              label: Text(
                "Categories",
                style: GoogleFonts.roboto(fontSize: AppSizes.fontSmall),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FournisseurView()));
              },
              icon: const Icon(Icons.airport_shuttle, size: AppSizes.iconLarge),
              label: Text(
                "Fournisseurs",
                style: GoogleFonts.roboto(fontSize: AppSizes.fontSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addStokcs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height * 0.95,
          child: Form(
            key: _globalKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Ajouter vos stocks",
                      style: GoogleFonts.roboto(
                          fontSize: AppSizes.fontMedium,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Image du produit",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium)),
                          IconButton(
                            icon: const Icon(Icons.photo_camera_back_outlined,
                                size: 38),
                            onPressed: () {
                              _getImageToGalleriePhone();
                            },
                          ),
                        ],
                      ),
                      if (_articleImage != null)
                        Image.file(File(_articleImage!.path),
                            width: 100, height: 100),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: "Nom du produit",
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
                    controller: _prixAchatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Prix d'achat",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La description est requise";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _prixVenteController,
                    decoration: const InputDecoration(
                        labelText: "Prix de vente",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le prix est requis";
                      } else if (double.tryParse(value) == null) {
                        return "Veuillez entrer un prix valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _stockController,
                    decoration: const InputDecoration(
                        labelText: "Stock du produit",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le stock est requis";
                      } else if (int.tryParse(value) == null) {
                        return "Veuillez entrer un stock valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _categoryController,
                    decoration: const InputDecoration(
                        labelText: "Catégorie du produit",
                        border: OutlineInputBorder()),
                    items: _listCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoryController = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "La catégorie est requise";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                        selectedDate = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1A30),
                        minimumSize: const Size(400, 50)),
                    onPressed: () {
                      _sendNewStocksToServer();
                      Navigator.pop(context);
                    },
                    child: Text("Ajouter",
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

  void _editStocks(BuildContext context, article) {
    _nameController.text = article.nom;
    _categoryController = article.categories;
    _prixAchatController.text = article.prixAchat.toString();
    _stockController.text = article.stocks.toString();
    _prixVenteController.text = article.prixVente.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height * 0.95,
          child: Form(
            key: _globalKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Modifier vos stocks",
                      style: GoogleFonts.roboto(
                          fontSize: AppSizes.fontMedium,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Image du produit",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium)),
                          IconButton(
                            icon: const Icon(Icons.photo_camera_back_outlined,
                                size: 38),
                            onPressed: () {
                              _getImageToGalleriePhone();
                            },
                          ),
                        ],
                      ),
                      if (_articleImage != null)
                        Image.file(File(_articleImage!.path),
                            width: 100, height: 100),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: "Nom du produit",
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
                    controller: _prixAchatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Prix d'achat",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "La description est requise";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _prixVenteController,
                    decoration: const InputDecoration(
                        labelText: "Prix de vente",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le prix est requis";
                      } else if (double.tryParse(value) == null) {
                        return "Veuillez entrer un prix valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _stockController,
                    decoration: const InputDecoration(
                        labelText: "Stock du produit",
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le stock est requis";
                      } else if (int.tryParse(value) == null) {
                        return "Veuillez entrer un stock valide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _categoryController,
                    decoration: const InputDecoration(
                        labelText: "Catégorie du produit",
                        border: OutlineInputBorder()),
                    items: _listCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoryController = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "La catégorie est requise";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
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
                        selectedDate = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1A30),
                        minimumSize: const Size(400, 50)),
                    onPressed: () {
                      _sendUpdateStockToServer(article);
                      Navigator.pop(context);
                    },
                    child: Text("modifier",
                        style: GoogleFonts.roboto(
                            fontSize: AppSizes.fontMedium,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 240, 27, 27),
                        minimumSize: const Size(400, 50)),
                    onPressed: () {
                      _removeArticles(article);
                    },
                    child: Text("Supprimer",
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

  Future<bool?> _showAlertDelete(BuildContext context, article) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer cet article ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => _removeArticles(article),
              child: const Text("Supprimer"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );
  }
}
