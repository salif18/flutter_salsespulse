import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/providers/panier_provider.dart';
import 'package:salespulse/services/panier_api.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/panier/widgets/card_cart.dart';
import 'package:salespulse/views/panier/widgets/cart_empty.dart';

class PanierView extends StatefulWidget {
  const PanierView({super.key});

  @override
  State<PanierView> createState() => _PanierViewState();
}

class _PanierViewState extends State<PanierView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  ServicesPanier api = ServicesPanier();
  DateTime selectedDate = DateTime.now();

  Future<void> _sendOrders(BuildContext context) async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);
    final panier = panierProvider.myCart;

    try {
      // Préparer les commandes
      List<Future<Response>> futures = panier.map((item) {
        var order = {
          'userId': userId,
          "nom": item.nom,
          "_id": item.productId,
          "categories": item.categories,
          "prix_achat": item.prixAchat,
          "prix_vente": item.prixVente,
          "stocks": item.stocks,
          "qty": item.qty,
          'date_vente': selectedDate.toIso8601String(),
        };
        return api.postOrders(order, token);
      }).toList();

      // Attendre que toutes les requêtes soient terminées
      final responses = await Future.wait(futures);

      // Traiter les réponses
      for (var response in responses) {
        final body = response.data as Map<String, dynamic>;

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          api.showSnackBarSuccessPersonalized(
              // ignore: use_build_context_synchronously
              context,
              body["message"] ?? 'Commande réussie');
        } else {
          // ignore: use_build_context_synchronously
          api.showSnackBarErrorPersonalized(
              // ignore: use_build_context_synchronously
              context,
              body["message"] ??
                  'Erreur lors de l\'enregistrement de la commande');
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      api.showSnackBarErrorPersonalized(context,
          'Une erreur s\'est produite lors de l\'enregistrement des ventes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          title: "Panier",
          color: Colors.white,
          titleColore: Colors.black,
          drawerkey: drawerKey),
      body: SafeArea(
        child: Consumer<PanierProvider>(
          builder: (context, panierProvider, child) {
            var cart = panierProvider.myCart;
            return cart.isNotEmpty
                ? ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, int index) {
                      final item = cart[index];
                      return Dismissible(
                        key: Key(item.productId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          panierProvider.removeToCart(item);
                        },
                        confirmDismiss: (direction) async {
                          return await _showAlertDelete(context);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1D1A30),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              size: AppSizes.iconLarge, color: Colors.white),
                        ),
                        child: MyCard(item: item),
                      );
                    },
                  )
                : const EmptyCart();
          },
        ),
      ),
      bottomNavigationBar: Consumer<PanierProvider>(
        builder: (context, panierProvider, child) {
          var cart = panierProvider.myCart;
          int total = panierProvider.total;
          int totalArticle = panierProvider.totalArticle;
          return cart.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 200, 255, 198),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  height: 300,
                  child: Column(
                    children: [
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nombre d'articles",
                              style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1D1A30),
                              ),
                            ),
                            Text(
                              "${totalArticle}",
                              style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontSmall,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D1A30),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "$total FCFA",
                              style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D1A30),
                            minimumSize: const Size(400, 50),
                          ),
                          icon: const Icon(
                            Icons.location_on,
                            size: AppSizes.iconLarge,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _sendOrders(context);
                          },
                          label: Text(
                            "Enregistrer cette vente",
                            style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Future<bool?> _showAlertDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer cet article ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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
