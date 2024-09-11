import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/components/bar_chart.dart';
import 'package:salespulse/components/drawer.dart';
import 'package:salespulse/components/line_chart.dart';
import 'package:salespulse/models/stats_categorie_model.dart';
import 'package:salespulse/models/stats_week_model.dart';
import 'package:salespulse/models/stats_year_model.dart';
import 'package:salespulse/models/stocks_model.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/services/depense_api.dart';
import 'package:salespulse/services/stats_api.dart';
import 'package:salespulse/services/stocks_api.dart';
import 'package:salespulse/services/vente_api.dart';
import 'package:salespulse/utils/app_size.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  ServicesDepense depenseApi = ServicesDepense();
  ServicesStocks stockApi = ServicesStocks();
  ServicesVentes venteApi = ServicesVentes();
  ServicesStats statsApi = ServicesStats();

  List<ProduitBestVendu> populaireVente = [];
  List<StocksModel> stocks = [];
  List<StatsWeekModel> statsHebdo = [];
  List<StatsYearModel> statsYear = [];
  int totalAchatOfAchat = 0;
  int totalAchatOfVente = 0;
  int beneficeTotal = 0;
  int venteTotal = 0;
  int depenseTotal = 0;

  int totalHebdo = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Charger les produits au démarrage
    _loadVentes();
    _loadDepenses();
    _loadMostCategorie();
    _loadStatsHebdo();
    _loadStatsYear();
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadProducts() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await stockApi.getAllProducts(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // Ajouter les produits au stream
        setState(() {
          stocks = (body["produits"] as List)
              .map((json) => StocksModel.fromJson(json))
              .toList();
          totalAchatOfAchat = body["totalAchatOfAchat"];
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  Future<void> _loadDepenses() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await depenseApi.getAllDepenses(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          depenseTotal = body["depensesTotal"];
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadVentes() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await venteApi.getAllVentes(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          totalAchatOfVente = body["totalAchatOfVente"];
          venteTotal = body["total_vente"];
          beneficeTotal = body["benefice_total"];
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadMostCategorie() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await statsApi.getStatsByCategories(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          populaireVente = (body["results"] as List)
              .map((json) => ProduitBestVendu.fromJson(json))
              .toList();
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadStatsHebdo() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await statsApi.getStatsHebdo(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          totalHebdo = body["totalHebdo"];
          statsHebdo = (body["stats"] as List)
              .map((json) => StatsWeekModel.fromJson(json))
              .toList();
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  // Fonction pour récupérer les produits depuis le serveur et ajouter au stream
  Future<void> _loadStatsYear() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final res = await statsApi.getStatsByMonth(token, userId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          statsYear = (body["results"] as List)
              .map((json) => StatsYearModel.fromJson(json))
              .toList();
        });
      } else {
        Exception("Failed to load products");
      }
    } catch (e) {
      Exception("Error loading products");
    }
  }

  //rafraichire la page en actualisanst la requete
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _loadProducts();
      _loadDepenses();
      _loadMostCategorie();
      _loadStatsHebdo();
      _loadStatsYear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: drawerKey,
        drawer: const DrawerWidget(),
        backgroundColor: const Color.fromARGB(255, 223, 223, 223),
        appBar: AppBarWidget(
            title: "Tableau de bord",
            color: const Color(0xff001c30),
            titleColore: Colors.white,
            drawerkey: drawerKey),
        body: RefreshIndicator(
          backgroundColor: Colors.transparent,
          color: Colors.grey[100],
          onRefresh: _refresh,
          displacement: 50,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: _statsWeek(context)),
              ),
              SliverToBoxAdapter(child: _statsStock(context)),
              SliverToBoxAdapter(child: _statsCaisse(context)),
              SliverToBoxAdapter(child: _statsCaisse1(context)),
              SliverToBoxAdapter(child: _statsCaisse2(context)),
              SliverToBoxAdapter(child: _statsAnnuel(context)),
            ],
          ),
        ));
  }

  Widget _statsWeek(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // color: const Color(0xff001c30),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 36, 34, 34)
                  .withOpacity(0.2), // Couleur de l'ombre
              spreadRadius: 2, // Taille de la diffusion de l'ombre
              blurRadius: 8, // Flou de l'ombre
              offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Hebdomadaire",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color.fromARGB(255, 7, 7, 7))),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("$totalHebdo XOF",
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: const Color.fromARGB(255, 10, 10, 10))),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(0),
                child: BarChartWidget(
                  data: statsHebdo,
                ))
          ],
        ),
      );
    });
  }

  Widget _statsStock(BuildContext context) {
    List<StocksModel> filterStocks =
        stocks.where((product) => product.stocks == 0).toList();

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatContainer(
              title: "Les plus achetés",
              icon: Icons.star_rate_rounded,
              iconColor: Colors.yellow,
              backgroundColor: const Color.fromARGB(255, 255, 149, 50),
              textColor: Colors.white,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: populaireVente.length.clamp(0, 5), // max 4 items
                  itemBuilder: (context, index) {
                    final stock = populaireVente[index];
                    return ListTile(
                      title: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stock.id.nom,
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                color: Colors.white),
                          )),
                         subtitle: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                           "catego: ${stock.id.categories}",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                color: Colors.white),
                          )),
                      trailing: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stock.totalVendu.toString(),
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                color: Colors.white),
                          )),
                    );
                  },
                ),
              ),
            ),
            _buildStatContainer(
              title: "Manque de stock",
              icon: Icons.hourglass_empty_rounded,
              iconColor: const Color.fromARGB(255, 236, 40, 40),
              backgroundColor: const Color(0xfff0f1f5),
              textColor: const Color.fromARGB(255, 39, 39, 39),
              child: filterStocks.isEmpty
                  ? Center(
                      child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Aucun stock manquant",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium)),
                    ))
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            filterStocks.length.clamp(0, 5), // max 4 items
                        itemBuilder: (context, index) {
                          final stock = filterStocks[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(stock.nom,
                                    style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontMedium)),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(stock.categories,
                                    style: GoogleFonts.roboto(
                                        fontSize: AppSizes.fontMedium)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color textColor,
    Widget? child,
  }) {
    return Flexible(
      flex: 1,
      child: Container(
        // width: 180,
        height: 200,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 36, 34, 34).withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSizes.iconLarge, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: AppSizes.fontMedium,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _statsCaisse(BuildContext context) {
    int revenu = beneficeTotal - depenseTotal;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: const Color(0xfff0f1f5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 36, 34, 34)
                  .withOpacity(0.2), // Couleur de l'ombre
              spreadRadius: 2, // Taille de la diffusion de l'ombre
              blurRadius: 8, // Flou de l'ombre
              offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
            ),
          ],
        ),
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.line_axis_rounded,
                        size: AppSizes.iconLarge,
                        color: Color.fromARGB(255, 20, 151, 3))),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Etat de caisse",
                        style:
                            GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                      ),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "$revenu XOF",
                      style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium,fontWeight:FontWeight.bold , color: revenu < 0? Colors.red : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 25),
                  revenu > 0
                      ? const Icon(
                          Icons.arrow_upward_rounded,
                          size: AppSizes.fontLarge,
                          color: Colors.blue,
                        )
                      : const Icon(
                          Icons.arrow_downward_outlined,
                          size: AppSizes.fontLarge,
                          color: Colors.red,
                        )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _statsCaisse1(BuildContext context) {
    int prixGlobalAchat = totalAchatOfAchat + totalAchatOfVente;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: constraints.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xfff764ba),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 36, 34, 34)
                          .withOpacity(0.2), // Couleur de l'ombre
                      spreadRadius: 2, // Taille de la diffusion de l'ombre
                      blurRadius: 8, // Flou de l'ombre
                      offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
                    ),
                  ],
                ),
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.monetization_on,
                                size: AppSizes.iconLarge,
                                color: Color.fromARGB(255, 255, 230, 1))),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Prix d'achat",
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "$prixGlobalAchat XOF",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 36, 34, 34)
                          .withOpacity(0.2), // Couleur de l'ombre
                      spreadRadius: 2, // Taille de la diffusion de l'ombre
                      blurRadius: 8, // Flou de l'ombre
                      offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
                    ),
                  ],
                ),
                width: 180,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.attach_money_outlined,
                              size: AppSizes.iconLarge,
                              color: Color.fromARGB(255, 16, 230, 23),
                            )),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Prix de vente",
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium),
                              ),
                            ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "$venteTotal XOF",
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statsCaisse2(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: constraints.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff2f80ed),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 36, 34, 34)
                        .withOpacity(0.2), // Couleur de l'ombre
                    spreadRadius: 2, // Taille de la diffusion de l'ombre
                    blurRadius: 8, // Flou de l'ombre
                    offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
                  ),
                ],
              ),
              width: 180,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.monetization_on,
                            size: AppSizes.iconLarge,
                            color: Color.fromARGB(255, 255, 255, 255),
                          )),
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Benefices",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontMedium,
                                  color: Colors.white),
                            ),
                          ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$beneficeTotal XOF",
                        style: GoogleFonts.roboto(
                            fontSize: AppSizes.fontMedium, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF292D4E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 36, 34, 34)
                          .withOpacity(0.2), // Couleur de l'ombre
                      spreadRadius: 2, // Taille de la diffusion de l'ombre
                      blurRadius: 8, // Flou de l'ombre
                      offset: const Offset(0, 4), // Décalage de l'ombre (x,y)
                    ),
                  ],
                ),
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.monetization_on,
                                size: AppSizes.iconLarge,
                                color: Color.fromARGB(255, 255, 17, 0))),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Depenses",
                                style: GoogleFonts.roboto(
                                    fontSize: AppSizes.fontMedium,
                                    color: Colors.white),
                              ),
                            ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "$depenseTotal XOF",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statsAnnuel(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.all(5),
        width: constraints.maxWidth,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 223, 223, 223),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Annuel",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color.fromARGB(255, 12, 12, 12))),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("125000 fcfa",
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: const Color.fromARGB(255, 5, 5, 5))),
              ),
            ),
            LineChartWidget(data: statsYear),
          ],
        ),
      );
    });
  }
}
