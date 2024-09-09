import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/panier/panier.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color color;
  final Color titleColore;
  final GlobalKey<ScaffoldState> drawerkey;
  const AppBarWidget(
      {super.key,
      required this.title,
      required this.color,
      required this.titleColore,
      required this.drawerkey});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: AppBar(
        backgroundColor: color,
        elevation: 0,
        centerTitle: true,
        leading: title == "Tableau de bord" 
            ? IconButton(
                onPressed: () {
                  drawerkey.currentState!.openDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  size: AppSizes.iconLarge,
                  color: titleColore,
                ))
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppSizes.iconLarge,
                  color: titleColore,
                )),
        title: Text(title,
            style: GoogleFonts.roboto(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.w500,
                color:titleColore)),
                actions: [
                  IconButton(
                    onPressed: (){
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PanierView()));
                    }, icon: Icon(Icons.shopping_cart_outlined,color:titleColore, size:AppSizes.iconHyperLarge))
                ],
      ),
    );
  }
}
