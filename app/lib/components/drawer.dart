import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/auth/update_password.dart';
import 'package:salespulse/views/customscroll/usage_customscroll_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:salespulse/views/profil/update_profil.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff001c30),
      child: LayoutBuilder(builder: (context, constraints) {
      return ListView(
        children: [
          DrawerHeader(
              child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight * 0.20,
            child: Image.asset(
              "assets/images/salespulse2.jpg",
              fit: BoxFit.fill,
            ),
          )),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UpdateProfil()));
            },
            title: Row(
              children: [
                const Icon(Icons.edit, size: AppSizes.iconLarge,color: Color.fromARGB(255, 58, 174, 228)),
                const SizedBox(width:20),
                AutoSizeText(
                  "Modifier profil",
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontLarge, color: Colors.white),
                )
              ],
            ),
          ),
         
        ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UpdatePassword()));
            },
            title: Row(
              children: [
                const Icon(Icons.password, size: AppSizes.iconLarge,color: Color.fromARGB(255, 2, 156, 27)),
                const SizedBox(width:20),
                AutoSizeText(
                  "Modifier password",
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontLarge,color: Colors.white),
                )
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewCustomScroll()));
            },
            title: Row(
              children: [
                const Icon(Icons.person_off_outlined, size: AppSizes.iconLarge,color: const Color.fromARGB(255, 228, 58, 58)),
                const SizedBox(width:20),
                AutoSizeText(
                  "Supprimer",
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(fontSize: AppSizes.fontLarge,color: const Color.fromARGB(255, 228, 58, 58)),
                )
              ],
            ),
          ),
         
          Consumer<AuthProvider>(builder: (context, provider, child) {
            return ListTile(
              onTap: () {
                provider.logoutButton();
              },
              title: Row(
                children: [
                  AutoSizeText("Se deconnecter",style: GoogleFonts.roboto(fontSize:AppSizes.fontLarge,color: Colors.white),)],
              ),
            );
          }),
        ],
      );
    }));
  }
}
