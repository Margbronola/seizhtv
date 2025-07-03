// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../globals/network.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../models/cast.dart';
import '../../../../models/xtreams_models/xtream_series_data.dart';
import '../../../../services/tv_series_api.dart';
import '../../../../viewmodel/cast_vm.dart';

class XtreamSeriesInfoPage extends StatefulWidget {
  const XtreamSeriesInfoPage({super.key, required this.data});
  final XtreamSeriesDataModel data;

  @override
  State<XtreamSeriesInfoPage> createState() => _XtreamSeriesInfoPageState();
}

class _XtreamSeriesInfoPageState extends State<XtreamSeriesInfoPage> {
  static final CastViewModel _castViewModel = CastViewModel.instance;
  @override
  void initState() {
    TVSeriesAPI()
        .searchTV(title: widget.data.title ?? "", year: widget.data.year)
        .then((value) {
          print("SEARCH TV: $value");
          TVSeriesAPI().tvSeriesCast(value!);
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Directors".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [TextSpan(text: " :")],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.data.director == null ? "" : widget.data.director!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Release_Date".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [TextSpan(text: " :")],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    DateFormat(
                      'MMMM dd, yyyy',
                    ).format(DateTime.parse(widget.data.releaseDate!)),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Genre".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [TextSpan(text: " :")],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.data.genre ?? "",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Cast".tr(),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 170,
              child: StreamBuilder<List<CastModel>>(
                stream: _castViewModel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No_data_available".tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    if (snapshot.data!.isNotEmpty) {
                      final List<CastModel> result = snapshot.data!;

                      return ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: result.length,
                        itemBuilder: (_, i) {
                          final CastModel cast = result[i];

                          return SizedBox(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(
                                    height: 80,
                                    width: 75,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          "${Network.imageUrl}${cast.profilePath}",
                                      placeholder: (context, url) =>
                                          UIAdditional().shimmerLoading(
                                            ColorPalette().highlight,
                                            80,
                                            width: double.infinity,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            "assets/images/logo.png",
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  cast.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  cast.character,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: ColorPalette().white.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (c, i) => const SizedBox(width: 10),
                      );
                    }
                  }
                  return const CircularProgressIndicator(color: Colors.grey);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
