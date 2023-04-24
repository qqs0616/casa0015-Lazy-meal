import 'package:food_app/http/http.dart';

///Find full meal details by id
Future searchById({required int id}) async {
  return await HttpService.getInstance().get(path: "lookup.php?i=$id");
}
