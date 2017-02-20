spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

\l planlib.q

.dinner.foodtypes: `meat`healthy`staple`bread`canned`dessert`side`dairy

.dinner.carbsreq: 50
.dinner.proteinreq: 60
.dinner.fatreq: 50

.dinner.spending:          .planlib.spending[`dinner;.dinner.foodtypes]
.dinner.groupedbyfoodtype: `foodtype xgroup .dinner.spending
.dinner.foodnames:         exec name from .dinner.spending
.dinner.nutrition:         select from nutrition where name in .dinner.foodnames
.dinner.cost:              select from cost      where name in .dinner.foodnames

.dinner.categorisednutrition: .planlib.categorisenutrition[.dinner.spending;.dinner.nutrition]

dinner_meats:    .dinner.categorisednutrition `meat
dinner_healthys: .dinner.categorisednutrition `healthy
dinner_staples:  .dinner.categorisednutrition `staple
dinner_breads:   .planlib.triplebreadvalues .dinner.categorisednutrition `bread
dinner_canneds:  .dinner.categorisednutrition `canned
dinner_desserts: .dinner.categorisednutrition `dessert
dinner_sides:    .dinner.categorisednutrition `side
dinner_dairys:   .dinner.categorisednutrition `dairy

.dinner.optionsA: `dinner_staples`dinner_breads`dinner_canneds
.dinner.optionsB: `dinner_desserts`dinner_sides`dinner_dairys

.dinner.options: `dinner_staples`dinner_breads`dinner_canneds cross `dinner_desserts`dinner_sides`dinner_dairys
.dinner.filters: .planlib.filters[.dinner.options;(.dinner.carbsreq;.dinner.proteinreq;.dinner.fatreq)]

.dinner.mxh_viables: {[sides;field] .planlib.axb_viables[`dinner_meats;`dinner_healthys;.dinner.filters sides;field]}

.dinner.generalfilters: .planlib.generalfilters[.dinner.carbsreq;.dinner.proteinreq;.dinner.fatreq;.dinner.options]

.dinner.gensolution: {[sides]
  viable_intermediates: .planlib.tabulateviables .dinner.mxh_viables sides;
  tabulate_sides: .planlib.tabulate_multifoods[sides 0;sides 1];
  .planlib.axb_viables[viable_intermediates;tabulate_sides;.dinner.generalfilters sides;`name]}

.dinner.solutions: .planlib.concatmap[.dinner.gensolution;.dinner.options]

.dinner.plan: {.planlib.solution[.dinner.spending;.dinner.nutrition;.dinner.cost;.dinner.solutions]}
