import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=fc97f6bb";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  var dolarControler = TextEditingController();
  var realControler = TextEditingController();
  var euroControler = TextEditingController();

  void changeReal(String text) {
    var real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsPrecision(2);
    euroControler.text = (real / euro).toStringAsPrecision(2);
  }

  void changeDolar(String text) {
    var dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsPrecision(2);
    euroControler.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void changeEuro(String text) {
    var euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsPrecision(2);
    euroControler.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  void reset() {
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: reset)
        ],
        backgroundColor: Colors.amber,
        title: Text(
          "Conversor de Moedas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case (ConnectionState.none):
              case (ConnectionState.waiting):
                return Center(
                    child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Erro ao carregar os dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.attach_money,
                              size: 150.0, color: Colors.amber),
                          buildTextField(
                              "Reais", "R\$ ", realControler, changeReal),
                          Divider(),
                          buildTextField(
                              "Dólares", "USD ", dolarControler, changeDolar),
                          Divider(),
                          buildTextField(
                              "Euro", "Eur ", euroControler, changeEuro)
                        ],
                      ));
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController ctrl, Function f) {
  return TextFormField(
      onChanged: f,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          prefixText: prefix,
          border: OutlineInputBorder()),
      controller: ctrl,
      style: TextStyle(color: Colors.amber));
}

Future<Map> getData() async {
  var response = await http.get(request);
  return json.decode(response.body);
}
