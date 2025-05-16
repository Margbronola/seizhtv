import 'package:rxdart/rxdart.dart';
import 'package:seizhtv/extension/categorized_m3u.dart';

import '../m3u/categorized_m3u_data.dart';
import '../m3u/m3u_entry.dart';

class History {
  History._pr();
  static final History _instance = History._pr();
  static History get instance => _instance;
  BehaviorSubject<CategorizedM3UData> _subject =
      BehaviorSubject<CategorizedM3UData>();
  Stream<CategorizedM3UData> get stream => _subject.stream;
  CategorizedM3UData get current => _subject.value;
  void populate(CategorizedM3UData data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<CategorizedM3UData>();
  }

  void appendIn(String src, {required M3uEntry entry}) {
    final CategorizedM3UData f = current.clone();
    switch (src) {
      case "movie":
        f.movies
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(f);
        return;

      case "series":
        f.series
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(f);
        return;
      case "live":
        f.live
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(f);
        return;
    }
  }
}
