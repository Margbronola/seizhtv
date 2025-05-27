// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extension/color.dart';
import 'package:seizhtv/extension/list.dart';
import 'package:seizhtv/extension/state.dart';
import 'package:seizhtv/views/landing_page/xtream_pages/live/xtream_live_list.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../data_containers/loaded_m3u_data.dart';
import '../../../globals/data.dart';
import '../../../globals/loader.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../globals/video_loader.dart';
import '../../../m3u/categorized_m3u_data.dart';
import '../../../m3u/classified_data.dart';
import '../../../m3u/m3u_entry.dart';
import '../../../m3u/zm3u_handler.dart';
import '../../../models/xtreams_models/category.dart';
import '../../../models/xtreams_models/xtream_data.dart';
import '../../../services/xtream_api.dart';
import '../../../viewmodel/xtream_category_vm.dart';
import 'live/xtream_live_category.dart';
import 'live/xtream_live_favorite.dart';
import 'live/xtream_live_history.dart';

class XtreamLivePage extends StatefulWidget {
  const XtreamLivePage({super.key});

  @override
  State<XtreamLivePage> createState() => _XtreamLivePageState();
}

class _XtreamLivePageState extends State<XtreamLivePage> {
  late final StreamSubscription<CategorizedM3UData> _streamer;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final Favorites _favvm = Favorites.instance;
  final History _hisvm = History.instance;
  late List<ClassifiedData> sdata = [];
  late List<String> categoryName = [
    "ALL (${liveXtreamData.isEmpty ? "" : liveXtreamData.length})",
  ];
  final TextEditingController _search = TextEditingController();
  late List<XtreamDataModel> displayData = [];
  late List<XtreamDataModel> categoryFilteredData = [];
  String searchText = "";
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  late int categoryId;
  late final ScrollController scrollController;
  late final TextEditingController search;
  final XtreamCategoryViewModel _catvm = XtreamCategoryViewModel.instance;
  bool showSearchField = false;
  String dropdownvalue = "";
  bool categorysearch = false;
  bool selected = true;
  bool update = false;
  int prevIndex = 1;
  int? ind = 0;

  initXtreamCategory() {
    _catvm.stream.listen((event) {
      xtreamLiveCategory = event;
      for (final CategoryModel cdata in xtreamLiveCategory) {
        categoryName.add(cdata.name);
      }
      categoryName.toSet().toList();
      categoryName.sort((a, b) => a.compareTo(b));
      for (final String label in categoryName) {
        if (label.contains(
          "ALL (${liveXtreamData.isEmpty ? "" : liveXtreamData.length})",
        )) {
          dropdownvalue = label;
        }
      }
      if (mounted) setState(() {});
    });
  }

  fetchFav() async {
    // await _handler
    //     .getDataFrom(type: CollectionType.favorites, refId: refId!)
    //     .then((value) {
    //       if (value != null) {
    //         _favvm.populate(value);
    //       }
    //     });
  }

  fetchHis() async {
    // await _handler
    //     .getDataFrom(type: CollectionType.history, refId: refId!)
    //     .then((value) {
    //       if (value != null) {
    //         _hisvm.populate(value);
    //       }
    //     });
  }

  initFavStream() {
    // _favvm.stream.listen((event) {
    //   _favdata = List.from(event.live);
    //   favData = _favdata.expand((element) => element.data).toList();
    // });
  }

  initHisStream() {
    // _hisvm.stream.listen((event) {
    //   _hisdata = List.from(event.live);
    //   hisData = _hisdata.expand((element) => element.data).toList();
    // });
  }

