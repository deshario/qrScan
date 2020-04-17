import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:qrscan/components/ScannerOverlay.dart';

class QrScanner extends StatefulWidget {
  
  final ValueChanged<String> onGetResult;
  final String qrTitle;

  QrScanner({
    Key key,
    @required this.qrTitle,
    @required this.onGetResult,
  }) : super(key: key);

  @override
  QrScannerState createState() => QrScannerState();
}

class QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            overlay: ScannerOverlay(
              borderColor: Colors.white,
              borderLength: 40,
              borderWidth: 5,
              cutOutSize: 270
            ),
            onQRViewCreated: _onQRViewCreate
          ),
          Positioned(
            top: 80,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text(widget.qrTitle,
                  style: TextStyle(color: Colors.white, fontFamily: 'Helvethaica', fontSize: 30, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      widget.onGetResult(scanData);
    });
  }
}