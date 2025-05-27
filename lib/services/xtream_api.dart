// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seizhtv/models/xtreams_models/xtream_series_data.dart';
import '../models/xtreams_models/category.dart';
import '../models/xtreams_models/xtream_data.dart';
import '../viewmodel/xtream_category_vm.dart';
import '../viewmodel/xtream_series_vm.dart';
import '../viewmodel/xtream_vm.dart';

class XtreamApi {
  static final XtreamViewModel _xtreamViewModel = XtreamViewModel.instance;
  static final XtreamViewModel _xtreamViewModel1 = XtreamViewModel.instance;
  static final XtreamCategoryViewModel _xtreamCategoryViewModel =
      XtreamCategoryViewModel.instance;
  static final XtreamSeriesViewModel _xtreamSeriesViewModel =
      XtreamSeriesViewModel.instance;

  Future<String?> getStreamM3u({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/get.php?username=$username&password=$password&type=m3u_plus&outputs=ts',
      );
      final response = await http.get(url);

      print("GET STREAM M3U");
      print("RESPONSE STATUS: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print("ERROR FETCHING USER INFO XTREAM: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserInfo({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password',
      );
      final response = await http.get(url);

      print("RESPONSE STATUS: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print("ERROR FETCHING USER INFO XTREAM: $e");
    }
    return null;
  }

  Future<List<XtreamDataModel>?> getLiveStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams',
      );
      final response = await http.get(url);

      print("LIVE");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<XtreamDataModel> xtreamdata = List.from(
          data,
        ).map((e) => XtreamDataModel.fromJson(e)).toList();
        _xtreamViewModel.populate(
          data.map((e) => XtreamDataModel.fromJson(e)).toList(),
        );
        return xtreamdata;
      } else {
        throw Exception('Failed to load live streams');
      }
    } catch (e, s) {
      print("ERROR FETCHING LIVE STREAM: $e");
      print("$s");
    }
    return null;
  }

  Future<List<XtreamDataModel>?> getLiveFilterdByCategory({
    required String baseUrl,
    required String username,
    required String password,
    required int categoryId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams&category_id=$categoryId',
      );
      final response = await http.get(url);

      print(" LIVE FILTERED BY CATEGORY");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<XtreamDataModel> xtreamdata = List.from(
          data,
        ).map((e) => XtreamDataModel.fromJson(e)).toList();
        return xtreamdata;
      } else {
        throw Exception('Failed to load live filtered by category');
      }
    } catch (e, s) {
      print("ERROR FETCHING LIVE FILTERED BY CATEGORY: $e");
      print("$s");
    }
    return null;
  }

  Future<List<CategoryModel>?> getLiveCategoryStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_live_categories',
      );
      final response = await http.get(url);

      print("LIVE CATEGORY");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<CategoryModel> xtreamCategorydata = List.from(
          data,
        ).map((e) => CategoryModel.fromJson(e)).toList();
        _xtreamCategoryViewModel.populate(
          data.map((e) => CategoryModel.fromJson(e)).toList(),
        );
        return xtreamCategorydata;
      } else {
        throw Exception('Failed to load live category streams');
      }
    } catch (e) {
      print("ERROR FETCHING LIVE CATEGORY STREAM: $e");
    }
    return null;
  }

  Future<List<XtreamDataModel>?> getMovieStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_streams',
      );
      final response = await http.get(url);

      print("MOVIES");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<XtreamDataModel> xtreamdata = List.from(
          data,
        ).map((e) => XtreamDataModel.fromJson(e)).toList();
        _xtreamViewModel.populate(
          data.map((e) => XtreamDataModel.fromJson(e)).toList(),
        );
        return xtreamdata;
      } else {
        throw Exception('Failed to load movie streams');
      }
    } catch (e) {
      print("ERROR FETCHING MOVIE STREAM: $e");
    }
    return null;
  }

  Future<List<XtreamDataModel>?> getMovieFilterdByCategory({
    required String baseUrl,
    required String username,
    required String password,
    required int categoryId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_streams&category_id=$categoryId',
      );
      final response = await http.get(url);

      print("MOVIE FILTERED BY CATEGORY");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<XtreamDataModel> xtreamdata = List.from(
          data,
        ).map((e) => XtreamDataModel.fromJson(e)).toList();
        return xtreamdata;
      } else {
        throw Exception('Failed to load movie filtered by category');
      }
    } catch (e, s) {
      print("ERROR FETCHING MOVIE FILTERED BY CATEGORY: $e");
      print("$s");
    }
    return null;
  }

  Future<List<CategoryModel>?> getMovieCategoryStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_categories',
      );
      final response = await http.get(url);

      print("MOVIES CATEGORY");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<CategoryModel> xtreamCategorydata = List.from(
          data,
        ).map((e) => CategoryModel.fromJson(e)).toList();
        _xtreamCategoryViewModel.populate(
          data.map((e) => CategoryModel.fromJson(e)).toList(),
        );
        return xtreamCategorydata;
      } else {
        throw Exception('Failed to load movie category streams');
      }
    } catch (e) {
      print("ERROR FETCHING MOVIE CATEGORY STREAM: $e");
    }
    return null;
  }

  Future<dynamic>? getMovieStreamInfo({
    required String baseUrl,
    required String username,
    required String password,
    required int movieId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_info&vod_id=$movieId',
      );
      final response = await http.get(url);

      print("MOVIES INFO");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie streams');
      }
    } catch (e) {
      print("ERROR FETCHING MOVIE STREAM: $e");
    }
    return null;
  }

  Future<List<XtreamSeriesDataModel>?> getSeriesStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_series',
      );
      final response = await http.get(url);

      print("SERIES");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<XtreamSeriesDataModel> xtreamSeriesdata = data
            .map((e) => XtreamSeriesDataModel.fromJson(e))
            .toList();
        _xtreamSeriesViewModel.populate(
          data.map((e) => XtreamSeriesDataModel.fromJson(e)).toList(),
        );
        return xtreamSeriesdata;
      } else {
        throw Exception('Failed to load series streams');
      }
    } catch (e, s) {
      print("ERROR FETCHING SERIES STREAM: $e");
      print('$s');
    }
    return null;
  }

  Future<List<CategoryModel>?> getSeriesCategoryStream({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_series_categories',
      );
      final response = await http.get(url);

      print("SERIES CATEGORY");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<CategoryModel> xtreamCategorydata = List.from(
          data,
        ).map((e) => CategoryModel.fromJson(e)).toList();
        _xtreamCategoryViewModel.populate(
          data.map((e) => CategoryModel.fromJson(e)).toList(),
        );
        return xtreamCategorydata;
      } else {
        throw Exception('Failed to load series category streams');
      }
    } catch (e) {
      print("ERROR FETCHING SERIES CATEGORY STREAM: $e");
    }
    return null;
  }

  Future<dynamic>? getSeriesInfo({
    required String baseUrl,
    required String username,
    required String password,
    required int? seriesId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_series_info&series_id=$seriesId',
      );
      final response = await http.get(url);

      print("SERIES EPISODE");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        // var data = json.decode(response.body);
        // XtreamSeriesInfo xtreamSeriesInfo = data;
        // _xtreamCategoryViewModel.populate(
        //   data.map((e) => CategoryModel.fromJson(e)).toList(),
        // );
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load series category streams');
      }
    } catch (e) {
      print("ERROR FETCHING SERIES CATEGORY STREAM: $e");
    }
    return null;
  }
}
