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

.breakfast.macrosfilter:   {[macroreq] .planlib.macrosfilter[sum;{y > x} macroreq]}
.breakfast.carbsfilter:   .breakfast.macrosfilter .breakfast.carbsreq
.breakfast.proteinfilter: .breakfast.macrosfilter .breakfast.proteinreq
.breakfast.fatfilter:     .breakfast.macrosfilter .breakfast.fatreq
.breakfast.filters: `carbs`protein`fat!(.breakfast.carbsfilter;.breakfast.proteinfilter;.breakfast.fatfilter)

.breakfast.axb_viables: {[a;b] .planlib.axb_viables[a;b;.breakfast.filters;`name]}
.breakfast.cxb_solution: .breakfast.axb_viables[`breakfast_cereals;`breakfast_breads]
.breakfast.cxs_solution: .breakfast.axb_viables[`breakfast_cereals;`breakfast_sides]

.breakfast.solutions: .breakfast.cxb_solution , .breakfast.cxs_solution

.breakfast.price: .planlib.pricesols[.breakfast.cost;.breakfast.solutions]
.breakfast.ingredients: .breakfast.solutions
.breakfast.requiredshops: .planlib.shopsrequiredsols[.breakfast.spending;.breakfast.solutions]
.breakfast.nutritionstats: {exec sum gtotalPserving,sum calsPserving,sum gcarbsPserving,sum gproteinPserving,sum gfatPserving from .breakfast.nutrition where name in x} each .breakfast.solutions

.breakfast.plan: {([]
  price: .breakfast.price;
  ingredients: .breakfast.ingredients;
  requiredshops: .breakfast.requiredshops;
  gtotal: .breakfast.nutritionstats `gtotalPserving;
  cals: .breakfast.nutritionstats `calsPserving;
  gcarbs: .breakfast.nutritionstats `gcarbsPserving;
  gprotein: .breakfast.nutritionstats `gproteinPserving;
  gfat: .breakfast.nutritionstats `gfatPserving)}
