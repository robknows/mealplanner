\c 25 200

spending: value`:tables/spending
givenstats: value`:tables/givenstats
nutrition: value`:tables/nutrition
cost: value`:tables/cost
mymeals:value`:tables/mymeals

\l deploy/sattr.q

solutions: value`:tables/lastsolutions

contains: {x like ("*", y , "*")}

mealstats: {[foodnames]
  nutritionalinfo: exec gt:sum gtotalPserving,cl:sum calsPserving,cb:sum gcarbsPserving,pr:sum gproteinPserving,ft:sum gfatPserving from nutrition each foodnames;
  price:exec sum pricePserving from cost each foodnames;
  gTotal:nutritionalinfo[`gt];
  cals:nutritionalinfo[`cl];
  carbs:nutritionalinfo[`cb];
  protein:nutritionalinfo[`pr];
  fat:nutritionalinfo[`ft];
  stats:(price;gTotal;cals;carbs;protein;fat);
  `price`gTotal`nCals`gCarbs`gProtein`gFat!stats}
