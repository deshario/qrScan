import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:qrscan/components/QrScanner.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String scannedText = '';

  void showSnack({statusId, isFailure = false}){
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
      showSnack(statusId:statusId,isFailure:false);
    } else {
      showSnack(statusId:0,isFailure:true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: QrScanner(
                qrTitle: 'Scan your qr',
                onGetResult: (result) async { // Continous Loop
                  if (scannedText != result){ // Scan New Only
                    setState(() {
                      scannedText = result;
                    });
                    await sendRequest(result);
                  }
                },
              )
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Result : $scannedText', style: TextStyle(fontSize: 22)),
                ],
              )
            ),
          )
        ],
      )
      )
    );
  }
}