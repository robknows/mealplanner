\c 25 160

spending: value`:tables/spending
givenstats: value`:tables/givenstats
nutrition: value`:tables/nutrition
cost: value`:tables/cost

/
The solutions to the last call of ./mealplanner
\
solutions: value`:tables/lastsolutions

/
Returns true if the string x contains the string y
\
contains: {x like ("*", y , "*")}

/
x=A list of symbols corresponding to names of foods
\
mealstats: {
  nutritionalinfo: exec gt:sum gtotalPserving,cl:sum calsPserving,cb:sum gcarbsPserving,pr:sum gproteinPserving,ft:sum gfatPserving from nutrition each x;
  price:exec sum pricePserving from cost each x;
  gTotal:nutritionalinfo[`gt];
  cals:nutritionalinfo[`cl];
  carbs:nutritionalinfo[`cb];
  protein:nutritionalinfo[`pr];
  fat:nutritionalinfo[`ft];
  stats:(price;gTotal;cals;carbs;protein;fat);
  `price`gTotal`nCals`gCarbs`gProtein`gFat!stats}

sattr: {[t]
  c:first cols t;
  a:`g`u 1=n:count keys t;
  t:n!@[;c;a#]0!t;
  t}
