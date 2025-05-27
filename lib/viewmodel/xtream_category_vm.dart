import 'package:rxdart/rxdart.dart';
import '../models/xtreams_models/category.dart';

class XtreamCategoryViewModel {
  XtreamCategoryViewModel._pr();
  static final XtreamCategoryViewModel _instance =
      XtreamCategoryViewModel._pr();
  static XtreamCategoryViewModel get instance => _instance;

  BehaviorSubject<List<CategoryModel>> _subject =
      BehaviorSubject<List<CategoryModel>>();
  Stream<List<CategoryModel>> get stream => _subject.stream;
  List<CategoryModel> get current => _subject.value;

  void populate(List<CategoryModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<CategoryModel>>();
  }
}
