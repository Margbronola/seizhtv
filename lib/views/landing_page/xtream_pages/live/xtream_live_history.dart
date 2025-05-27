// ignore_for_file: must_be_immutable, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:seizhtv/extension/list.dart';
import 'package:seizhtv/extension/m3u_entry.dart';
import 'package:seizhtv/models/xtreams_models/xtream_data.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../m3u/m3u_entry.dart';

class XtreamLiveHistoryPage extends StatefulWidget {
  XtreamLiveHistoryPage({
    super.key,
    required this.data,
    required this.onPressed,
    this.showSearchField = false,
  });

  final List<XtreamDataModel> data;
  final ValueChanged<XtreamDataModel> onPressed;
  bool showSearchField;

  @override
  State<XtreamLiveHistoryPage> createState() => XtreamLiveHistoryPageState();
}

class XtreamLiveHistoryPageState extends State<XtreamLiveHistoryPage> {
  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
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
      return const Center(child: Text("No data added to History"));
    }
    return _displayData.isEmpty
        ? Center(
            child: Text(
              "No Result Found for `$searchText`",
              style: TextStyle(color: Colors.white.withOpacity(.5)),
            ),
          )
        : GridView.builder(
            shrinkWrap: true,
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
                  // print("${item.existsInFavorites("live")}");
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
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
                ),
              );
              // return LayoutBuilder(builder: (context, c) {
              //   final double w = c.maxWidth;
              //   return GestureDetector(
              //     onTap: () {

              //     },
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(10),
              //           child: NetworkImageViewer(
              //             url: item.attributes['tvg-logo'],
              //             title: "false",
              //             width: w,
              //             height: 70,
              //             color: highlight,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //         const SizedBox(height: 5),
              //         Text(
              //           item.title,
              //           maxLines: 2,
              //           overflow: TextOverflow.ellipsis,
              //           style: const TextStyle(height: 1),
              //         ),
              //       ],
              //     ),
              //   );
              // });
            },
          );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150)
        .floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
