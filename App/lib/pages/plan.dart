import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_app/untils/index.dart';
import 'package:food_app/widgets/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/index.dart';
import '../main.dart';

///plan page
class PlanPage extends StatefulWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  State<PlanPage> createState() => _PlanPageState();
}

///For local refreshes
ValueNotifier<List> planDataList = ValueNotifier([]);

///All plan's data
ValueNotifier<List<Map>> planList = ValueNotifier([]);

Future getPlanData() async {
  sharedPreferences = await SharedPreferences.getInstance();
  var planString = sharedPreferences.getString("plan") ?? "";
  if (planString.isNotEmpty) {
    planDataList.value = json.decode(planString);
    planDataList.notifyListeners();
    //Initialize List
    planList.value = [];
    for (var element1 in planDataList.value) {
      //Determine if data is already available at this point in time
      bool isHave =
          planList.value.any((element) => element["time"] == element1["time"]);

      //If already included
      if (isHave) {
        //Find that Map and add the data to the end
        Map firstWhere = planList.value
            .firstWhere((element) => element["time"] == element1["time"]);
        firstWhere["data"].add(element1);
      } else {
        //If don't find it, add the data yourself
        Map map = {
          "time": element1["time"],
          "data": [element1],
        };
        planList.value.add(map);
      }
      planList.notifyListeners();
    }
  }
}

