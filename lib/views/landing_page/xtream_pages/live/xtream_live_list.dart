// ignore_for_file: deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/models/xtreams_models/xtream_data.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';

class XtreamLiveListPage extends StatefulWidget {
  const XtreamLiveListPage({
    super.key,
    required this.data,
    required this.controller,
    required this.onPressed,
    required this.onUpdateCallback,
  });
  final List<XtreamDataModel> data;
  final ScrollController controller;
  final ValueChanged<XtreamDataModel> onPressed;
  final ValueChanged<XtreamDataModel> onUpdateCallback;

  @override
  State<XtreamLiveListPage> createState() => XtreamLiveListPageState();
}

class XtreamLiveListPageState extends State<XtreamLiveListPage> {
  static final Favorites _vm = Favorites.instance;
  // static final ZM3UHandler _handler = ZM3UHandler.instance;
  List<XtreamDataModel>? searchData;

  // fetchFav() async {
  //   await _handler
  //       .getDataFrom(type: CollectionType.favorites, refId: refId!)
  //       .then((value) {
  //         if (value != null) {
  //           _vm.populate(value);
  //         }
  //       });
  // }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data);
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.data)
            : _displayData = List.from(
                widget.data
                    .where(
                      (element) => element.name!.toLowerCase().contains(
                        text.toLowerCase(),
                      ),
                    )
                    .toList(),
              );
      }
      _displayData.sort((a, b) => a.name!.compareTo("${b.name}"));

      print("DISPLAY DATA LENGHT: ${_displayData.length}");
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length;
  late List<XtreamDataModel> _displayData = List.from(
    widget.data.sublist(startIndex, endIndex),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SeizhTvLoader(
        label: Text(
          "Retrieving_data".tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: _displayData.isEmpty
              ? Center(
                  child: Text(
                    "No Result Found for `$searchText`",
                    style: TextStyle(color: Colors.white.withOpacity(.5)),
                  ),
                )
              : GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: calculateCrossAxisCount(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: _displayData.length,
                  itemBuilder: (context, index) {
                    final XtreamDataModel item = _displayData[index];

                    return GestureDetector(
                      onTap: () {
                        widget.onPressed(item);
                        print("ITEM TITLE: ${item.name}");
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final double w = c.maxWidth;
                                  final double h = c.maxHeight;
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: NetworkImageViewer(
                                      url: item.icon,
                                      width: w,
                                      height: h,
                                      fit: BoxFit.fitWidth,
                                      color: ColorPalette().highlight,
                                      title: item.name ?? "",
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Positioned(
                            //   top: 0,
                            //   right: 0,
                            //   child: SizedBox(
                            //     height: 25,
                            //     width: 25,
                            //     child: FavoriteIconButton(
                            //       onPressedCallback: (bool f) async {
                            //         if (f) {
                            //           showDialog(
                            //             barrierDismissible: false,
                            //             context: context,
                            //             builder: (BuildContext context) {
                            //               Future.delayed(
                            //                 const Duration(seconds: 3),
                            //                 () {
                            //                   Navigator.of(context).pop(true);
                            //                 },
                            //               );
                            //               return Dialog(
                            //                 alignment: Alignment.topCenter,
                            //                 shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10.0),
                            //                 ),
                            //                 child: Container(
                            //                   padding:
                            //                       const EdgeInsets.symmetric(
                            //                         horizontal: 20,
                            //                       ),
                            //                   child: Row(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment
                            //                             .spaceBetween,
                            //                     children: [
                            //                       Text(
                            //                         "Added_to_Favorites".tr(),
                            //                         style: const TextStyle(
                            //                           fontSize: 16,
                            //                         ),
                            //                       ),
                            //                       IconButton(
                            //                         padding:
                            //                             const EdgeInsets.all(0),
                            //                         onPressed: () {
                            //                           Navigator.of(
                            //                             context,
                            //                           ).pop();
                            //                         },
                            //                         icon: const Icon(
                            //                           Icons.close_rounded,
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ),
                            //               );
                            //             },
                            //           );
                            //           await item.addToFavorites(refId!);
                            //           widget.onUpdateCallback(item);
                            //         } else {
                            //           await item.removeFromFavorites(refId!);
                            //           widget.onUpdateCallback(item);
                            //         }
                            //       },
                            //       initValue: item.existsInFavorites("live"),
                            //       iconSize: 20,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150).floor();
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
