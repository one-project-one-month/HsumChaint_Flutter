import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:http/src/response.dart';

Future<dynamic> saveCache(CacheManager instance) async {
  //CacheManager.instance.isSaving = true;

  var cacheString = jsonEncode(instance.cacheJSON);
  var file = File(instance.cacheFilePath);
  file.writeAsStringSync(cacheString);

  return null;
}

class CacheManager {
  static final instance = CacheManager();
  var _cacheAge = 60 * 15; //Age In second, default 15 minutes
  Map<String, dynamic> _cacheJSON = {};
  bool isSaving = false;

  SharedPreferences? pref;
  String cacheFilePath = "";

  CacheManager() {
    getTemporaryDirectory().then(
      (cacheDir) => cacheFilePath = cacheDir.path + "/datingcache.txt",
    );
  }
  //Cache manager work on two condition
  // isOffline & enableOffLine => it will return cached line data
  // Not isOffline & enableOffLine => it will return uptodate data as per the cache age
  // isOffline & Not enableOffLine => it will return uptodate data as per the cache age
  // Not isOffline & Not enableOffline => it will return uptodate data as per the cache age
  bool _isOffline = false;
  bool _offlineEnabled = false;

  set isOffline(value) => _isOffline = value;
  set offlineEnabled(value) => _offlineEnabled = value;
  int get cacheAge => _cacheAge;
  set cacheAge(int durationInSecond) =>
      _cacheAge = durationInSecond ?? 1 * 60 * 60 * 12;
  get cacheJSON => _cacheJSON;

  Future<void> clearCache() async {
    cacheFilePath =
        cacheFilePath ?? (await getTemporaryDirectory()).path + "/ntrcache.txt";

    var existFuture = File(cacheFilePath).exists();
    existFuture.then((status) {
      if (status) {
        File(cacheFilePath).delete();
        print("Cache file deleted");
        _cacheJSON = {};
        return;
      }
    });
    return;
  }

  Future<void> loadCacheFromDisk() async {
    cacheFilePath =
        cacheFilePath ?? (await getTemporaryDirectory()).path + "/ntrcache.txt";

    var existFuture = File(cacheFilePath).exists();

    existFuture.then((status) {
      if (status) {
        var file = File(cacheFilePath);

        var cacheJSONString = file.readAsStringSync();
        if (cacheJSONString != null) {
          print("Cache loaded from disk...");
          _cacheJSON = jsonDecode(cacheJSONString) as Map<String, dynamic>;
        }
        return;
      } else
        return;
    });
  }

  Future<Response> get(
    dynamic uri, {
    required Map<String, String> headers,
    int statusCodeByCache = 404,
    int maxTimeInSecond = 5,
    bool forcefetch = false,
  }) async {
    String url = "";
    if (uri is Uri) {
      url = uri.origin + uri.path + uri.query;
    } else if (uri is String) {
      url = uri;
    }
    if (_cacheJSON == null) await loadCacheFromDisk();
    if (_cacheJSON != null && _cacheJSON[url] != null) {
      Map<String, dynamic> urlJSON = _cacheJSON[url] as Map<String, dynamic>;
      //Time value is the cache saved time
      var timeValue = urlJSON["time"] != null
          ? urlJSON["time"]
          : DateTime.now().millisecondsSinceEpoch;
      var lifeSpan = (maxTimeInSecond ?? this._cacheAge) * 1000;
      var isRefetch =
          (DateTime.now().millisecondsSinceEpoch - timeValue) > lifeSpan;

      if ((_isOffline && _offlineEnabled) || isRefetch == false) {
        print("$url is returned from cache");
        if (forcefetch == true) {
          var response = await http.get(uri, headers: headers);
          if (response.statusCode == 200) updateURLCache(response, url);
          return response;
        } else {
          var response = Response(
            urlJSON["body"] as String,
            statusCodeByCache ?? 200,
          );
          return response;
        }
      }
      print("$url is refetched as of time expired");
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) updateURLCache(response, url);
      return response;
    }

    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) updateURLCache(response, url);
    return response;
  }

  // Future<Response> post(dynamic uri,
  //     {Map<String, String> headers,
  //     int statusCodeByCache,
  //     int maxTimeInSecond,
  //     bool forcefetch}) async {
  //   String url = "";
  //   if (uri is Uri) {
  //     url = uri.origin + uri.path + uri.query;
  //   } else if (uri is String) {
  //     url = uri;
  //   }
  //   if (_cacheJSON == null) await loadCacheFromDisk();
  //   if (_cacheJSON != null && _cacheJSON[url] != null) {
  //     Map<String, dynamic> urlJSON = _cacheJSON[url] as Map<String, dynamic>;
  //     //Time value is the cache saved time
  //     var timeValue = urlJSON["time"] != null
  //         ? urlJSON["time"]
  //         : DateTime.now().millisecondsSinceEpoch;
  //     var lifeSpan = (maxTimeInSecond ?? this._cacheAge) * 1000;
  //     var isRefetch =
  //         (DateTime.now().millisecondsSinceEpoch - timeValue) > lifeSpan;

  //     if ((_isOffline && _offlineEnabled) || isRefetch == false) {
  //       print("$url is returned from cache");
  //       if (forcefetch == true) {
  //         var response = await http.get(uri, headers: headers);
  //         if (response.statusCode == 200) updateURLCache(response, url);
  //         return response;
  //       } else {
  //         var response =
  //             Response(urlJSON["body"] as String, statusCodeByCache ?? 200);
  //         return response;
  //       }
  //     }
  //     print("$url is refetched as of time expired");
  //     var response = await http.get(uri, headers: headers);
  //     if (response.statusCode == 200) updateURLCache(response, url);
  //     return response;
  //   }

  //   var response = await http.get(uri, headers: headers);
  //   if (response.statusCode == 200) updateURLCache(response, url);
  //   return response;
  // }

  updateURLCache(Response response, String url) async {
    _cacheJSON = _cacheJSON ?? {};
    Map<String, dynamic> urlJSON = _cacheJSON[url] ?? {};
    urlJSON["body"] = response.body;
    urlJSON["time"] = DateTime.now().millisecondsSinceEpoch;
    _cacheJSON[url] = urlJSON;

    print("Cache memory updated...");

    if (CacheManager.instance.isSaving == false) {
      CacheManager.instance.isSaving = true;

      compute(
        saveCache,
        CacheManager.instance,
      ).then((result) => CacheManager.instance.isSaving = false);
    } else {
      print("Cache saving in progress...");
    }
  }
}
