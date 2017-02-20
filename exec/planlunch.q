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
.lunch.filters: .planlib.filters[.lunch.optionalfoodtypes;(.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq)]

.lunch.mxh_viables: {[side;field] .planlib.axb_viables[`lunch_meats;`lunch_healthys;.lunch.filters side;field]}

.lunch.generalfilters: .planlib.generalfilters[.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq;.lunch.optionalfoodtypes]

.lunch.gensolution: {[supplementfood]
  viable_intermediates: .planlib.tabulateviables .lunch.mxh_viables supplementfood;
  .planlib.axb_viables[viable_intermediates;supplementfood;.lunch.generalfilters supplementfood;`name]}

.lunch.solutions: .planlib.concatmap[.lunch.gensolution;.lunch.optionalfoodtypes]

.lunch.price:          .planlib.pricesols[.lunch.cost;.lunch.solutions]
.lunch.ingredients:    .lunch.solutions
.lunch.requiredshops:  .planlib.shopsrequiredsols[.lunch.spending;.lunch.solutions]
.lunch.nutritionstats: .planlib.nutritionstats[.lunch.nutrition;.lunch.solutions]

.lunch.plan: {.planlib.solutionstable[.lunch.price;.lunch.ingredients;.lunch.requiredshops;.lunch.nutritionstats]}
