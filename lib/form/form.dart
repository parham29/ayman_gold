import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class form extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubmitForm();
  }
}

class SubmitForm extends State<form> {
  final _formKey2 = GlobalKey<FormState>();
  bool _isDis = false;

  //type color size number
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _numberController = TextEditingController();

  Future<bool> submit() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: "token");
    Map<String, String> body = {
      'name': _nameController.text,
      'type': _typeController.text,
      'color': _colorController.text,
      'size': _sizeController.text,
      'numbers': _numberController.text
    };
    Map<String, String> requestHeaders = {'Accept': 'application/json'};
    http.Response response = await http.post(
        "http://aymangold.com/public/api/v1/orders?api_token=$token",
        body: body,
        headers: requestHeaders);
    print("response: ${response.statusCode}");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title:
              const Text('ثبت سفارش', style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'نام'),
                  controller: _nameController,
                  validator: (value) {
                    if (value.length < 1) {
                      return 'فیلد نام الزامی است';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'نوع'),
                  controller: _typeController,
                  validator: (value) {
                    if (value.length < 1) {
                      return 'فیلد نوع الزامی است';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'رنگ'),
                  controller: _colorController,
                  validator: (value) {
                    if (value.length < 1) {
                      return 'فیلد رنگ الزامی است';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'سایز'),
                  controller: _sizeController,
                  validator: (value) {
                    if (value.length < 1) {
                      return 'فیلد سایز الزامی است';
                    }
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'تعداد'),
                  controller: _numberController,
                  validator: (value) {
                    if (value.length < 1) {
                      return 'فیلد تعداد الزامی است';
                    }
                  },
                ),
                SizedBox(height: 15),
                Container(
                  child: _isDis == true ? CircularProgressIndicator() : null,
                ),
                SizedBox(height: 15),
                Container(
                  child: _isDis == false
                      ? ButtonTheme(
                    minWidth: 200.0,
                    child:  RaisedButton(
                            color: Color(0xffA06D5A),
                            textColor: Colors.white,
                            onPressed: () {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              if (_formKey2.currentState.validate() &&
                                  _isDis == false) {
                                setState(() {
                                  _isDis = true;
                                });

                                submit().then((result) {
                                  setState(() {
                                    _isDis = false;
                                  });

                                  print(result);
                                  if (result) {
                                    Navigator.pop(context, "comeback");
                                  } else {
                                    Navigator.pop(context, "comeback failed");
                                  }
                                });
                              }
                            },
                            child: Text(
                              'ثبت',
                              style: TextStyle(fontSize: 25),
                            ),
                          )
                       ,
                  ):null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
