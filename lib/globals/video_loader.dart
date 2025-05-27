// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seizhtv/globals/data.dart';
import '../views/custom_player.dart';

class VideoLoader {
  loadVideo(
    BuildContext context, {
    required String link,
    required String title,
    required String? type,
    String? image,
    String? movieExtension,
    bool fromXtream = false,
  }) async {
    print(
      "LINK: ${"${server!.serverProtocol}://${server!.url}:${server!.port}/$type/${userInfo?.username}/${userInfo?.password}/$link.${type == "live"
          ? "ts"
          : type == "movie" || type == "series"
          ? "$movieExtension"
          : ""}"}",
    );
    await showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.black.withOpacity(.5),
      barrierLabel: "",
      barrierDismissible: false,
      transitionBuilder: (_, a1, a2, x) => Transform.scale(
        scale: a1.value,
        child: FadeTransition(
          opacity: a1,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: CustomPlayer(
              link: fromXtream == false
                  ? link
                  : "${server!.serverProtocol}://${server!.url}:${server!.port}/$type/${userInfo?.username}/${userInfo?.password}/$link.${type == "live"
                        ? "ts"
                        : type == "movie"
                        ? "mp4"
                        : ""}",
              id: title,
              name: title,
              image: image ?? "",
              popOnError: true,
            ),
          ),
        ),
      ),
      pageBuilder: (_, a1, a2) => Container(),
    );
  }
}
