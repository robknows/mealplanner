spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

breakfastfoodtypes: `cereal`side`bread

spending: select from spending where foodtype in breakfastfoodtypes
groupedbyfoodtype: `foodtype xgroup spending
breakfastfoodnames: exec name from spending
nutrition: select from nutrition where name in breakfastfoodnames
cost: select from cost where name in breakfastfoodnames

categorisednutrition: {
  categorisednames: select name from groupedbyfoodtype where foodtype=x;
  lj[ungroup categorisednames; nutrition]}

cereals: categorisednutrition `cereal
sides:   categorisednutrition `side
breads:  categorisednutrition `bread

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

breakfast_carbsfilter:   macrosfilter[sum;{x > 70}]
breakfast_proteinfilter: macrosfilter[sum;{x > 10}]
breakfast_fatfilter:     macrosfilter[sum;{x > 10}]

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
solvefortwofoods: {[a;b]
  axb_carbpassingindices:    breakfast_carbsfilter   fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: breakfast_proteinfilter fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     breakfast_fatfilter     fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  mapFPIs_names[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b]}

cxb_solution: solvefortwofoods[`cereals;`breads]
cxs_solution: solvefortwofoods[`cereals;`sides]

breakfastsolutions: cxb_solution , cxs_solution

price: {exec sum pricePserving from cost where name in x} each breakfastsolutions
ingredients: breakfastsolutions
requiredshops: {exec distinct boughtfrom from spending where name in x} each breakfastsolutions
nutritionstats: {exec sum gtotalPserving,sum calsPserving,sum gcarbsPserving,sum gproteinPserving,sum gfatPserving from nutrition where name in x} each breakfastsolutions

solutionstable: ([]
  price: price;
  ingredients: ingredients;
  requiredshops: requiredshops;
  gtotal: nutritionstats `gtotalPserving;
  cals: nutritionstats `calsPserving;
  gcarbs: nutritionstats `gcarbsPserving;
  gprotein: nutritionstats `gproteinPserving;
  gfat: nutritionstats `gfatPserving)
  
planbreakfast: {solutionstable}
