
import 'package:equatable/equatable.dart';

enum StatusEnum{
  initial,
  loading,
  successfully,
  failed,
}

class Status<T> extends Equatable{
  final StatusEnum status;
  final T? data;
  final String? message;

  const Status({
    required this.status,
    this.data,
    this.message
  });

  factory Status.initial(){
    return const Status(
        status: StatusEnum.initial
    );
  }

  factory Status.loading({T? data}){
    return Status(
      status: StatusEnum.loading,
      data: data,
    );
  }

  factory Status.success({required T? data, String? message}){
    return Status(
        status: StatusEnum.successfully,
        data: data,
        message: message ?? (data == null ? "Not found value" : "Success"),
    );
  }

  factory Status.failed({T? data, required String message}){
    return Status(
        status: StatusEnum.failed,
        data: data,
        message: message,
    );
  }

  @override
  List<Object?> get props => [status, data, message];
}