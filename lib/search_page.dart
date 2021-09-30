import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String secilenSehir = '';
  final myController = TextEditingController();

  void showDialoog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Hatalı Giriş Yaptınız.'),
                    ),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {Navigator.of(context).pop();},
                        child: Text(
                          "Kapat",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     decoration: BoxDecoration(
       image: DecorationImage(
           fit: BoxFit.cover,
           image: AssetImage('assets/search.jpg')),
     ),
      child: Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent,),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: TextField(
                  controller: myController   ,
                  //onChanged: (value){secilenSehir = value;},
                  decoration: InputDecoration(hintText: 'Şehir Yazınız.',
                              border: OutlineInputBorder(borderSide: BorderSide.none)),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              FlatButton(onPressed: ()async{
                var response = await http.get('https://www.metaweather.com/api/location/search/?query=${myController.text}');
                jsonDecode(response.body).isEmpty
                    ? showDialoog()
                    : Navigator.pop(context, myController.text);
              }, child: Text('Şehri Seçin.'),)
            ],
          ),
        ),
      ),
    );
  }
}


