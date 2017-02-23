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
lunch_mxh:      .planlib.tabulate_multifoods[`lunch_meats;`lunch_healthys]
.lunch.options: `lunch_staples`lunch_breads`lunch_canneds

.lunch.filters:        .planlib.filters[.lunch.options;(.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq)]
.lunch.generalfilters: .planlib.generalfilters[.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq;.lunch.options]

.lunch.viable_mxhxX: {.planlib.viable_NeededxOption_names[.lunch.filters;.lunch.generalfilters;`lunch_mxh;x]}
.lunch.solutions: .planlib.concatmap[.lunch.viable_mxhxX;.lunch.options]
.lunch.plan: {.planlib.solution[.lunch.spending;.lunch.nutrition;.lunch.cost;.lunch.solutions]}
