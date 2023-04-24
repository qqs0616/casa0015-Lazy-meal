import '../http/index.dart';

///Get all areas
Future getAllArea() async {
  return await HttpService.getInstance().get(path: "list.php?a=list");
}

///According to the national filter
Future filterArea({required String area}) async {
  return await HttpService.getInstance().get(path: "filter.php?a=$area");
}

///Filter by category
Future filterCuisine({required String cuisine}) async {
  return await HttpService.getInstance().get(path: "filter.php?c=$cuisine");
}

///Filtered according to ingredients
Future filterIngredients({required String ingredients}) async {
  return await HttpService.getInstance().get(path: "filter.php?i=$ingredients");
}

///Get all categories
Future getAllCategory() async {
  return await HttpService.getInstance().get(path: "list.php?c=list");
}

///Get all ingredients
Future getAllIngredients() async {
  return await HttpService.getInstance().get(path: "list.php?i=list");
}

///Get food list by name
Future getFoodFromName({required String name}) async {
  return await HttpService.getInstance().get(path: "search.php?s=$name");
}
