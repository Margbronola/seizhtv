import 'package:seizhtv/extension/categorized_m3u.dart';

import '../data_containers/favorites.dart';
import '../m3u/categorized_m3u_data.dart';
import '../m3u/m3u_entry.dart';

extension ENTRY on M3uEntry {
  static final Favorites _vm = Favorites.instance;
  bool existsInFavorites(String src) {
    try {
      final CategorizedM3UData f = _vm.current.clone();
      // _vm.current.;

      switch (src) {
        case "series":
          return f.series
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        case "movie":
          return f.movies
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        case "live":
          return f.live
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
