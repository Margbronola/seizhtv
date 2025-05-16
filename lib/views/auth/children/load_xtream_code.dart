// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../globals/data.dart';
import '../../../globals/labeled_textfield.dart';
import '../../../globals/loader.dart';
import '../../../globals/logo.dart';
import '../../../globals/palette.dart';
import '../../../m3u/m3u_handler.dart';
import '../../../models/source.dart';

class LoadXtreamCodePage extends StatefulWidget {
  const LoadXtreamCodePage({super.key});

  @override
  State<LoadXtreamCodePage> createState() => _LoadXtreamCodePageState();
}

class _LoadXtreamCodePageState extends State<LoadXtreamCodePage> {
  final GlobalKey<FormState> kForm = GlobalKey<FormState>();
  final M3uFirestoreServices _service = M3uFirestoreServices();
  late final TextEditingController _sourceName, _username, _password, _url;
  var date = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    _sourceName = TextEditingController();
    _username = TextEditingController();
    _password = TextEditingController();
    _url = TextEditingController();
    date = DateTime(date.year, date.month + 1, date.day);
    super.initState();
  }

  @override
  void dispose() {
    _sourceName.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade800,
            body: Container(
              decoration: BoxDecoration(gradient: ColorPalette().gradient),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: "auth-logo",
                    child: LogoSVG(bottomText: "Load_your_source".tr()),
                  ),
                  Form(
                    key: kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _sourceName,
                          label: "Source_Name".tr(),
                          hinttext: "Type your Source Name",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          controller: _username,
                          label: "Username".tr(),
                          hinttext: "Type your username",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          isPassword: true,
                          controller: _password,
                          label: "Password".tr(),
                          hinttext: "Type your password",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        LabeledTextField(
                          controller: _url,
                          label: "URL",
                          hinttext: "http://url_here.com:port",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    onPressed: () async {
                      // FocusScope.of(context).unfocus();
                      print(_url.text);
                      print(_username.text);
                      print(_password.text);
                      print("SOURCE");
                      print(
                        "${_url.text}/get.php?username=${_username.text}&password=${_password.text}&type=m3u_plus&output=mpegts",
                      );

                      fetchM3u(_username.text, _password.text, _url.text).then((
                        value,
                      ) {
                        if (value.contains("Access Denied") ||
                            value.contains("access denied")) {
                          Fluttertoast.showToast(msg: value);
                        } else {
                          Navigator.of(context).pop();
                        }
                      });

                      // final String source =
                      //     "${_url.text}/get.php?username=${_username.text}&password=${_password.text}&type=m3u_plus";
                      // try {
                      //   await _service.firestore
                      //       .collection("user-source")
                      //       .doc(refId)
                      //       .set({
                      //         "sources": FieldValue.arrayUnion([
                      //           M3uSource(
                      //             source: source,
                      //             isFile: false,
                      //             name: _sourceName.text,
                      //           ).toJson(),
                      //         ]),
                      //       }, SetOptions(merge: true));
                      //   Navigator.of(context).pop();
                      //   _sourceName.clear();
                      //   _url.clear();
                      //   _username.clear();
                      //   _password.clear();
                      // } catch (e, s) {
                      //   print("errorrrr $e");
                      //   print("errorrrr $s");
                      // }
                    },
                    color: ColorPalette().orange,
                    height: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 5),
                        Text("Add_Source".tr()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    height: 50,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        "Cancel".tr(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            const Positioned.fill(child: SeizhTvLoader(opacity: .7)),
          },
        ],
      ),
    );
  }

  Future<String> fetchM3u(
    String username,
    String password,
    String urlPassed,
  ) async {
    print("FETCHING M3UUUUU");
    final url = Uri.parse(urlPassed);

    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      },
    );

    print("RESPONSE: ${response.body}");
    print("RESPONSE: ${response.reasonPhrase}");
    print("RESPONSE: ${response.statusCode}");

    if (response.statusCode == 200) {
      return response.body;
    } else {
      Fluttertoast.showToast(msg: "Failed to load M3U");
      throw Exception('Failed to load M3U');
    }
  }
}
