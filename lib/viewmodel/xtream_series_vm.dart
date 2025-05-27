import 'package:rxdart/rxdart.dart';
import '../models/xtreams_models/xtream_series_data.dart';

class XtreamSeriesViewModel {
  XtreamSeriesViewModel._pr();
  static final XtreamSeriesViewModel _instance = XtreamSeriesViewModel._pr();
  static XtreamSeriesViewModel get instance => _instance;

  BehaviorSubject<List<XtreamSeriesDataModel>> _subject =
      BehaviorSubject<List<XtreamSeriesDataModel>>();
  Stream<List<XtreamSeriesDataModel>> get stream => _subject.stream;
  List<XtreamSeriesDataModel> get current => _subject.value;

  void populate(List<XtreamSeriesDataModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<XtreamSeriesDataModel>>();
  }
}
