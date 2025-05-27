// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extension/color.dart';
import 'package:seizhtv/extension/state.dart';
import 'package:seizhtv/models/xtreams_models/category.dart';
import 'package:seizhtv/models/xtreams_models/xtream_data.dart';
import 'package:seizhtv/viewmodel/xtream_category_vm.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../globals/data.dart';
import '../../../globals/loader.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../services/xtream_api.dart';
import 'movie/xtream_movie_category.dart';
import 'movie/xtream_movie_favorite.dart';
import 'movie/xtream_movie_history.dart';
import 'movie/xtream_movie_list.dart';

class XtreamMoviePage extends StatefulWidget {
  const XtreamMoviePage({super.key});

  @override
  State<XtreamMoviePage> createState() => _XtreamMoviePageState();
}

class _XtreamMoviePageState extends State<XtreamMoviePage> {
  final XtreamCategoryViewModel _catvm = XtreamCategoryViewModel.instance;
  late final ScrollController _scrollController;
  final Favorites _vm1 = Favorites.instance;
  final History _hisvm = History.instance;
  bool showSearchField = false;
  bool update = false;
  late final TextEditingController _search;
  late List<String>? categoryName = [
    "ALL (${movieXtreamData.isEmpty ? "" : movieXtreamData.length})",
  ];
  late List<XtreamDataModel> categorydata = [];
  bool categorysearch = false;
  String dropdownvalue = "";
  int? ind = 0;
  int? prevIndex;
  bool selected = true;

  initXtreamCategory() {
    _catvm.stream.listen((event) {
      xtreamMovieCategory = event;
      for (final CategoryModel cdata in xtreamMovieCategory) {
        categoryName!.add(cdata.name);
      }
      categoryName!.toSet().toList();
      categoryName!.sort((a, b) => a.compareTo(b));
      for (final String label in categoryName!) {
        if (label.contains(
          "ALL (${movieXtreamData.isEmpty ? "" : movieXtreamData.length})",
        )) {
          dropdownvalue = label;
        }
      }

      if (mounted) setState(() {});
    });
  }

  fetchFav() async {
    //  await _handler
    //     .getDataFrom(type: CollectionType.favorites, refId: refId!)
    //     .then((value) {
    //       if (value != null) {
    //         _vm1.populate(value);
    //       }
    //     });
  }

  fetchHis() async {
    //  await _handler
    //      .getDataFrom(type: CollectionType.history, refId: refId!)
    //      .then((value) {
    //       if (value != null) {
    //          _hisvm.populate(value);
    //       }
    //     });
  }

  fetchxtream() async {
    await XtreamApi()
        .getMovieCategoryStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            xtreamMovieCategory = value!;
          });
        });
    await XtreamApi()
        .getMovieStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            movieXtreamData = value!;
          });
        });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    fetchxtream();
    initXtreamCategory();
    fetchFav();
    fetchHis();
    super.initState();
  }

  final GlobalKey<XtreamMovieListPageState> _kList =
      GlobalKey<XtreamMovieListPageState>();
  final GlobalKey<XtreamMovieFavoritePageState> _favPage =
      GlobalKey<XtreamMovieFavoritePageState>();
  final GlobalKey<XtreamMovieHistoryPageState> _hisPage =
      GlobalKey<XtreamMovieHistoryPageState>();
  final GlobalKey<XtreamMovieCategoryPageState> _catPage =
      GlobalKey<XtreamMovieCategoryPageState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            2,
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
            movieXtreamData.isEmpty
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
                                                items: categoryName!.map((
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
                                                          : categoryName?.first
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
                                                        XtreamApi()
                                                            .getMovieFilterdByCategory(
                                                              baseUrl:
                                                                  "${server!.serverProtocol}://${server!.url}:${server!.port}",
                                                              username:
                                                                  userInfo!
                                                                      .username,
                                                              password:
                                                                  userInfo!
                                                                      .password,
                                                              categoryId:
                                                                  int.parse(
                                                                    cm.id,
                                                                  ),
                                                            )
                                                            .then((value) {
                                                              setState(() {
                                                                print(
                                                                  "VALUE LENGHT: ${value!.length}",
                                                                );
                                                                categorydata =
                                                                    value;
                                                              });
                                                            });
                                                      }
                                                    }
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
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prevIndex = ind!;
                                          ind = 0;
                                          showSearchField = false;
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
                                                items: categoryName!.map((
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
                                                          : categoryName![3]
                                                    : dropdownvalue,
                                                style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    dropdownvalue = value!;
                                                    for (CategoryModel cm
                                                        in xtreamLiveCategory) {
                                                      if (dropdownvalue ==
                                                          cm.name) {
                                                        print(
                                                          "ID: ${cm.id} - ${cm.name}",
                                                        );
                                                        XtreamApi()
                                                            .getMovieFilterdByCategory(
                                                              baseUrl:
                                                                  "${server!.serverProtocol}://${server!.url}:${server!.port}",
                                                              username:
                                                                  userInfo!
                                                                      .username,
                                                              password:
                                                                  userInfo!
                                                                      .password,
                                                              categoryId:
                                                                  int.parse(
                                                                    cm.id,
                                                                  ),
                                                            )
                                                            .then((value) {
                                                              setState(() {
                                                                print(
                                                                  "VALUE LENGHT: ${value!.length}",
                                                                );
                                                                categorydata =
                                                                    value;
                                                              });
                                                            });
                                                      }
                                                    }
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
                                    "${"favorites".tr().toUpperCase()} (${00})",
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
                                    "${"Channels_History".tr().toUpperCase()} (${00})",
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
                                                        controller: _search,
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
                                          _search.text = "";
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
                                    ? XtreamMovieListPage(
                                        key: _kList,
                                        controller: _scrollController,
                                        data: movieXtreamData,
                                        showSearchField: showSearchField,
                                        onUpdateCallback: (item) {
                                          setState(() {
                                            print("Valueee: $item");
                                          });
                                        },
                                      )
                                    : XtreamMovieCategoryPage(
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
                              ? XtreamMovieFavoritePage(
                                  key: _kList,
                                  data: [],
                                  showSearchField: showSearchField,
                                  onUpdateCallback: (item) {
                                    setState(() {
                                      print("Valueee: $item");
                                    });
                                  },
                                )
                              : XtreamMovieHistoryPage(key: _kList, data: []),
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
