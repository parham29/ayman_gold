import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class UserRepository {
  Map data;

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    Map<String, String> body = {
      'email': username,
      'password': password
    };
    Map<String, String> requestHeaders = {
      'Accept': 'application/json'
    };
    http.Response response =
        await http.post("http://aymangold.com/public/api/v1/login", body: body, headers: requestHeaders);


    if (response.statusCode != 200) {
      String error = "Unknown Error";
      if (json.decode(response.body)["status"] == "error") {
        error = json.decode(response.body)["data"];
      }
      else if (json.decode(response.body)["message"] == "The given data was invalid."){
        var list = json.decode(response.body)["errors"]["email"];
        String newError = "";
        for(var i = 0; i < list.length; i++){
          newError = newError + list[i] + " ";
        }
        error = newError;
      }

      throw http.ClientException(error);
    } else {
      data = json.decode(response.body);
      return data["data"]["api_token"];
    }
  }

  Future<void> deleteToken() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: "token");
    return;
  }

  Future<void> persistToken(String token) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: "token", value: token);
    return;
  }

  Future<bool> hasToken() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: "token");
    if (value == null)
      return false;
    else
      return true;
  }
}
