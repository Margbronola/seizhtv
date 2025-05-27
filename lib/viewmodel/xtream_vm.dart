import 'package:rxdart/rxdart.dart';
import '../models/xtreams_models/xtream_data.dart';

class XtreamViewModel {
  XtreamViewModel._pr();
  static final XtreamViewModel _instance = XtreamViewModel._pr();
  static XtreamViewModel get instance => _instance;

  BehaviorSubject<List<XtreamDataModel>> _subject =
      BehaviorSubject<List<XtreamDataModel>>();
  Stream<List<XtreamDataModel>> get stream => _subject.stream;
  List<XtreamDataModel> get current => _subject.value;

  void populate(List<XtreamDataModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<XtreamDataModel>>();
  }
}
