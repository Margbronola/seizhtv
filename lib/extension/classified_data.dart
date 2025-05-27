// ignore_for_file: avoid_print

import 'package:seizhtv/extension/categorized_m3u.dart';
import 'package:seizhtv/m3u/classified_data.dart';

import '../data_containers/favorites.dart';
import '../m3u/categorized_m3u_data.dart';
import '../m3u/m3u_entry.dart';

extension CLS on ClassifiedData {
  static final Favorites _vm = Favorites.instance;
  bool isInFavorite(String src) {
    try {
      final CategorizedM3UData f = _vm.current.clone();
      switch (src) {
        case "series":
          final List<ClassifiedData> srcs = List.from(f.series);
          try {
            print("NAME: $name");
            print("SRC: $srcs");
            print("SRC: ${srcs.length}");
            List<M3uEntry> s = [];

            // final ClassifiedData _s =
            //     src.where((element) => element.name == name).first;
            // print("NAME: $_s");
            // return _s.data.length == data.length;
            for (final ClassifiedData sdata in srcs) {
              print("SDATAAAA: $sdata");
              for (final M3uEntry mdata in sdata.data) {
                if (mdata.title.contains(name)) {
                  s.add(mdata);
                  print("M3U DATA: $s");
                }
              }
            }
            print("SDATAAAA LENGHT: ${s.length} - ${data.length}");
            return s.length == data.length;
            // return false;
          } on StateError {
            return false;
          }
        case "movie":
          final List<ClassifiedData> src0 = List.from(f.movies);
          try {
            final ClassifiedData s = src0
                .where((element) => element.name == name)
                .first;
            return s.data.length == data.length;
          } on StateError {
            return false;
          }
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