  fetchxtream() async {
    await XtreamApi()
        .getLiveStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            liveXtreamData = value!;
          });
        });
    await XtreamApi()
        .getLiveCategoryStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            xtreamLiveCategory = value!;
          });
        });
  }

  @override
  void initState() {
    scrollController = ScrollController();
    search = TextEditingController();
    showSearchField = false;
    initXtreamCategory();
    fetchxtream();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    search.dispose();
    _streamer.cancel();
    showSearchField = false;
    super.dispose();
  }

  final GlobalKey<XtreamLiveListPageState> _kList =
      GlobalKey<XtreamLiveListPageState>();
  final GlobalKey<XtreamLiveFavoritePageState> _favPage =
      GlobalKey<XtreamLiveFavoritePageState>();
  final GlobalKey<XtreamLiveHistoryPageState> _hisPage =
      GlobalKey<XtreamLiveHistoryPageState>();
  final GlobalKey<XtreamLiveCategoryPageState> _catPage =
      GlobalKey<XtreamLiveCategoryPageState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorPalette().card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(
            1,
            onSearchPressed: () async {
              showSearchField = !showSearchField;

              if (showSearchField == true) {
                if (ind == 0) {
                  if (dropdownvalue.contains("ALL") || dropdownvalue == "") {
                    categorysearch = false;
                  } else {
                    categorysearch = true;
                  }
                } else {
                  categorysearch = false;
                }
              }
              print("CATEGORY SEARCH: $categorysearch");
              if (mounted) setState(() {});
            },
            onUpdateChannel: () {
              setState(() {
                update = true;
                Future.delayed(const Duration(seconds: 6), () {
                  setState(() {
                    update = false;
                  });
                });
              });
            },
          ),
        ),
        body: Stack(
          children: [
            liveXtreamData.isEmpty
                ? SeizhTvLoader(
                    label: Text(
                      "Retrieving_data".tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ind == 0
                                  ? Container(
                                      width: 270,
                                      height: 50,
                                      padding: const EdgeInsets.all(10),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: ind == 0
                                            ? ColorPalette().topColor
                                            : ColorPalette().highlight,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ind == 0
                                              ? ColorPalette().topColor
                                              : Colors.grey,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            prevIndex = ind!;
                                            ind = 0;
                                            showSearchField = false;
                                            print("CURRENT INDEX $ind");
                                            print("PREV INDEX $prevIndex");
                                          });
                                        },
                                        child: ind == 0 && prevIndex != 0
                                            // ? DropdownButtonHideUnderline(
                                            //     child: DropdownButton2(
                                            //       isExpanded: true,
                                            //       items: categoryName
                                            //           .map(
                                            //             (String item) =>
                                            //                 DropdownMenuItem<
                                            //                   String
                                            //                 >(
                                            //                   value: item,
                                            //                   child: Text(
                                            //                     item,
                                            //                     maxLines: 1,
                                            //                     overflow:
                                            //                         TextOverflow
                                            //                             .ellipsis,
                                            //                   ),
                                            //                 ),
                                            //           )
                                            //           .toList(),
                                            //       value: dropdownvalue == ""
                                            //           ? categoryName == []
                                            //                 ? ""
                                            //                 : categoryName.first
                                            //           : dropdownvalue,
                                            //       onChanged: (value) {
                                            //         setState(() {
                                            //           dropdownvalue = value!;
                                            //           print(
                                            //             "DROPDOWN VALUE: $dropdownvalue",
                                            //           );
                                            //           for (CategoryModel cm
                                            //               in xtreamLiveCategory) {
                                            //             if (dropdownvalue ==
                                            //                 cm.name) {
                                            //               print(
                                            //                 "ID: ${cm.id} - ${cm.name}",
                                            //               );
                                            //               for (XtreamDataModel
                                            //                   liveData
                                            //                   in liveXtreamData) {
                                            //                 if (liveData
                                            //                         .categoryId ==
                                            //                     cm.id) {
                                            //                   data.add(
                                            //                     liveData,
                                            //                   );
                                            //                 }
                                            //               }
                                            //             }
                                            //           }
                                            //           print(
                                            //             "CATEGORY LIVE LENGHHT: ${data.length}",
                                            //           );
                                            //           categorydata = data;
                                            //           showSearchField = false;
                                            //           categorysearch = false;
                                            //         });
                                            //       },
                                            //     ),
                                            //   )
                                            ? DropdownButton(
                                                elevation: 0,
                                                isExpanded: true,
                                                padding: const EdgeInsets.all(
                                                  0,
                                                ),
                                                underline: Container(),
                                                onTap: () {
                                                  setState(() {
                                                    selected = true;
                                                    ind = 0;
                                                  });
                                                },
                                                items: categoryName.map((
                                                  value,
                                                ) {
                                                  return DropdownMenuItem(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }).toList(),
                                                value: dropdownvalue == ""
                                                    ? categoryName == []
                                                          ? ""
                                                          : categoryName.first
                                                    : dropdownvalue,
                                                style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    dropdownvalue = value!;
                                                    print(
                                                      "DROPDOWN VALUE: $dropdownvalue",
                                                    );
                                                    for (CategoryModel cm
                                                        in xtreamLiveCategory) {
                                                      if (dropdownvalue ==
                                                          cm.name) {
                                                        print(
                                                          "ID: ${cm.id} - ${cm.name}",
                                                        );
                                                        categoryId = int.parse(
                                                          cm.id,
                                                        );
                                                        XtreamApi()
                                                            .getLiveFilterdByCategory(
                                                              baseUrl:
                                                                  "${server!.serverProtocol}://${server!.url}:${server!.port}",
                                                              username:
                                                                  userInfo!
                                                                      .username,
                                                              password:
                                                                  userInfo!
                                                                      .password,
                                                              categoryId:
                                                                  categoryId,
                                                            )
                                                            .then((value) {
                                                              setState(() {
                                                                print(
                                                                  "VALUE LENGHT: ${value!.length}",
                                                                );
                                                                categoryFilteredData =
                                                                    value;
                                                              });
                                                            });
                                                      }
                                                    }
                                                  });
                                                  showSearchField = false;
                                                  categorysearch = false;
                                                },
                                              )
                                            : Text(
                                                dropdownvalue,
                                                style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                ),
                                              ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prevIndex = ind!;
                                          ind = 0;
                                          showSearchField = false;
                                          print("CURRENT INDEX $ind");
                                          print("PREV INDEX $prevIndex");
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.all(10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: ind == 0
                                              ? ColorPalette().topColor
                                              : ColorPalette().highlight,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: ind == 0
                                                ? ColorPalette().topColor
                                                : Colors.grey,
                                          ),
                                        ),
                                        child: ind == 0 && prevIndex != 0
                                            ? Expanded(
                                                child: DropdownButton(
                                                  elevation: 0,
                                                  isExpanded: true,
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  underline: Container(),
                                                  onTap: () {
                                                    setState(() {
                                                      selected = true;
                                                      ind = 0;
                                                    });
                                                  },
                                                  items: categoryName!.map((
                                                    value,
                                                  ) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        // maxLines: 1,
                                                        // overflow:
                                                        //     TextOverflow.ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: dropdownvalue == ""
                                                      ? categoryName == []
                                                            ? ""
                                                            : categoryName
                                                                  ?.first
                                                      : dropdownvalue,
                                                  style: const TextStyle(
                                                    fontFamily: "Poppins",
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dropdownvalue = value!;
                                                      print(
                                                        "DROPDOWN VALUE: $dropdownvalue",
                                                      );
                                                      for (CategoryModel cm
                                                          in xtreamLiveCategory) {
                                                        if (dropdownvalue ==
                                                            cm.name) {
                                                          print(
                                                            "ID: ${cm.id} - ${cm.name}",
                                                          );
                                                          categoryId =
                                                              int.parse(cm.id);
                                                        }
                                                      }
                                                      showSearchField = false;
                                                      categorysearch = false;
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(
                                                dropdownvalue,
                                                style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                ),
                                              ),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    prevIndex = ind!;
                                    ind = 1;
                                    showSearchField = false;
                                    print("CURRENT INDEX $ind");
                                    print("PREV INDEX $prevIndex");
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: ind == 1
                                        ? ColorPalette().topColor
                                        : ColorPalette().highlight,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: ind == 1
                                          ? ColorPalette().topColor
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Text(
                                    "${"favorites".tr().toUpperCase()} (${favData.length})",
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    prevIndex = ind!;
                                    ind = 2;
                                    showSearchField = false;
                                    print("CURRENT INDEX $ind");
                                    print("PREV INDEX $prevIndex");
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: ind == 2
                                        ? ColorPalette().topColor
                                        : ColorPalette().highlight,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: ind == 2
                                          ? ColorPalette().topColor
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Text(
                                    "${"Channels_History".tr().toUpperCase()} (${hisData.length})",
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      categorysearch == false
                          ? AnimatedPadding(
                              duration: const Duration(milliseconds: 400),
                              padding: EdgeInsets.symmetric(
                                horizontal: showSearchField ? 20 : 0,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: showSearchField ? 50 : 0,
                                width: double.maxFinite,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorPalette().highlight,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorPalette().highlight
                                                  .darken()
                                                  .withOpacity(1),
                                              offset: const Offset(2, 2),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/search.svg",
                                              height: 20,
                                              width: 20,
                                              color: ColorPalette().white,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                child: showSearchField
                                                    ? TextField(
                                                        onChanged: (text) {
                                                          if (_kList
                                                                  .currentState !=
                                                              null) {
                                                            _kList.currentState!
                                                                .search(text);
                                                          }
                                                          // else if (_catPage
                                                          //         .currentState !=
                                                          //     null) {
                                                          //   _catPage
                                                          //       .currentState!
                                                          //       .search(text);
                                                          // }
                                                          else if (_favPage
                                                                  .currentState !=
                                                              null) {
                                                            _favPage
                                                                .currentState!
                                                                .search(text);
                                                          } else if (_hisPage
                                                                  .currentState !=
                                                              null) {
                                                            _hisPage
                                                                .currentState!
                                                                .search(text);
                                                          }
                                                          if (mounted) {
                                                            setState(() {});
                                                          }
                                                        },
                                                        cursorColor:
                                                            ColorPalette()
                                                                .orange,
                                                        controller: search,
                                                        decoration:
                                                            InputDecoration(
                                                              hintText: "Search"
                                                                  .tr(),
                                                            ),
                                                      )
                                                    : Container(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _kList.currentState?.search("");
                                          // _catPage.currentState?.search("");
                                          _favPage.currentState?.search("");
                                          _hisPage.currentState?.search("");
                                          search.text = "";
                                          showSearchField = !showSearchField;
                                        });
                                      },
                                      child: Text(
                                        "Cancel".tr(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      if (showSearchField) ...{const SizedBox(height: 20)},
                      Expanded(
                        child: Scrollbar(
                          controller: scrollController,
                          child: ind == 0
                              ? dropdownvalue.contains("ALL") ||
                                        dropdownvalue == ""
                                    ? XtreamLiveListPage(
                                        key: _kList,
                                        data: liveXtreamData,
                                        controller: scrollController,
                                        onPressed:
                                            (XtreamDataModel entry) async {
                                              print("ON PRESS DATA: $entry");
                                              // entry.addToHistory(refId!);
                                              await VideoLoader().loadVideo(
                                                context,
                                                link: "${entry.streamId}",
                                                title: entry.name ?? "",
                                                type: entry.type,
                                                image: entry.icon,
                                                fromXtream: true,
                                              );
                                            },
                                        onUpdateCallback: (item) {
                                          setState(() {
                                            print("Valueee: $item");
                                          });
                                        },
                                      )
                                    : XtreamLiveCategoryPage(
                                        key: _catPage,
                                        category: categoryFilteredData,
                                        showsearchfield: categorysearch,
                                        onUpdateCallback: (item) {
                                          setState(() {
                                            print("Valueee: $item");
                                          });
                                        },
                                      )
                              : ind == 1
                              ? XtreamLiveFavoritePage(
                                  key: _kList,
                                  data: [],
                                  onPressed: (XtreamDataModel entry) async {
                                    await VideoLoader().loadVideo(
                                      context,
                                      link: "${entry.streamId}",
                                      title: entry.name ?? "",
                                      type: entry.type,
                                      image: entry.icon,
                                      fromXtream: true,
                                    );
                                  },
                                  onUpdateCallback: (item) {
                                    setState(() {
                                      print("Valueee: $item");
                                    });
                                  },
                                )
                              : XtreamLiveHistoryPage(
                                  key: _kList,
                                  data: [],
                                  onPressed: (XtreamDataModel entry) async {
                                    await VideoLoader().loadVideo(
                                      context,
                                      link: "${entry.streamId}",
                                      title: entry.name ?? "",
                                      type: entry.type,
                                      image: entry.icon,
                                      fromXtream: true,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
            update == true ? UIAdditional().loader() : Container(),
          ],
        ),
      ),
    );
  }
}
