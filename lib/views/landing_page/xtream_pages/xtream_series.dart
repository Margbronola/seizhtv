// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extension/color.dart';
import 'package:seizhtv/extension/state.dart';
import 'package:seizhtv/m3u/extension.dart';
import 'package:seizhtv/models/xtreams_models/xtream_series_data.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../data_containers/loaded_m3u_data.dart';
import '../../../globals/data.dart';
import '../../../globals/loader.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../m3u/classified_data.dart';
import '../../../m3u/zm3u_handler.dart';
import '../../../models/xtreams_models/category.dart';
import '../../../models/xtreams_models/xtream_data.dart';
import '../../../services/xtream_api.dart';
import '../../../viewmodel/xtream_category_vm.dart';
import 'series/xtream_series_category.dart';
import 'series/xtream_series_favorite.dart';
import 'series/xtream_series_history.dart';
import 'series/xtream_series_list.dart';

class XtreamSeriesPage extends StatefulWidget {
  const XtreamSeriesPage({super.key});

  @override
  State<XtreamSeriesPage> createState() => _XtreamSeriesPageState();
}

class _XtreamSeriesPageState extends State<XtreamSeriesPage> {
  late final ScrollController _scrollController;
  static final Favorites _fav = Favorites.instance;
  static final History _hisvm = History.instance;
  late final TextEditingController search;
  late List<ClassifiedData> _favdata = [];
  late List<ClassifiedData> _hisdata = [];
  final XtreamCategoryViewModel _catvm = XtreamCategoryViewModel.instance;
  late List<XtreamDataModel> xtreamCategorydata = [];
  List<CategoryModel> xtreamCategory = [];
  late List<XtreamSeriesDataModel> data = [];
  late List<XtreamSeriesDataModel> categorydata = [];
  bool showSearchField = false;
  bool update = false;
  late List<String>? categoryName = [
    "ALL (${seriesXtreamData.isEmpty ? "" : seriesXtreamData.length})",
  ];
  bool categorysearch = false;
  String dropdownvalue = "";
  String label = "";
  int ind = 0;
  bool selected = true;
  int prevIndex = 1;

