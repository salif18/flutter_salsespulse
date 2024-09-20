import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/utils/app_size.dart';
import 'package:salespulse/views/auth/login_view.dart';
import 'package:salespulse/views/dashbord/dashboard.dart';
import 'package:salespulse/views/depenses/depense_view.dart';
import 'package:salespulse/views/rapports/rapports.dart';
import 'package:salespulse/views/stocks/stocks.dart';
import 'package:salespulse/views/ventes/ventes.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<AuthProvider>(
      builder: (context, provider, child) {
        // Si le token est présent, afficher les vues de l'application
        if (provider.token.isNotEmpty) {
          return <Widget>[
            DashboardView(),
            StocksView(),
            VenteView(),
            RapportView(),
            DepensesView(),
            DashboardView()
          ][_currentIndex];
        } else {
          // Si pas de token, afficher la page de connexion
          return const LoginView();
        }
      },
    ), bottomNavigationBar:
        Consumer<AuthProvider>(builder: (context, provider, child) {
      if (provider.token.isNotEmpty) {
        return _buildBottomNavigation();
      } else {
        // Si pas de token, ne rien afficher
        return const SizedBox.shrink();
      }
    }));
  }

  Widget _buildBottomNavigation() {
    return SizedBox(
      height: 80,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 20,
        selectedItemColor: const Color(0xFF1D1A30),
        unselectedItemColor: const Color.fromARGB(255, 168, 168, 168),
        iconSize: AppSizes.iconLarge,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart_rounded),
              label: "Statistiques"),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar_outlined), label: "Stocks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.clean_hands_rounded), label: "Vente"),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_sharp), label: "Rapports"),
          BottomNavigationBarItem(
              icon: Icon(Icons.balance_sharp), label: "Depenses"),
        ],
      ),
    );
  }
}
