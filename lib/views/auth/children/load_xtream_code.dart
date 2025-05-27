// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import '../../../globals/data.dart';
import '../../../globals/data_cacher.dart';
import '../../../globals/labeled_textfield.dart';
import '../../../globals/loader.dart';
import '../../../globals/logo.dart';
import '../../../globals/palette.dart';
import '../../../models/xtreams_models/server_info.dart';
import '../../../models/xtreams_models/user_info.dart';
import '../../../services/xtream_api.dart';
import '../../landing_page/main_landing_page.dart';

class LoadXtreamCodePage extends StatefulWidget {
  const LoadXtreamCodePage({super.key});

  @override
  State<LoadXtreamCodePage> createState() => _LoadXtreamCodePageState();
}

class _LoadXtreamCodePageState extends State<LoadXtreamCodePage> {
  final GlobalKey<FormState> kForm = GlobalKey<FormState>();
  late final TextEditingController _sourceName, _username, _password, _url;
  final DataCacher _cacher = DataCacher.instance;
  bool isLoading = false;

  @override
  void initState() {
    _sourceName = TextEditingController();
    _username = TextEditingController();
    _password = TextEditingController();
    _url = TextEditingController();
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
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade800,
            body: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(gradient: ColorPalette().gradient),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: "auth-logo",
                    child: LogoSVG(bottomText: "Login with XTREAM Codes API"),
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
                          label: "XTREAM Code Username",
                          hinttext: "Type your XTREAM Code username",
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
                          label: "XTREAM Code Password",
                          hinttext: "Type your XTREAM Code password",
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
                      print(_url.text);
                      print(_username.text);
                      print(_password.text);
                      print("SOURCE");
                      // print(
                      //   "${_url.text}/get.php?username=${_username.text}&password=${_password.text}&type=m3u_plus&output=mpegts",
                      // );
                      setState(() {
                        isLoading = true;
                        _cacher.removeFile();
                      });

                      // XtreamApi()
                      //     .getStreamM3u(
                      //       baseUrl: _url.text,
                      //       username: _username.text,
                      //       password: _password.text,
                      //     )
                      //     .then((value) {
                      //       parseM3U("$value");
                      //     });

                      XtreamApi()
                          .getUserInfo(
                            baseUrl: _url.text,
                            username: _username.text,
                            password: _password.text,
                          )
                          .then((value) {
                            print("XTREAM LOGIN VALUE: $value");
                            print("XTREAM USER INFO: ${value!['user_info']}");
                            print(
                              "XTREAM SERVER INFO: ${value['server_info']}",
                            );

                            setState(() {
                              file = null;
                              userInfo = UserInfoModel.fromJson(
                                value['user_info'],
                              );
                              server = ServerInfoModel.fromJson(
                                value['server_info'],
                              );
                              _cacher.saveXtreamUser(userInfo!);
                              _cacher.saveXtreamServer(server!);
                            });
                          })
                          .whenComplete(() {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: MainLandingPage(isXtreamCode: true),
                                type: PageTransitionType.rightToLeft,
                              ),
                            );
                          });
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            // Navigator.of(context).pop();
                          },
                          height: 50,
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              "Connect VPN",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            // Navigator.of(context).pop();
                          },
                          height: 50,
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              "List Users",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  const SizedBox(height: 50),
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

  // List<Map<String, String>> parseM3U(String content) {
  //   final lines = content.split('\n');
  //   List<Map<String, String>> channels = [];

  //   for (int i = 0; i < lines.length; i++) {
  //     if (lines[i].startsWith('#EXTINF')) {
  //       String info = lines[i];
  //       String url = (i + 1 < lines.length) ? lines[i + 1].trim() : '';
  //       channels.add({'info': info, 'url': url});
  //     }
  //   }

  //   print("CHANNELS AVAILABLE: $channels");

  //   return channels;
  // }
}