  fetchFav() async {
    // await _handler
    //     .getDataFrom(type: CollectionType.favorites, refId: refId!)
    //     .then((value) {
    //       if (value != null) {
    //         _fav.populate(value);
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

  initXtreamCategory() {
    _catvm.stream.listen((event) {
      xtreamSeriesCategory = event;
      for (final CategoryModel cdata in xtreamSeriesCategory) {
        categoryName!.add(cdata.name);
      }
      categoryName!.toSet().toList();
      categoryName!.sort((a, b) => a.compareTo(b));
      for (final String label in categoryName!) {
        if (label.contains(
          "ALL (${seriesXtreamData.isEmpty ? "" : seriesXtreamData.length})",
        )) {
          dropdownvalue = label;
        }
      }
      if (mounted) setState(() {});
    });
  }

  initFavStream() {
    // _fav.stream.listen((event) {
    //   _favdata = List.from(event.series);
    //   favData = _favdata.expand((element) => element.data.classify()).toList();
    // });
  }

  initHisStream() {
    // _hisvm.stream.listen((event) {
    //   _hisdata = List.from(event.series);
    //   hisData = _hisdata.expand((element) => element.data.classify()).toList();
    // });
  }

  fetchxtream() async {
    await XtreamApi()
        .getSeriesCategoryStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            xtreamSeriesCategory = value!;
          });
        });
    await XtreamApi()
        .getSeriesStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            seriesXtreamData = value!;
          });
        });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    search = TextEditingController();
    fetchxtream();
    initXtreamCategory();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<XtreamSeriesListPageState> _kList =
      GlobalKey<XtreamSeriesListPageState>();
  final GlobalKey<XtreamSeriesFavoritePageState> _favPage =
      GlobalKey<XtreamSeriesFavoritePageState>();
  final GlobalKey<XtreamSeriesHistoryPageState> _hisPage =
      GlobalKey<XtreamSeriesHistoryPageState>();
  final GlobalKey<XtreamSeriesCategoryPageState> _catPage =
      GlobalKey<XtreamSeriesCategoryPageState>();

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
            3,
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
            seriesXtreamData.isEmpty
                ? SeizhTvLoader(
                    label: Text(
                      "Retrieving_data".tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
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
                                          prevIndex = ind;
                                          ind = 0;
                                          showSearchField = false;
                                          print("CURRENT INDEX $ind");
                                          print("PREV INDEX $prevIndex");
                                        });
                                      },
                                      child: ind == 0 && prevIndex != 0
                                          ? DropdownButton(
                                              elevation: 0,
                                              isExpanded: true,
                                              padding: const EdgeInsets.all(0),
                                              underline: Container(),
                                              onTap: () {
                                                setState(() {
                                                  selected = true;
                                                  ind = 0;
                                                });
                                              },
                                              items: categoryName!.map((value) {
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
                                                        : categoryName?.first
                                                  : dropdownvalue,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  dropdownvalue = value!;

                                                  for (CategoryModel cm
                                                      in xtreamSeriesCategory) {
                                                    if (dropdownvalue ==
                                                        cm.name) {
                                                      print(
                                                        "ID: ${cm.id} - ${cm.name}",
                                                      );
                                                      for (XtreamSeriesDataModel
                                                          seriesData
                                                          in seriesXtreamData) {
                                                        if (seriesData
                                                                .categoryId ==
                                                            cm.id) {
                                                          data.add(seriesData);
                                                        }
                                                      }
                                                    }
                                                  }
                                                  print(
                                                    "CATEGORY LIVE LENGHHT: ${data.length}",
                                                  );
                                                  categorydata = data;
                                                  showSearchField = false;
                                                  categorysearch = false;
                                                });
                                              },
                                            )
                                          : Text(
                                              dropdownvalue,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        prevIndex = ind;
                                        ind = 0;
                                        showSearchField = false;
                                        print("CURRENT INDEX $ind");
                                        print("PREV INDEX $prevIndex");
                                      });
                                    },
                                    child: Container(
                                      // width: 180,
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
                                      child: ind == 0 && prevIndex != 0
                                          ? DropdownButton(
                                              elevation: 0,
                                              isExpanded: true,
                                              padding: const EdgeInsets.all(0),
                                              underline: Container(),
                                              onTap: () {
                                                setState(() {
                                                  selected = true;
                                                  ind = 0;
                                                });
                                              },
                                              items: categoryName!.map((value) {
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
                                                        : categoryName![3]
                                                  : dropdownvalue,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  dropdownvalue = value!;
                                                  String result1 = dropdownvalue
                                                      .replaceAll(
                                                        RegExp(
                                                          r"[(]+[0-9]+[)]",
                                                        ),
                                                        '',
                                                      );
                                                  for (CategoryModel cm
                                                      in xtreamSeriesCategory) {
                                                    if (dropdownvalue ==
                                                        cm.name) {
                                                      print(
                                                        "ID: ${cm.id} - ${cm.name}",
                                                      );
                                                      for (XtreamSeriesDataModel
                                                          seriesData
                                                          in seriesXtreamData) {
                                                        if (seriesData
                                                                .categoryId ==
                                                            cm.id) {
                                                          data.add(seriesData);
                                                        }
                                                      }
                                                    }
                                                  }
                                                  print(
                                                    "CATEGORY LIVE LENGHHT: ${data.length}",
                                                  );
                                                  categorydata = data;
                                                  showSearchField = false;
                                                  categorysearch = false;
                                                });
                                              },
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
                                  prevIndex = ind;
                                  ind = 1;
                                  showSearchField = false;
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
                                  "${"favorites".tr().toUpperCase()} ()",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind;
                                  ind = 2;
                                  showSearchField = false;
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
                                  "${"Series History".toUpperCase()} ()",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
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
                                                          } else if (_favPage
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
                          controller: _scrollController,
                          child: ind == 0
                              ? dropdownvalue.contains("ALL") ||
                                        dropdownvalue == ""
                                    ? XtreamSeriesListPage(
                                        key: _kList,
                                        controller: _scrollController,
                                        data: seriesXtreamData,
                                        showSearchField: showSearchField,
                                        onUpdateCallback: (item) {
                                          setState(() {
                                            print("Valueee: $item");
                                          });
                                        },
                                      )
                                    : XtreamSeriesCategoryPage(
                                        key: _catPage,
                                        categorydata: categorydata,
                                        showsearchfield: categorysearch,
                                        onUpdateCallback: (item) {
                                          setState(() {
                                            print("Valueee: $item");
                                          });
                                        },
                                      )
                              : ind == 1
                              ? XtreamSeriesFavoritePage(
                                  key: _favPage,
                                  data: [],
                                  onUpdateCallback: (item) {
                                    setState(() {
                                      print("Valueee: $item");
                                    });
                                  },
                                )
                              : XtreamSeriesHistoryPage(
                                  key: _hisPage,
                                  data: [],
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
