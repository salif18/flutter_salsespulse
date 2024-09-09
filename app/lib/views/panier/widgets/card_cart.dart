import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:salespulse/models/cart_item_model.dart';
import 'package:salespulse/providers/panier_provider.dart';
import 'package:salespulse/utils/app_size.dart';

class MyCard extends StatefulWidget {
  final CartItemModel item;
  const MyCard({super.key, required this.item});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: NetworkImage(widget.item.image),
                        fit: BoxFit.contain)),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.nom,
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xff121212)),
                      ),
                      Text(widget.item.prixVente.toString(),
                          style: GoogleFonts.roboto(
                              fontSize: 14, color: const Color(0xff121212)))
                    ],
                  ),
                  if (widget.item.stocks < widget.item.qty)
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "stocks insuffisant",
                        style: GoogleFonts.roboto(
                            fontSize: AppSizes.fontSmall, color: Colors.red),
                      ),
                    ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1D1A30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1D1A30),
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: TextButton(
                              onPressed: () {
                                Provider.of<PanierProvider>(context,
                                        listen: false)
                                    .increment(widget.item);
                              },
                              child: Text("+",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(widget.item.qty.toString(),
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (widget.item.qty > 1)
                          Container(
                            alignment: Alignment.center,
                            width: 50,
                            child: TextButton(
                                onPressed: () {
                                  Provider.of<PanierProvider>(context,
                                          listen: false)
                                      .decrement(widget.item);
                                },
                                child: Text("-",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                          )
                      ],
                    ),
                  )
                ],
              ))
            ],
          )),
    );
  }
}
