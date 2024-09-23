import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:salespulse/utils/app_size.dart';


class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});
  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff001c30),
      appBar: AppBar(
        backgroundColor: const Color(0xff001c30),
        leading: IconButton(onPressed: ()=> Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_rounded, size:AppSizes.iconLarge, color: Colors.orange,)),
        title: Text('Scanner QR Code',style: GoogleFonts.roboto(fontSize: AppSizes.fontLarge, color: Colors.orange),),
      ),
      body: Column(
        children: [
           Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.orange,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(qrText != null ? 'Résultat : $qrText' : 'Scanne un code QR', style: GoogleFonts.roboto(fontSize: AppSizes.fontLarge, fontWeight: FontWeight.bold, color: Colors.orange),),
            ),
          ),
        ],
      ),
      
    );
    
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code;
      });
    });
  }

}
