import 'package:spotify/feature/data/models/modified.dart';

class ModifiedDTO {
  String? time;

  ModifiedDTO({this.time});

  ModifiedDTO.fromJson(Map<String, dynamic> json) {
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    return data;
  }

  Modified toModified() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    return Modified(
      time: time
    );
  }
}