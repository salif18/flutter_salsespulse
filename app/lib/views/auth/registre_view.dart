// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/routes.dart';
import 'package:salespulse/services/auth_api.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/auth/login_view.dart';

class RegistreView extends StatefulWidget {
  const RegistreView({super.key});

  @override
  State<RegistreView> createState() => _RegistreViewState();
}

class _RegistreViewState extends State<RegistreView> {
  // CLE KEY FORMULAIRE
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  // API SERVICE AUTHENTIFICATION
  ServicesAuth api = ServicesAuth();

  //CHAMPS FORMULAIRES
  final _nom = TextEditingController();
  final _entreprise = TextEditingController();
  final _numero = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool isVisibility = true;

  @override
  void dispose() {
    _nom.dispose();
    _entreprise.dispose();
    _numero.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

// ENVOIE DES DONNEE VERS API SERVER
 Future<void> _sendToserver(BuildContext context) async {
  if (_globalKey.currentState!.validate()) {
    final data = {
      "name": _nom.text,
      "boutique_name": _entreprise.text,
      "numero": _numero.text,
      "email": _email.text,
      "password": _password.text
    };
    final provider = Provider.of<AuthProvider>(context, listen: false);
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      
      final response = await api.postRegistreUser(data);
      final body = json.decode(response.body);

      if (!mounted) return; // Vérification avant l'utilisation de Navigator

      Navigator.pop(context); // Fermer le dialog

      if (response.statusCode == 201) {
        provider.loginButton(body['token'], body["userId"].toString(),
            body["userName"], body["entreprise"]);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Routes()));
      } else {
        api.showSnackBarErrorPersonalized(context, body["message"]);
      }
    } catch (e) {
      if (!mounted) return; // Vérification avant l'utilisation de Navigator
      Navigator.pop(context); // Fermer le dialogue
      api.showSnackBarErrorPersonalized(context, "Erreur: ${e.toString()}");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 248, 255),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 400,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/logos/logo2.jpg"),
                      fit: BoxFit.contain)),
            ),
            Container(
              height: 670,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
              decoration: const BoxDecoration(
                  color: Color(0xff001c30),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  )),
              child: Form(
                key: _globalKey,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Création de compte",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontHyperLarge,
                              color: Colors.white),
                        ),
                        Text(
                          "Information personnelle",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _nom,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintText: "Nom",
                          hintStyle:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                          filled: true,
                          fillColor: const Color(0xfff0fcf3),
                          prefixIcon: const Icon(Icons.person_3_outlined,
                              size: AppSizes.iconLarge),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _entreprise,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer votre service';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintText: "Votre societé",
                          hintStyle:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                          filled: true,
                          fillColor: const Color(0xfff0fcf3),
                          prefixIcon: const Icon(Icons.home_work_outlined,
                              size: AppSizes.iconLarge),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _numero,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer un numero';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Numero",
                          hintStyle:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                          filled: true,
                          fillColor: const Color(0xfff0fcf3),
                          prefixIcon: const Icon(Icons.phone_android_outlined,
                              size: AppSizes.iconLarge),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _email,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer un e-mail';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                          filled: true,
                          fillColor: const Color(0xfff0fcf3),
                          prefixIcon: const Icon(Icons.mail_outline,
                              size: AppSizes.iconLarge),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: isVisibility,
                      decoration: InputDecoration(
                          hintText: "Mot de passe",
                          hintStyle:
                              GoogleFonts.roboto(fontSize: AppSizes.fontMedium),
                          filled: true,
                          fillColor: const Color(0xfff0fcf3),
                          prefixIcon: const Icon(Icons.lock_outline,
                              size: AppSizes.iconLarge),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisibility = !isVisibility;
                                });
                              },
                              icon: Icon(isVisibility
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(400, 50),
                          backgroundColor:
                              const Color.fromARGB(255, 255, 123, 0),
                        ),
                        onPressed: () {
                          _sendToserver(context);
                        },
                        child: Text("Créer compte",
                            style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontMedium,
                                color: Colors.white))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous avez déjà un compte ?",
                          style: GoogleFonts.roboto(
                              fontSize: AppSizes.fontMedium,
                              color: Colors.white),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginView()));
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.roboto(
                                fontSize: AppSizes.fontSmall,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 123, 0),
                              ),
                            ))
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
