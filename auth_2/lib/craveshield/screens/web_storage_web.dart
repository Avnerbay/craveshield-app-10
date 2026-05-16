// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void webStorageSave(String key, String value) {
  html.window.localStorage[key] = value;
}

String? webStorageLoad(String key) {
  return html.window.localStorage[key];
}
