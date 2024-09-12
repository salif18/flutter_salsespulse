import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/views/customscroll/usage_customscroll_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
           ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewCustomScroll()));
            },
            title: Row(
              children: [Text("custom page")],
            ),
          ),
          Consumer<AuthProvider>(builder: (context, provider, child) {
            return ListTile(
              onTap: () {
                provider.logoutButton();
              },
              title: Row(
                children: [Text("Se deconnecter")],
              ),
            );
          }),
        ],
      ),
    );
  }
}
