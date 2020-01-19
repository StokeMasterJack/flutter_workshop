library ssutil;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef T FromJsonFactory<T>(Map<String, dynamic> json);

typedef Command<A>(A arg);
typedef R Action<R>();
typedef R Query<A, R>(A arg);
typedef bool Predicate<A>(A arg);

typedef Future<R> AsyncAction<R>();
typedef Future<R> AsyncQuery<A, R>(A arg);
typedef Future<bool> AsyncPredicate<A>(A arg);



class Api {
  bool logging = false;

  Future<http.Response> get(String url, {Map<String, String> headers}) async {
    Map<String, String> h = headers ?? {};

    final response = await http.get(url, headers: h);

    if (response.statusCode != 200) {
      logHttpResponse(response);
      throw HttpException(response);
    }

    if (logging) {
      print("HTTP Response:");
      print(responseToString(response));
    }

    return response;
  }
}

class HttpException implements Exception {
  final http.Response response;

  HttpException(this.response);

  String toString() {
    return responseToString(response);
  }

  int get statusCode => response.statusCode;

  log() {
    print(toString());
  }
}

List<T> convertJsonList<T>(List<dynamic> jsonListParsed, FromJsonFactory<T> fromJsonFactory) {
  List<T> tmp = [];
  for (var jsonObject in jsonListParsed) {
    T o = fromJsonFactory(jsonObject);
    tmp.add(o);
  }
  return tmp;
}

List<T> parseJsonList<T>(String jsonListText, FromJsonFactory<T> fromJsonFactory) {
  final List<dynamic> jsonListParsed = json.decode(jsonListText);
  return convertJsonList(jsonListParsed, fromJsonFactory);
}

String responseToString(http.Response response) {
  return """url: ${response.request.url}
        responseStatus: ${response.statusCode}
        responseHeaders: ${response.headers}
        responsebody: ${response.body}
        """;
}

logHttpResponseError(response) {
  logHttpResponse("HTTP Error Response", response);
}

logHttpResponse(response, [String title]) {
  if (title != null) print(title);
  print(responseToString(response));
}

logError(Object err, [String title]) {
  final String effectiveTitle = title ?? "An error occurred";
  print(effectiveTitle);
  if (err == null) {
    print("Error object was null");
  } else {
    print(err.toString());
    print(err.runtimeType == null ? err.runtimeType.toString() : "No runtimeType");
    if (err is Error) {
      final StackTrace trace = err.stackTrace;
      if (trace != null) {
        print(err.stackTrace.toString());
      } else {
        print("No stackTrace");
      }
    }
  }
}

bool isMissing(String s) {
  if (s == null) return true;
  if (s.trim().isEmpty) return true;
  return false;
}

String nullNormalize(String s) {
  if (s == null) return null;
  if (s.trim().isEmpty) return null;
  return s.trim();
}

bool isValidEmail(String email) {
  RegExp emailRegExp = new RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");
  return emailRegExp.hasMatch(email.toLowerCase());
}

String capFirstLetter(String s) {
  assert(s != null);
  return "${s[0].toUpperCase()}${s.substring(1)}";
}

String avatarChar(String s) {
  assert(s != null);
  return s[0].toUpperCase();
}

//a and b are guaranteed to ne non-null and !identical and !==
typedef int EzComparator<T>(T a, T b);

void checkEasyCompareArgs<T>(T a, T b) {
  assert(a != null);
  assert(b != null);
  assert(!identical(a, b));
  assert(a != b);
}

int ezStringCompare(String a, String b) {
  checkEasyCompareArgs(a, b);
  return a.compareTo(b);
}

int ezBoolCompare(bool a, bool b) {
  checkEasyCompareArgs(a, b);
  return a ? 1 : -1;
}

int nullSafeCompare<T>(T a, T b, EzComparator<T> ezComparator) {
  if (a == null && b == null) {
    return 0;
  } else if (a == null && b != null) {
    return 1;
  } else if (a != null && b == null) {
    return -1;
  } else if (a != null && b != null) {
    if (identical(a, b)) return 0;
    if (a == b) return 0;
    return ezComparator(a, b);
  } else
    throw StateError("");
}

int timestamp() {
  return new DateTime.now().microsecondsSinceEpoch;
}

T checkArgument<T>(bool expression, {message}) {
  if (!expression) {
    throw new ArgumentError(_resolveMessage(message, "NoMsg"));
  } else {
    return null;
  }
}

T checkState<T>(bool expression, {message}) {
  if (!expression) {
    throw new StateError(_resolveMessage(message, 'NoMsg'));
  } else {
    return null;
  }
}

T unsupported<T>({String msg}) {
  String m = msg ?? "UnsupportedError";
  throw UnsupportedError(m);
}

T throwEx<T>([String msg]) {
  String m = msg ?? "NoMsg";
  throw new Exception(m);
}

T throwStateErr<T>([String msg]) {
  String m = msg ?? "StateError";
  throw StateError(m);
}

T throwArgErr<T>([String msg]) {
  String m = msg ?? "ArgError";
  throw StateError(m);
}

String _resolveMessage(message, String defaultMessage) {
  if (message is Function) message = message();
  if (message == null) return defaultMessage;
  return message.toString();
}

bool isInt(String s) => int.tryParse(s) != null;
