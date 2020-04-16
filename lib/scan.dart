import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:qrscan/components/QrDialog.dart';

class Scanner extends StatefulWidget {
  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<Scanner> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool btnLoading = false;
  bool readyToScan = false;

  void handleStatus({statusId, isFailure = false}){
    String result = '';
    if(isFailure){
      result = 'Something Went Wrong';
      statusId = 0;
    }else{
      if(statusId == 1){
        result = 'Received';
      }else if(statusId == 0){
        result = 'Not Received';
      }else{
        result = 'Invalid ID';
      }
    }
    scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text('$result'),
        duration: Duration(seconds: 2),
        backgroundColor: statusId == 1 ? Colors.lightGreen : Colors.red
      )
    );
  }

  Future sendRequest(qrString) async {
    String url = 'https://comsci.app/meegin/qrscan/checkreceive.php?id=$qrString';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = convert.jsonDecode(response.body);
      var statusId = data['statusid'];
      handleStatus(statusId:statusId,isFailure:false);
    } else {
      handleStatus(statusId:0,isFailure:true);
    }
  }

  Future handleScan(qrString) async {
    Navigator.of(context).pop();
    setState((){
      btnLoading = true;
    });
    await sendRequest(qrString);
    Timer(Duration(seconds: 2),(){
      scaffoldKey.currentState.removeCurrentSnackBar();
      setState(() {
        btnLoading = false;
        readyToScan = true;
      });
    });
  }

  void renderQrDialog() {
    setState((){
      readyToScan = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => QrDialog(
        dialogTitle: 'SCAN YOUR QRCODE',
        onGetResult: (result) async {
          // if (readyToScan){
          //   setState(() {
          //     readyToScan = false;
          //   });
            await handleScan(result);
          // }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.blue.shade500,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.55,
              // padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30,),
                    Image.asset('assets/qrholder.png'),
                    SizedBox(height: 10,),
                    MaterialButton( 
                      minWidth: 225,
                      height: 50, 
                      color: btnLoading ? Colors.grey : Theme.of(context).primaryColor, 
                      textColor: Colors.white, 
                      splashColor: btnLoading ? Colors.grey : Colors.blue.shade800,
                      child: Text('Scan1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,color: Colors.white)),
                      // onPressed: () => btnLoading ? null : renderQrDialog(),
                      onPressed: () => btnLoading ? null : sendRequest('1'),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}