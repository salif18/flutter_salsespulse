import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salespulse/components/app_bar.dart';
import 'package:salespulse/components/drawer.dart';
import 'package:salespulse/utils/app_size.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: drawerKey,
      drawer: const DrawerWidget(),
      backgroundColor: const Color(0xff001c30),
      appBar: AppBarWidget(
          title: "Tableau de bord",
          color: const Color(0xff001c30),
          titleColore: Colors.white,
          drawerkey: drawerKey),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Color(0xfff0f1f5),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: _statsWeek(context)),
            _statsStock(context),
            _statsCaisse(context),
            _statsCaisse1(context),
            _statsCaisse2(context),
            _statsAnnuel(context)
          ],
        ),
      ),
    );
  }

  Widget _statsWeek(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xff001c30),
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
              child: Text("Hebdomadaire",
                  style: GoogleFonts.roboto(
                      fontSize: AppSizes.fontMedium, color: Colors.white))),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text("125000 fcfa",
                style: GoogleFonts.roboto(
                    fontSize: AppSizes.fontMedium, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _statsStock(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              width: 180,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 255, 149, 50),
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
              margin: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rate_rounded,
                        size: AppSizes.iconLarge,
                        color:Colors.yellow
                      ),
                      Text(
                        "Les plus achetés",
                        style:
                            GoogleFonts.roboto(fontSize: AppSizes.fontMedium, color:Colors.white),
                      )
                    ],
                  )
                ],
              )),
          Container(
              width: 180,
              height: 200,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xfff0f1f5),
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
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.hourglass_empty_rounded,
                        size: AppSizes.iconLarge,
                        color:Color.fromARGB(255, 236, 40, 40)
                      ),
                      Text(
                        "Manque de stock",
                        style:
                            GoogleFonts.roboto(fontSize: AppSizes.fontMedium ,color:const Color.fromARGB(255, 39, 39, 39)),
                      )
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _statsCaisse(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
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
      width: double.infinity,
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
                    Icons.line_axis_rounded,
                    size: AppSizes.iconLarge,
                    color:Color.fromARGB(255, 20, 151, 3)
                  )),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "Etat de caisse",
                    style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium ),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  "200000 fcfa",
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium ),
                ),
               const SizedBox(width: 25),
               const Icon(Icons.arrow_upward_rounded , size: AppSizes.fontLarge,color:Colors.blue,)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statsCaisse1(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
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
                          color:Color.fromARGB(255, 255, 230, 1)
                        )),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          "Prix d'achat",
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium , color:Colors.white),
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "200000 fcfa",
                    style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium, color:Colors.white),
                  ),
                )
              ],
            ),
          ),
          Container(
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
                        child: Text(
                          "Prix de vente",
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "200000 fcfa",
                    style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCaisse2(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: Text(
                          "Benefices",
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium ,color:Colors.white),
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "200000 fcfa",
                    style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffff7c60),
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
                          color:Color.fromARGB(255, 255, 17, 0)
                        )),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          "Depenses",
                          style:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium, color:Colors.white),
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    "200000 fcfa",
                    style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium,color:Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsAnnuel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xfff0f1f5),
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
              child: Text("Annuel",
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium))),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text("125000 fcfa",
                style: GoogleFonts.roboto(fontSize: AppSizes.fontMedium)),
          ),
        ],
      ),
    );
  }
}
