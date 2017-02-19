spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

\l planlib.q

.lunch.foodtypes: `meat`healthy`staple`bread`canned

.lunch.carbsreq: 75
.lunch.proteinreq: 40
.lunch.fatreq: 50

.lunch.spending:          .planlib.spending[`lunch;.lunch.foodtypes]
.lunch.groupedbyfoodtype: `foodtype xgroup .lunch.spending
.lunch.foodnames:         exec name from .lunch.spending
.lunch.nutrition:         select from nutrition where name in .lunch.foodnames
.lunch.cost:              select from cost      where name in .lunch.foodnames

.lunch.categorisednutrition: .planlib.categorisenutrition[.lunch.spending;.lunch.nutrition]

lunch_meats:    .lunch.categorisednutrition `meat
lunch_healthys: .lunch.categorisednutrition `healthy
lunch_staples:  .lunch.categorisednutrition `staple
lunch_breads:   .planlib.triplebreadvalues .lunch.categorisednutrition `bread
lunch_canneds:  .lunch.categorisednutrition `canned


.lunch.optionalfoodtypes: `lunch_staples`lunch_breads`lunch_canneds

/
Gives a table giving the maximum values for each of the macronutrients
  for each of the optional foodtypes. I tried using eachboth,
  but I couldn't make it work... Feelsbadman
\
.lunch.macromax: {[table;field] max table[field]}
.lunch.intermediatereqs: ([foods: .lunch.optionalfoodtypes]
  carbs:   {.lunch.carbsreq   - .lunch.macromax[x;y]}\:[.lunch.optionalfoodtypes;`gcarbsPserving];
  protein: {.lunch.proteinreq - .lunch.macromax[x;y]}\:[.lunch.optionalfoodtypes;`gproteinPserving];
  fat:     {.lunch.fatreq     - .lunch.macromax[x;y]}\:[.lunch.optionalfoodtypes;`gfatPserving])

/
Gives a table containing filter functions for the intermediate filtration of
  food combinations that are not going to work, organised by the food type
  that the meat-healthy pair is being tested against and the 3 macronutrients
  that form the basis of each test.
\
.lunch.checkmacro: {[foodt;macroname;val] val > (.lunch.intermediatereqs foodt)[macroname]}
.lunch.intermediatefilterfunc: {[foodt;macro] .planlib.macrosfilter[sum;.lunch.checkmacro[foodt;macro]]}
.lunch.filters: ([foods: .lunch.optionalfoodtypes]
  carbs:   .lunch.intermediatefilterfunc\:[.lunch.optionalfoodtypes;`carbs];
  protein: .lunch.intermediatefilterfunc\:[.lunch.optionalfoodtypes;`protein];
  fat:     .lunch.intermediatefilterfunc\:[.lunch.optionalfoodtypes;`fat])

/
We must convert the list of viable combinations back into a table to
  be compared against their corresponding foodtype for validity.
\
.lunch.mxh_viables: {[side;field] .planlib.axb_viables[`lunch_meats;`lunch_healthys;.lunch.filters side;field]}
.lunch.mxh_tabulateviables: {[foodtype]
  ([]
    name: .lunch.mxh_viables[foodtype;`name];
    gtotalPserving: sum each .lunch.mxh_viables[foodtype;`gtotalPserving];
    calsPserving: sum each .lunch.mxh_viables[foodtype;`calsPserving];
    gcarbsPserving: sum each .lunch.mxh_viables[foodtype;`gcarbsPserving];
    gproteinPserving: sum each .lunch.mxh_viables[foodtype;`gproteinPserving];
    gfatPserving: sum each .lunch.mxh_viables[foodtype;`gfatPserving])}

.lunch.generalfilters: .planlib.generalfilters[.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq;.lunch.optionalfoodtypes]

.lunch.gensolution: {[supplementfood] .planlib.axb_viables[.lunch.mxh_tabulateviables[supplementfood];supplementfood;.lunch.generalfilters supplementfood;`name]}
.lunch.mxhxs_solution: .lunch.gensolution `lunch_staples
.lunch.mxhxb_solution: .lunch.gensolution `lunch_breads
.lunch.mxhxc_solution: .lunch.gensolution `lunch_canneds

.lunch.solutions: .lunch.mxhxs_solution , .lunch.mxhxb_solution , .lunch.mxhxc_solution

.lunch.price:          .planlib.pricesols[.lunch.cost;.lunch.solutions]
.lunch.ingredients:    .lunch.solutions
.lunch.requiredshops:  .planlib.shopsrequiredsols[.lunch.spending;.lunch.solutions]
.lunch.nutritionstats: .planlib.nutritionstats[.lunch.nutrition;.lunch.solutions]

.lunch.plan: {.planlib.solutionstable[.lunch.price;.lunch.ingredients;.lunch.requiredshops;.lunch.nutritionstats]}
