spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

\l planlib.q

.breakfast.foodtypes: `cereal`side`bread

.breakfast.carbsreq: 60
.breakfast.proteinreq: 13
.breakfast.fatreq: 2

.breakfast.spending:  .planlib.spending[`breakfast;.breakfast.foodtypes]
.breakfast.foodnames: exec name from .breakfast.spending
.breakfast.nutrition: select from nutrition where name in .breakfast.foodnames
.breakfast.cost:      select from cost where name in .breakfast.foodnames

.breakfast.categorisednutrition: .planlib.categorisenutrition[.breakfast.spending;.breakfast.nutrition]

breakfast_cereals: .breakfast.categorisednutrition `cereal
breakfast_sides:   .breakfast.categorisednutrition `side
breakfast_breads:  .breakfast.categorisednutrition `bread

.breakfast.options: `breakfast_sides`breakfast_breads

.breakfast.filters:        .planlib.filters[.breakfast.options;(.breakfast.carbsreq;.breakfast.proteinreq;.breakfast.fatreq)]
.breakfast.generalfilters: .planlib.generalfilters[.breakfast.carbsreq;.breakfast.proteinreq;.breakfast.fatreq;.breakfast.options]

.breakfast.viable_cxX: {[option]
  viable_cereal_names: .planlib.viables[`breakfast_cereals;.breakfast.filters option; `name];
  viable_cereals: select from `breakfast_cereals where name in viable_cereal_names;
  possibilities: .planlib.tabulate_multifoods[viable_cereals;option];
  .planlib.viables[possibilities;.breakfast.generalfilters option;`name]}

.breakfast.solutions: .planlib.concatmap[.breakfast.viable_cxX;.breakfast.options]

.breakfast.plan: {.planlib.solution[.breakfast.spending;.breakfast.nutrition;.breakfast.cost;.breakfast.solutions]}
