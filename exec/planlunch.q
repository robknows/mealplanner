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
lunch_breads:   .lunch.categorisednutrition `bread
lunch_canneds:  .lunch.categorisednutrition `canned

/
Triple the used values for bread nutrition because in a meal I would
  of course never eat just one slice, I'd eat 3 or 4. Here I will
  specify that the meal must be valid given that I eat at least 3
  servings (slices, bagels etc..) of the bread.

  The last 2 lines here are just moving name to be the first column
    solely to satisfy my need for the 'name' column to go first.

  This applies specifically to things which have "bread" in their name,
    because bagels are much larger than slices of bread, so I probably
    wouldn't eat 3 or 4 of them.

  The code below uses a funtional update.
    annotatetripled&make3x_aggregates are there to create a dictionary
    which indicates application of `triple to them.

  The four arguments of the actual update (![`breads;...]) are:
    `breads                                               :: table name
    enlist ({0 < count ss[;"bread"] string x} each;`name) :: selection condition ie. only the ones which have 'bread' in their name
    0b                                                    :: ???
    make3x_aggregates 1_cols breads                       :: dictionary for the tripling of the numeric columns. (1_ is to leave out 'name')

\
.lunch.nSlicesPmeal: 4
lunch_scalebreads: {.lunch.nSlicesPmeal * x}
.lunch.annotatetripled: {(`lunch_scalebreads;x)}
.lunch.make3x_aggregates: {x ! .lunch.annotatetripled each x}
![`lunch_breads;enlist ({0 < count ss[;"bread"] string x} each;`name);0b;.lunch.make3x_aggregates 1_cols lunch_breads];

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

/
For this test, no optimisation is being done, so we check that they
  pass the general requirements in our filter function.
\
.lunch.generalfilter: {[req] .planlib.macrosfilter[sum;>[;req]]}
.lunch.generalfilters: ([foods: .lunch.optionalfoodtypes]
  carbs:   3 # .lunch.generalfilter[.lunch.carbsreq];
  protein: 3 # .lunch.generalfilter[.lunch.proteinreq];
  fat:     3 # .lunch.generalfilter[.lunch.fatreq])

.lunch.gensolution: {[supplementfood] .planlib.axb_viables[.lunch.mxh_tabulateviables[supplementfood];supplementfood;.lunch.generalfilters supplementfood;`name]}
.lunch.mxhxs_solution: .lunch.gensolution `lunch_staples
.lunch.mxhxb_solution: .lunch.gensolution `lunch_breads
.lunch.mxhxc_solution: .lunch.gensolution `lunch_canneds

.lunch.solutions: .lunch.mxhxs_solution , .lunch.mxhxb_solution , .lunch.mxhxc_solution

.lunch.price: .planlib.pricesols[.lunch.cost;.lunch.solutions]
.lunch.ingredients: .lunch.solutions
.lunch.requiredshops: {exec distinct boughtfrom from .lunch.spending where name in x} each .lunch.solutions
.lunch.nutritionstats: {exec sum gtotalPserving,sum calsPserving,sum gcarbsPserving,sum gproteinPserving,sum gfatPserving from .lunch.nutrition where name in x} each .lunch.solutions

.lunch.plan: {([]
  price: .lunch.price;
  ingredients: .lunch.ingredients;
  requiredshops: .lunch.requiredshops;
  gtotal: .lunch.nutritionstats `gtotalPserving;
  cals: .lunch.nutritionstats `calsPserving;
  gcarbs: .lunch.nutritionstats `gcarbsPserving;
  gprotein: .lunch.nutritionstats `gproteinPserving;
  gfat: .lunch.nutritionstats `gfatPserving)}
