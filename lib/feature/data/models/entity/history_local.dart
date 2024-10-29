
class HistoryLocalField{
  static const String historyTableName = 'history';

  static const String historyId = 'id';
  static const String historyContent = 'content';
  static const String historyTime = 'time';

  static final List<String> query = [historyTableName, historyId, historyContent, historyTime,];
}
class HistoryLocal {
  int? id;
  String? content;
  int? time;

  HistoryLocal({
    this.id,
    this.content,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'time': time,
    };
  }

  factory HistoryLocal.fromJson(Map<String, dynamic> json) {
    return HistoryLocal(
      id: json['id'],
      content: json['content'],
      time: json['time'],
    );
  }
}