class _PlanPageState extends State<PlanPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPlanData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    planDataList.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ValueListenableBuilder(
        builder: (BuildContext context, List value, Widget? child) {
          //data other than today

          return value.isEmpty
              ? const Center(
                  child: Text(
                    "No Meal Plan list",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding),
                    child: CustomScrollView(
                      slivers: [
                        _buildTitle(),
                        const SliverToBoxAdapter(
                          child: SpaceVerticalWidget(),
                        ),
                        _buildTodayList(size, value),
                        const SliverToBoxAdapter(
                          child: SpaceVerticalWidget(),
                        ),
                        _secondTitle(),
                        const SliverToBoxAdapter(
                          child: SpaceVerticalWidget(),
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            var previousData = _getPreviousData(value)[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTime(previousData["time"]),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.grey),
                                ),
                                const SpaceVerticalWidget(),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      var data = previousData["data"][index];
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: CheckPlanWidget(
                                          src: '${data["strMealThumb"]}',
                                          isCheck: data["isCheck"],
                                          onTap: () async {
                                            await _checkPlan(data);
                                          },
                                        ),
                                      );
                                    },
                                    itemCount: previousData["data"].length,
                                  ),
                                ),
                                const SpaceVerticalWidget(),
                              ],
                            );
                          }, childCount: _getPreviousData(value).length),
                        ),
                        // _buildTestButton()
                      ],
                    ),
                  ),
                );
        },
        valueListenable: planList,
      ),
    );
  }

  ///Convert the time to the desired format
  String getTime(String time) {
    String date = "";
    int firstIndex = time.indexOf("-");
    int lastIndex = time.lastIndexOf("-");
    String? month = monthMap[time.substring(firstIndex + 1, lastIndex)];
    String day = time.substring(lastIndex + 1, time.length);
    date = "$month ${day}th";
    return date;
  }

  ///test adding data
  SliverToBoxAdapter _buildTestButton() {
    return SliverToBoxAdapter(
      child: TextButton(
          onPressed: () async {
            Map map = {
              "idMeal": "52842",
              "strMeal": "Broccoli & Stilton soup",
              "strDrinkAlternate": null,
              "strCategory": "Starter",
              "strArea": "British",
              "strInstructions":
                  "Heat the rapeseed oil in a large saucepan and then add the onions. Cook on a medium heat until soft. Add a splash of water if the onions start to catch.\r\n\r\nAdd the celery, leek, potato and a knob of butter. Stir until melted, then cover with a lid. Allow to sweat for 5 minutes. Remove the lid.\r\n\r\nPour in the stock and add any chunky bits of broccoli stalk. Cook for 10 – 15 minutes until all the vegetables are soft.\r\n\r\nAdd the rest of the broccoli and cook for a further 5 minutes. Carefully transfer to a blender and blitz until smooth. Stir in the stilton, allowing a few lumps to remain. Season with black pepper and serve.",
              "strMealThumb":
                  "https://www.themealdb.com/images/media/meals/tvvxpv1511191952.jpg",
              "strTags": null,
              "strYoutube": "https://www.youtube.com/watch?v=_HgVLpmNxTY",
              "strIngredient1": "Rapeseed Oil",
              "strIngredient2": "Onion",
              "strIngredient3": "Celery",
              "strIngredient4": "Leek",
              "strIngredient5": "Potatoes",
              "strIngredient6": "Butter",
              "strIngredient7": "Vegetable Stock",
              "strIngredient8": "Broccoli",
              "strIngredient9": "Stilton Cheese",
              "strIngredient10": "",
              "strIngredient11": "",
              "strIngredient12": "",
              "strIngredient13": "",
              "strIngredient14": "",
              "strIngredient15": "",
              "strIngredient16": "",
              "strIngredient17": "",
              "strIngredient18": "",
              "strIngredient19": "",
              "strIngredient20": "",
              "strMeasure1": "2 tblsp ",
              "strMeasure2": "1 finely chopped ",
              "strMeasure3": "1",
              "strMeasure4": "1 sliced",
              "strMeasure5": "1 medium",
              "strMeasure6": "1 knob",
              "strMeasure7": "1 litre hot",
              "strMeasure8": "1 Head chopped",
              "strMeasure9": "140g",
              "strMeasure10": "",
              "strMeasure11": "",
              "strMeasure12": "",
              "strMeasure13": "",
              "strMeasure14": "",
              "strMeasure15": "",
              "strMeasure16": "",
              "strMeasure17": "",
              "strMeasure18": "",
              "strMeasure19": "",
              "strMeasure20": "",
              "strSource":
                  "https://www.bbcgoodfood.com/recipes/1940679/broccoli-and-stilton-soup",
              "strImageSource": null,
              "strCreativeCommonsConfirmed": null,
              "dateModified": null,
              "time": "2023-3-6",
              "isCheck": false
            };
            planDataList.value.add(map);
            await sharedPreferences.setString(
                "plan", json.encode(planDataList.value));
          },
          child: Text("123")),
    );
  }

  ///second title
  SliverToBoxAdapter _secondTitle() {
    return const SliverToBoxAdapter(
      child: TitleWidget(
        title: "Previous meal plans",
        fontSize: 30,
        hasButton: false,
      ),
    );
  }

  SliverToBoxAdapter _buildTodayList(Size size, List<dynamic> value) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: size.height * .28,
     
        child: value.any(_todayCondition)
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var data = _getTodayFirstData(value)[index];
                  return _buildItem(size, data);
                },
                itemCount: _getTodayFirstData(value).length,
              )
            : _buildNoToadyData(),
      ),
    );
  }

  ///List item
  Container _buildItem(Size size, data) {
    return Container(
      margin: const EdgeInsets.only(right: padding * 2),
      width: size.height * .2,
      height: size.width * .28,
      child: Column(
        children: [
          SizedBox(
            width: size.height * .2,
            height: size.height * .2,
            child: CheckPlanWidget(
              src: data["strMealThumb"],
              isCheck: data["isCheck"],
              onTap: () async {
                await _checkPlan(data);
              },
            ),
          ),
          // _buildImagePlan(data, size),
          const SpaceVerticalWidget(),
          Expanded(
            child: Text(
              data["strMeal"],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Center _buildNoToadyData() {
    return const Center(
      child: Text(
        "You haven't added a plan today",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    );
  }

  ///Change the status of whether you have completed today's plan
  Future<void> _checkPlan(data) async {
    data["isCheck"] = !data["isCheck"];
    planList.notifyListeners();
    //Find the one with the same ID and time and store the data
    Map map = planDataList.value.firstWhere((element) =>
        element["idMeal"] == data["idMeal"] && element["time"] == data["time"]);
    map["isCheck"] = data["isCheck"];
    await sharedPreferences.setString("plan", json.encode(planDataList.value));
  }

  ///title
  SliverToBoxAdapter _buildTitle() {
    return SliverToBoxAdapter(
      child: TitleWidget(
        title: 'Meal Plan',
        onPress: () async {
          planList.value = [];
          planDataList.value = [];
          planList.notifyListeners();
          planDataList.notifyListeners();
          await sharedPreferences.setString("plan", "");
        },
      ),
    );
  }


  List<dynamic> _getTodayFirstData(List<dynamic> value) {
    return (value.firstWhere(_todayCondition))["data"];
  }


  List<dynamic> _getPreviousData(List<dynamic> value) {
    return value.where((element) => _previousCondition(element)).toList();
  }


  bool _todayCondition(element) =>
      element["time"] == DateTime.now().toString().substring(0, 10);


  bool _previousCondition(element) =>
      element["time"] != DateTime.now().toString().substring(0, 10);

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


