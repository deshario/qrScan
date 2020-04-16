import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrscan/components/ScannerOverlay.dart';

class QrDialog extends StatefulWidget {

  final String dialogTitle;
  final ValueChanged<String> onGetResult;

  QrDialog({
    @required this.dialogTitle,
    @required this.onGetResult
  });

  @override
  QrDialogState createState() => QrDialogState();
}

class QrDialogState extends State<QrDialog> {
  final GlobalKey mqrKey = GlobalKey(debugLabel: 'mQR');

  QRViewController controller;

  Dialog dialogContent(mContext) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.65,
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Container(
                height: 30,
                child: Text('${widget.dialogTitle}',style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
              ),
            ),
            Expanded(
              child: QRView(
                key: GlobalKey(debugLabel: 'myScanner'),
                overlay: ScannerOverlay(
                  borderColor: Colors.white,
                  borderLength: 40,
                  borderWidth: 5,
                  cutOutSize: 300
                ),
                onQRViewCreated: _onQRViewCreate
              ),
            ),
          ],
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dialogContent(context);
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
