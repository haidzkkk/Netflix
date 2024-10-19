import 'package:intl/intl.dart';

class DateConverter {

  ///
  static DateTime isoStringToLocalDate(String? dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime!);
  }

  static DateTime isoString2ToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime);
  }

  static DateTime isoString3ToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(dateTime);
  }

  static DateTime? millisecondsSinceEpochToDateTime(int? data){
    if(data == null || data == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(data);
  }

  ///
  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String localDateToIsoString2(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }

  static String localDateToIsoString3(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(dateTime);
  }

  static String millisecondsSinceEpochToString(int? data){
    return data != null ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(data)) : '';
  }

  static String millisecondsSinceEpochToIsoString(int? data) {
    if(data == null) return "";
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(DateTime.fromMillisecondsSinceEpoch(data));
  }

  static String millisecondsSinceEpochToIsoString2(int? data) {
    if(data == null) return "";
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data));
  }

  static String millisecondsSinceEpochHourString(int? data) {
    if(data == null) return "";
    return DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(data));
  }

  static String millisecondsSinceEpochMonthString(int? data) {
    if(data == null) return "";
    return DateFormat('MMMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(data));
  }


  static String isoStringToLocalString(String? data) {
    if(data == null || data.isEmpty) return "";
    return DateFormat('dd/MM/yyyy').format(isoStringToLocalDate(data));
  }

  static String isoString2ToLocalString(String? data) {
    if(data == null || data.isEmpty) return "";
    return DateFormat('dd/MM/yyyy').format(isoString2ToLocalDate(data));
  }

  static String dateStringToday(DateTime? dateTime) {
    if (dateTime == null) {
      return "";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return "Today";
    } else if (dateOnly == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  static String analyzeDateTimeWithIsoString(String? inputDateTime){
    if(inputDateTime?.isNotEmpty != true) return "";
    return analyzeDateTime(isoString3ToLocalDate(inputDateTime!));
  }

  static String analyzeDateTime(DateTime? inputDateTime) {
    if(inputDateTime == null) return "";

    final now = DateTime.now();
    final difference = now.difference(inputDateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} giây trước';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}
