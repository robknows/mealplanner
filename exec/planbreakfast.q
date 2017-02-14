spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

.breakfast.foodtypes: `cereal`side`bread

.breakfast.carbsreq: 70
.breakfast.proteinreq: 10
.breakfast.fatreq: 10

.breakfast.spending: select from spending where foodtype in .breakfast.foodtypes, {x 0} each inmeals
.breakfast.groupedbyfoodtype: `foodtype xgroup .breakfast.spending
.breakfast.foodnames: exec name from .breakfast.spending
.breakfast.nutrition: select from nutrition where name in .breakfast.foodnames
.breakfast.cost: select from cost where name in .breakfast.foodnames

.breakfast.categorisednutrition: {
  categorisednames: select name from .breakfast.groupedbyfoodtype where foodtype=x;
  lj[ungroup categorisednames; .breakfast.nutrition]}

breakfast_cereals: .breakfast.categorisednutrition `cereal
breakfast_sides:   .breakfast.categorisednutrition `side
breakfast_breads:  .breakfast.categorisednutrition `bread

/
Returns the result of AS.FIELD cross BS.FIELD
\
fieldcross: {[field;as;bs]
  as[field] cross bs[field]}

/
Returns the indices at which L, when flipped and then transformed with 
  function TF return true for the predicate REQF.
\
macrosfilter: {[tf;reqf;l]
  asXbs: tf flip l;
  where reqf asXbs}

.breakfast.carbsfilter:   macrosfilter[sum;{x > .breakfast.carbsreq}]
.breakfast.proteinfilter: macrosfilter[sum;{x > .breakfast.proteinreq}]
.breakfast.fatfilter:     macrosfilter[sum;{x > .breakfast.fatreq}]

/
We must now traverse back through our solutions to convert the FPIS
  (fatpassingindices) to the names of their corresponding food combination
  of an element of AS and an element of BS.
  
To do this it goes from FPIS back into the ppis, selecting only those
  which passes the fat test, then from ppis back into cpis, again, 
  selecting only those which have passed the first two tests, and then
  finally it turns these indices into names. This explains why this
  function requres C and P and parameters
\
mapFPIs_names: {[fpis;p;c;as;bs]
  ppis: p fpis;
  cpis: c ppis;
  fieldcross[`name;as;bs] cpis}

/
Returns the names of the 2 food combinations that pass all requirements
  given two sets of foods A and B.
\
.breakfast.axb_viable: {[a;b]
  axb_carbpassingindices:    .breakfast.carbsfilter   fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: .breakfast.proteinfilter fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     .breakfast.fatfilter     fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  mapFPIs_names[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b]}

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
