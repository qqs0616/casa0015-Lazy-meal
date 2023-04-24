import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_app/api/index.dart';
import 'package:food_app/pages/details.dart';
import 'package:food_app/pages/index.dart';
import 'package:food_app/untils/index.dart';

import '../common/index.dart';
import '../widgets/index.dart';

///search title
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  //category
  String category = "";
  List categoryList = [];

  //ingredients
  String ingredients = "";
  List ingredientsList = [];

  //area
  String area = "";
  List areaList = [];

  //food
  List foodList = [];

  List tempFoodList = [];

  //sort
  String sort = sortString[0];

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  //get data
  Future getData() async {
    var category = await getAllCategory();
    var ingredients = await getAllIngredients();
    var area = await getAllArea();

    //Default search for all UK food
    var britishArea = await filterArea(area: "British");

    categoryList = category["meals"];
    ingredientsList = ingredients["meals"];
    areaList = area["meals"];
    foodList = britishArea["meals"];
    tempFoodList = List.from(foodList);

    if (categoryList.length > 10) {
      categoryList = categoryList.sublist(0, 10);
    }

    if (ingredientsList.length > 10) {
      ingredientsList = ingredientsList.sublist(0, 10);
    }

    if (areaList.length > 10) {
      areaList = areaList.sublist(0, 10);
    }

    setState(() {});
  }

  ///sort method
  void sortFun() {
    if (sort != "Sort By") {
      if (sort == "Newest") {
        foodList.sort((a, b) => a["idMeal"].compareTo(b["idMeal"]));
      } else {
        foodList.sort((a, b) => b["idMeal"].compareTo(a["idMeal"]));
      }
    } else {
      
      resetFoodList();
    }
    setState(() {});
  }

  ///search method
  Future<void> searchFun() async {
    String search = textEditingController.text;
    var data;
    if (search.isNotEmpty) {
      data = await getFoodFromName(name: search);
      foodList = data["meals"];
      copyFoodList();
    } else {
   
      resetFoodList();
    }

    sortFun();
    setState(() {});
  }

  //copy list
  void copyFoodList() async {
    tempFoodList = List.from(foodList);
  }

  ///Recovering arrays via tempFood
  void resetFoodList() async {
    foodList = List.from(tempFoodList);
  }

  ///pop refreshes the page in a uniform way
  void popFun(data) {
 
    foodList = data["meals"];


    copyFoodList();

    
    sortFun();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildSearch(),
            _buildPopMenu(),
            _buildSort(),
            _buildFoodList()
          ],
        ),
      ),
    );
  }

  ///food list
  Expanded _buildFoodList() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          var data = foodList[index];
          String randomTime = data["idMeal"].substring(1, 2) +
              data["idMeal"].substring(data["isMeal"].toString().length - 1,
                  data["isMeal"].toString().length);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FoodDetailsPage(id: int.parse(data["idMeal"]))));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ExtendedImage.network(
                        data["strMealThumb"],
                        borderRadius: const BorderRadius.all(
                            Radius.circular(padding * 2)),
                        shape: BoxShape.rectangle,
                        clipBehavior: Clip.antiAlias,
                        fit: BoxFit.cover,
                        cache: true,
                        width: 200,
                        height: 200,
                      ),
                      _buildTimeCircle(randomTime),
                    ],
                  ),
                  const SpaceHorizontalWidget(),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["strMeal"].toString().trim(),
                        style: const TextStyle(
                            fontSize: 25,
                            fontFamily: "TiltNeon",
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        },
        itemCount: foodList.length,
      ),
    );
  }

  ///time circle
  Positioned _buildTimeCircle(String randomTime) {
    return Positioned(
      bottom: padding,
      left: padding,
      child: CircleAvatar(
        backgroundColor: Colors.grey[200],
        radius: 20,
        child: Stack(
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: SizedBox(
                  child: CircularProgressIndicator(
                    value: int.parse(randomTime) / 100,
                    strokeWidth: 3,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: 10,
                child: Center(
                  child: Text(
                    randomTime,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///sort 
  Padding _buildSort() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton(
              value: sort,
              icon: const SizedBox.shrink(),
              underline: const SizedBox.shrink(),
              items: sortString
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  sort = value!;
                  sortFun();
                });
              },
            ),
          ),
          const Icon(Icons.arrow_drop_down_outlined)
        ],
      ),
    );
  }

  ///Classification
  Padding _buildPopMenu() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            child: PopMenuWidget(
              icon: const Icon(Icons.menu_open),
              title: 'Cuisine',
              items: categoryList
                  .map((e) => PopupMenuItem(
                        value: e["strCategory"],
                        child: Text(e["strCategory"]),
                      ))
                  .toList(),
              initialValue: category,
              onSelected: (val) async {
                category = val;
                var data = await filterCuisine(cuisine: category);
                popFun(data);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: PopMenuWidget(
              initialValue: ingredients,
              onSelected: (val) async {
                ingredients = val;
                var data = await filterIngredients(ingredients: ingredients);
                popFun(data);
                setState(() {});
              },
              icon: const Icon(Icons.apple),
              title: 'Ingredients',
              items: ingredientsList
                  .map((e) => PopupMenuItem(
                        value: e["strIngredient"],
                        child: Text(e["strIngredient"]),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: PopMenuWidget(
              initialValue: area,
              onSelected: (val) async {
                area = val;
                var data = await filterArea(area: area);
                popFun(data);
                setState(() {});
              },
              icon: const Icon(Icons.area_chart_outlined),
              title: 'Area',
              items: areaList
                  .map((e) => PopupMenuItem(
                        value: e["strArea"],
                        child: Text(e["strArea"]),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  ///Search
  Container _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(padding),
      color: homeTitleColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: TextField(
            controller: textEditingController,
            onSubmitted: (val) async {
              await searchFun();
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(padding),
                  borderSide: BorderSide.none),
              filled: true,
              hintText: "Search what you want",
              prefixIcon: const Icon(Icons.search),
            ),
          )),
          const SpaceHorizontalWidget(),
          GestureDetector(
            onTap: () async {
              await searchFun();
            },
            child: const Text(
              "Search",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  ///AppBar
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: homeTitleColor,
      elevation: 0,
      title: ValueListenableBuilder(
        valueListenable: planDataList,
        builder: (BuildContext context, List<dynamic> value, Widget? child) {
          return Text(
            "Food can heal all your unhappiness${value.isNotEmpty ? smilingFace : cryingFace}",
            style: const TextStyle(
                fontFamily: "TiltNeon", color: Color(0xffBD3124)),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
