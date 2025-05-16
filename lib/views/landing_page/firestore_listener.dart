// ignore_for_file: avoid_print

import '../../globals/data.dart';
import '../../m3u/m3u_entry.dart';
import '../../m3u/m3u_handler.dart';

class FirestoreListener {
  FirestoreListener._pr();
  static final FirestoreListener _instance = FirestoreListener._pr();
  static FirestoreListener get instance => _instance;
  // final Favorites _favVm = Favorites.instance;
  // final History _hisVm = History.instance;
  static final M3uFirestoreServices firestoreServices = M3uFirestoreServices();

  void listen() {
    print("RFID SA FIRESTORE LISTENER: $refId");
    // firestoreServices
    //     .getListener(collection: "user-favorites", docId: refId!)
    //     .listen((DocumentSnapshot event) {
    //   final Map _result = event.data() as Map;
    //   if (_result.isEmpty) {
    //     // return CategorizedM3UData.empty();
    //     _favVm.populate(CategorizedM3UData.empty());
    //     return;
    //   }
    //   final MappedValue<List<M3uEntry>, List<M3uEntry>, List<M3uEntry>> _res =
    //       _resultMapper(_result);
    //   final CategorizedM3UData f = CategorizedM3UData(
    //     live: _res.item1.sortedCategories(attributeName: "group-title"),
    //     movies: _res.item2.sortedCategories(attributeName: "group-title"),
    //     series: _res.item3.sortedCategories(attributeName: "group-title"),
    //   );
    //   _favVm.populate(f);
    //   return;
    // });
    // firestoreServices
    //     .getListener(collection: "user-history", docId: refId!)
    //     .listen((DocumentSnapshot event) {
    //   final Map _result = event.data() as Map;
    //   if (_result.isEmpty) {
    //     // return CategorizedM3UData.empty();
    //     _hisVm.populate(CategorizedM3UData.empty());
    //     return;
    //   }
    //   final MappedValue<List<M3uEntry>, List<M3uEntry>, List<M3uEntry>> _res =
    //       _resultMapper(_result);
    //   final CategorizedM3UData f = CategorizedM3UData(
    //     live: _res.item1.sortedCategories(attributeName: "group-title"),
    //     movies: _res.item2.sortedCategories(attributeName: "group-title"),
    //     series: _res.item3.sortedCategories(attributeName: "group-title"),
    //   );
    //   _hisVm.populate(f);
    //   return;
    // });
  }

  MappedValue<List<M3uEntry>, List<M3uEntry>, List<M3uEntry>> resultMapper(
    Map result,
  ) {
    final List<M3uEntry> mov =
        (result['movie'] as List?)
            ?.map((e) => M3uEntry.fromFirestore(e, 2))
            .toList() ??
        [];
    final List<M3uEntry> ser =
        (result['series'] as List?)
            ?.map((e) => M3uEntry.fromFirestore(e, 3))
            .toList() ??
        [];
    final List<M3uEntry> live =
        (result['live'] as List?)
            ?.map((e) => M3uEntry.fromFirestore(e, 1))
            .toList() ??
        [];
    return MappedValue(item1: live, item2: mov, item3: ser);
  }
}

class MappedValue<X1, X2, X3> {
  final X1 item1;
  final X2 item2;
  final X3 item3;
  const MappedValue({
    required this.item1,
    required this.item2,
    required this.item3,
  });
}
