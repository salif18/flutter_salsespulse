import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:salespulse/providers/auth_provider.dart';
import 'package:salespulse/providers/panier_provider.dart';

class PrintReceiptPage extends StatelessWidget {
  PrintReceiptPage({super.key});
  final String storeName = "Ma Boutique";
  final List<Map<String, dynamic>> products = [
    {"name": "Produit A", "unitPrice": 10, "quantity": 2},
    {"name": "Produit B", "unitPrice": 15, "quantity": 1},
    {"name": "Produit C", "unitPrice": 7.5, "quantity": 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Imprimer Reçu"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _printReceipt(context);
          },
          child: Text("Imprimer le Reçu"),
        ),
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final pdf = pw.Document();
    // Utiliser Consumer pour récupérer les données du panier
    final store = Provider.of<AuthProvider>(context, listen: false).societeName;
    final panierProvider = Provider.of<PanierProvider>(context, listen: false);
    final panier = panierProvider.myCart;
    int total = panierProvider.total;
    // Ajouter les détails du reçu au PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final now = DateTime.now();
          final date = DateFormat("dd MMM yyyy").format(now);
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(store,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Date: $date", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text("Détails du reçu :",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ['Produit', 'Prix Unitaire', 'Quantité', 'Somme'],
                data: panier.map((product) {
                  return [
                    product.nom,
                    "${product.prixVente} \$",
                    "${product.qty}",
                    "$total \$"
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text(
                "Total: $total \$",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    // Utiliser le package `printing` pour imprimer ou sauvegarder le PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Calculer le total du reçu
//   double _calculateTotal(List<Map<String, dynamic>> products) {
//     double total = 0;
//     for (var product in products) {
//       total += product['unitPrice'] * product['quantity'];
//     }
//     return total;
//   }
}
