
# this is a base Bloc

change the info app
- get pub CLI: flutter pub global activate rename
  + change the packageName: rename setBundleId --targets ios,android --value "com.example.bundleId"
  + change the appName: rename setAppName --targets ios,android --value "AppName"

change the icon app
- change icon in: assets/img/app_icon.png
- cmd: flutter pub run flutter_launcher_icons

flutter gen asset
- fluttergen -h
- fluttergen -c example/pubspec.yaml