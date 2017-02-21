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

.lunch.options: `lunch_staples`lunch_breads`lunch_canneds

.lunch.filters:        .planlib.filters[.lunch.options;(.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq)]
.lunch.generalfilters: .planlib.generalfilters[.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq;.lunch.options]

lunch_mxh: .planlib.tabulate_multifoods[`lunch_meats;`lunch_healthys]

.lunch.viable_mxhxX: {[option]
  viable_mxh_names: .planlib.viables[`lunch_mxh;.lunch.filters option; `name];
  viable_mxhs: select from `lunch_mxh where name in viable_mxh_names;
  possibilities: .planlib.tabulate_multifoods[viable_mxhs;option];
  .planlib.viables[possibilities;.lunch.generalfilters option;`name]}

.lunch.solutions: .planlib.concatmap[.lunch.viable_mxhxX;.lunch.options]

.lunch.plan: {.planlib.solution[.lunch.spending;.lunch.nutrition;.lunch.cost;.lunch.solutions]}
