// ignore_for_file: must_be_immutable

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salespulse/models/chart_model.dart';
import 'package:salespulse/models/stats_year_model.dart';

class LineChartWidget extends StatelessWidget {
  final List<StatsYearModel> data;
  const LineChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    
    //convertir data au format modelLinedata
    List<ModelLineData> modelLineData = data
            .map((e) => ModelLineData(
                x: double.parse(e.month.toString()),
                y: e.totalVentes?.toDouble() ?? 0.0))
            .toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: 2,
        child: Container(
          padding: const EdgeInsets.only(right: 25),
          decoration: BoxDecoration(
              color: const Color(0xFF292D4E),
              borderRadius: BorderRadius.circular(20)),
          child: LineChart(
              duration: const Duration(milliseconds: 750),
              curve: Curves.linear,
              LineChartData(
                  minX: 0,
                  maxX: 12,
                  minY: 0,
                  maxY: 400000,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  // lineTouchData: myLineTouchData(modelLineData),
                  titlesData: myLineTitlesData(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: modelLineData
                          .asMap()
                          .entries
                          .map((item) => FlSpot(item.value.x, item.value.y))
                          .toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.orangeAccent]),
                      dotData: const FlDotData(show: true),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(colors: [
                            Colors.redAccent.withOpacity(.4),
                            Colors.orangeAccent.withOpacity(.4)
                          ]),
                          applyCutOffY: true),
                      preventCurveOverShooting: true,
                      preventCurveOvershootingThreshold: 5.9,
                    ),
                  ])),
        ),
      ),
    );
  }

  LineTouchData myLineTouchData(List<ModelLineData> modelLineData) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        // tooltipBgColor: Colors.transparent,
        tooltipPadding: const EdgeInsets.all(5),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            String month;
            switch (touchedSpot.x.toInt()) {
              case 1:
                month = "Janvier";
                break;
              case 2:
                month = "Fevrier";
                break;
              case 3:
                month = "Mars";
                break;
              case 4:
                month = "Avril";
                break;
              case 5:
                month = "Mai";
                break;
              case 6:
                month = "Juin";
                break;
              case 7:
                month = "Juillet";
                break;
              case 8:
                month = "Aout";
                break;
              case 9:
                month = "Septembre";
                break;
              case 10:
                month = "Octobre";
                break;
              case 11:
                month = "Novembre";
                break;
              case 12:
                month = "Decembre";
                break;
              default:
                month = "";
                break;
            }
            String montant;
            int index = touchedSpot.x.toInt().clamp(1, modelLineData.length -1);
            
            switch (index) {
              case 1:
                montant = "${modelLineData[1].y}";
                break;
              case 2:
                montant = "${modelLineData[2].y}";
                break;
              case 3:
                montant = "${modelLineData[3].y}";
                break;
              case 4:
                montant = "${modelLineData[4].y}";
                break;
              case 5:
                montant = "${modelLineData[5].y}";
                break;
              case 6:
                montant = "${modelLineData[6].y}";
                break;
              case 7:
                montant = "${modelLineData[7].y}";
                break;
              case 8:
                montant = "${modelLineData[8].y}";
                break;
              case 9:
                montant = "${modelLineData[9].y}";
                break;
              case 10:
                montant = "${modelLineData[10].y}";
                break;
              case 11:
                montant = "${modelLineData[11].y}";
                break;
              case 12:
                montant = "${modelLineData[12].y}";
                break;
              default:
                montant = "";
                break;
            }

            return LineTooltipItem(
              "$month\n",
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: montant,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  FlTitlesData myLineTitlesData() {
    return FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 55,         
                getTitlesWidget: namedYear)));
  }

  Widget namedYear(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: _textBuild(value.toInt()),
    );
  }

  Widget _textBuild(int value) {
    switch (value) {
      case 1:
        return Text(
          "Jan",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 2:
        return Text(
          "Fe",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 3:
        return Text(
          "Mar",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 4:
        return Text(
          "Avr",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 5:
        return Text(
          "Mai",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 6:
        return Text(
          "Jun",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 7:
        return Text(
          "Jul",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 8:
        return Text(
          "Au",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 9:
        return Text(
          "Sep",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 10:
        return Text(
          "Oct",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 11:
        return Text(
          "Nov",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      case 12:
        return Text(
          "Dec",
          style: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
        );
      default:
        return const Text("");
    }
  }
}