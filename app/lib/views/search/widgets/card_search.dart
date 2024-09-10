import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salespulse/models/stocks_model.dart';
import 'package:salespulse/utils/app_size.dart';

class ResultSearch extends StatelessWidget {
  final StocksModel item;
  const ResultSearch({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: GestureDetector(
        onTap: () {
        
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 90,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                    bottom:
                        BorderSide(color: Color.fromARGB(255, 219, 219, 219)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: NetworkImage(item.image), fit: BoxFit.contain)),
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nom,
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.fontMedium,
                                color: const Color(0xff121212)),
                          ),
                          Text("${item.prixVente} cfa",
                              style: GoogleFonts.roboto(
                                  fontSize: AppSizes.fontSmall, color: const Color(0xff121212)))
                        ],
                      ),
                    ),
                  ],
                ))
              ],
            )),
      ),
    );
  }
}