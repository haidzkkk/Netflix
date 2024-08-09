import 'package:intl/intl.dart';

class DateConverter {

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  static String dateToDateAndTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String? dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime!);
  }

  static DateTime isoString2ToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime);
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String stringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String localDateToIsoString2(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }

  static String localDateToIsoString3(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(dateTime);
  }

  static String localDateToString(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static DateTime? localStringToDateTime(String? dateTime) {
    if(dateTime == null ) return null;
    return DateFormat('dd/MM/yyyy').parse(dateTime);
  }

  static DateTime convertStringTimeToDate(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String stringNomalDateToIsoDate(String? dateString) {
    if(dateString == null || dateString.isEmpty){
      return '';
    }
    DateTime dateTime = DateFormat("dd/MM/yyyy").parse(dateString);
    return DateFormat("yyyy-MM-ddTHH:mm:ss").format(dateTime);
  }


  static String stringIsoDateToNomalDate(String? dateString) {
    if(dateString == null || dateString.isEmpty){
      return '';
    }
    DateTime dateTime = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(dateString);

    return DateFormat("dd/MM/yyyy").format(dateTime);
  }
  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('h:mm a | d-MMM-yyyy ').format(dateTime.toLocal());
  }

  static int dateTimeToMillisecondsSinceEpoch(DateTime dateTime){
    return dateTime.millisecondsSinceEpoch;
  }

  static DateTime? millisecondsSinceEpochToDateTime(int? data){
    if(data == null || data == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(data);
  }

  static String millisecondsSinceEpochToString(int? data){
    return data != null ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(data)) : '';
  }

  static String millisecondsSinceEpochToString2(int data){
    return DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(data));
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


  static String convertArrayToDateString(List<int>? createDate) {
    if(createDate == null) return '';
    final year = createDate[0];
    final month = createDate[1];
    final day = createDate[2];
    final dateTime = DateTime(year, month, day);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateString = dateFormat.format(dateTime);
    return dateString;
  }

  static String isoStringToLocalString(String? data) {
    if(data == null || data.isEmpty) return "";
    return DateFormat('dd/MM/yyyy').format(isoStringToLocalDate(data));
  }

  static String isoString2ToLocalString(String? data) {
    if(data == null || data.isEmpty) return "";
    return DateFormat('dd/MM/yyyy').format(isoString2ToLocalDate(data));
  }

}
