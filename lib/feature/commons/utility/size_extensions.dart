
import 'pageutil.dart';

///define size for screen (width, height and sp for fonts)
extension SizeDExtension on num {
  double get w => PageUtil().setWidth(this).toDouble();

  double get h => PageUtil().setHeight(this).toDouble();

  double get sp => PageUtil().setSp(this).toDouble();
}
