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

.breakfast.carbsfilter:   .planlib.macrosfilter[sum;{x > .breakfast.carbsreq}]
.breakfast.proteinfilter: .planlib.macrosfilter[sum;{x > .breakfast.proteinreq}]
.breakfast.fatfilter:     .planlib.macrosfilter[sum;{x > .breakfast.fatreq}]

/
Returns the names of the 2 food combinations that pass all requirements
  given two sets of foods A and B.
\
.breakfast.axb_viable: {[a;b]
  axb_carbpassingindices:    .breakfast.carbsfilter   .planlib.fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: .breakfast.proteinfilter .planlib.fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     .breakfast.fatfilter     .planlib.fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  .planlib.mapFPIs[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b;`name]}

.breakfast.cxb_solution: .breakfast.axb_viable[`breakfast_cereals;`breakfast_breads]
.breakfast.cxs_solution: .breakfast.axb_viable[`breakfast_cereals;`breakfast_sides]

.breakfast.solutions: .breakfast.cxb_solution , .breakfast.cxs_solution

.breakfast.price: {exec sum pricePserving from  .breakfast.cost where name in x} each .breakfast.solutions
.breakfast.ingredients: .breakfast.solutions
.breakfast.requiredshops: {exec distinct boughtfrom from .breakfast.spending where name in x} each .breakfast.solutions
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
