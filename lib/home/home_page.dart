import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_bloc/authentication/authentication.dart';
import 'package:flutter_login_bloc/form/form.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List orders;
  AuthenticationBloc authenticationBloc;
  bool loaded = false;

  Future getData() async {
    setState(() {
      loaded = false;
    });
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: "token");
    Map<String, String> requestHeaders = {'Accept': 'application/json'};
    http.Response response = await http.get(
        "http://aymangold.com/public/api/v1/orders?api_token=$token",
        headers: requestHeaders);
    if (response.statusCode != 200) {
      authenticationBloc.dispatch(LoggedOut());
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('لطفا اطلاعات را مجددا بررسی کنید'),
          backgroundColor: Colors.red));
    }
    List ordersd = json.decode(response.body);
    setState(() {
      loaded = true;
      orders = ordersd;
    });
  }

  Future delete(int id) async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: "token");
    Map<String, String> requestHeaders = {'Accept': 'application/json'};
    http.Response response = await http.delete(
        "http://aymangold.com/public/api/v1/orders/$id?api_token=$token",
        headers: requestHeaders);
    if (response.statusCode != 200) {
      authenticationBloc.dispatch(LoggedOut());
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('لطفا اطلاعات را مجددا بررسی کنید'),
          backgroundColor: Colors.red));
    }
    print(response.body);
    getData();
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title:
              const Text('Ayman Gold', style: TextStyle(color: Colors.white))),
      body: Container(
        child: Center(
          child: loaded == true
              ? ListView.builder(
                  itemCount: orders == null ? 0 : orders.length,
                  padding: EdgeInsets.only(bottom: 35),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if ((orders[index]["ready_date"]) == "0") {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RichAlertDialog(
                                  alertTitle: richTitle("مطمئن هستید؟!"),
                                  alertSubtitle: richSubtitle(
                                      "پس از تایید سفارش شما حذف خواهد شد"),
                                  alertType: RichAlertType.WARNING,
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("بله"),
                                      onPressed: () {
                                        delete(orders[index]["id"]);
                                        Navigator.pop(context);

                                      },
                                    ),
                                    FlatButton(
                                      child: Text("خیر"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      child: Card(
                        margin: EdgeInsets.only(right: 10, left: 10, top: 10),
                        color: Color(0xfffeb204),
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage:  AssetImage(
                                    'icon/ring.png'),
                              ),
                              Flexible(
                                  child: new Container(
                                padding: const EdgeInsets.only(right: 10),
                                child: AutoSizeText(
                                  "${orders[index]["name"]}\n${orders[index]["type"]}\n${orders[index]["color"]}\n${orders[index]["size"]}\n${orders[index]["numbers"]}\n${(orders[index]["ready_date"]) == "0" ? "تاریخ آماده سازی به زودی اعلام میشود" : "${(orders[index]["ready_date"])}"}",
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text('اضافه کردن سفارش'),
        backgroundColor: Color(0xffff8503),
        onPressed: () {
          navigateToSubPage(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                authenticationBloc.dispatch(LoggedOut());
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                getData();
              },
            )
          ],
        ),
      ),
    );
  }

  Future navigateToSubPage(context) async {
    String message = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => form()));
    if (message == "comeback") {
      getData();
    } else {}
  }
}
