spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

\l planlib.q

.breakfast.foodtypes: `cereal`side`bread

.breakfast.carbsreq: 70
.breakfast.proteinreq: 10
.breakfast.fatreq: 10

.breakfast.spending:  .planlib.spending[`breakfast;.breakfast.foodtypes]
.breakfast.foodnames: exec name from .breakfast.spending
.breakfast.nutrition: select from nutrition where name in .breakfast.foodnames
.breakfast.cost:      select from cost where name in .breakfast.foodnames

.breakfast.categorisednutrition: .planlib.categorisenutrition[.breakfast.spending;.breakfast.nutrition]

breakfast_cereals: .breakfast.categorisednutrition `cereal
breakfast_sides:   .breakfast.categorisednutrition `side
breakfast_breads:  .breakfast.categorisednutrition `bread

.breakfast.options: `breakfast_sides`breakfast_breads

.breakfast.filters: .planlib.filters[.breakfast.options;(.breakfast.carbsreq;.breakfast.proteinreq;.breakfast.fatreq)]

.breakfast.solutions: .planlib.concatmap[{[ft] .planlib.axb_viables[`breakfast_cereals;ft;.breakfast.filters ft;`name]};.breakfast.options]

.breakfast.plan: {.planlib.solution[.breakfast.spending;.breakfast.nutrition;.breakfast.cost;.breakfast.solutions]}
