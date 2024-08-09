// import 'package:get/get.dart';
// import 'package:get_it/get_it.dart';
// import '../../presentation/components/utility/snackbar.dart';
// import '../repositories/auth_repo.dart';
//
// class ApiChecker {
//   static void checkApi(Response response,{bool? showSnackBar}) {
//     if (response.statusCode == 401) {
//       GetIt.instance.get<AuthRepo>().clearUserToken();
//       // Get.offAll(() => LoginScreen());
//       return;
//     } else {
//       if(showSnackBar == null) {
//         showCustomSnackBar(response.statusText ?? "error");
//       }
//     }
//   }
// }
