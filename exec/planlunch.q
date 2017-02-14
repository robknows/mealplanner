spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

lunchfoodtypes: `meat`healthy`staple`bread`canned

carbsreq: 60
proteinreq: 30
fatreq: 30

spending: select from spending where foodtype in lunchfoodtypes
groupedbyfoodtype: `foodtype xgroup spending
lunchfoodnames: exec name from spending
nutrition: select from nutrition where name in lunchfoodnames
cost: select from cost where name in lunchfoodnames

categorisednutrition: {
  categorisednames: select name from groupedbyfoodtype where foodtype=x;
  lj[ungroup categorisednames; nutrition]}

meats: categorisednutrition `meat
healthys: categorisednutrition `healthy
staples: categorisednutrition `staple
breads: categorisednutrition `bread
canneds: categorisednutrition `canned

/
Triple the used values for bread nutrition because in a meal I would
  of course never eat just one slice, I'd eat 3 or 4. Here I will
  specify that the meal must be valid given that I eat at least 3
  servings (slices, bagels etc..) of the bread.

  The last 2 lines here are just moving name to be the first column
    solely to satisfy my need for the 'name' column to go first.
\
triple: {3*x}
breads: update name: breads[`name] from (flip `gtotalPserving`calsPserving`gcarbsPserving`gproteinPserving`gfatPserving ! {triple breads x} each `gtotalPserving`calsPserving`gcarbsPserving`gproteinPserving`gfatPserving)
`name xkey `breads;
breads: 0!breads

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

optional_lunchfoodtypes: `staples`breads`canneds

/
Gives a table giving the maximum values for each of the macronutrients
  for each of the optional foodtypes. I tried using eachboth,
  but I couldn't make it work... Feelsbadman
\
macromax: {[table;field] max table[field]}
intermediatereqs: ([foods: optional_lunchfoodtypes]
  carbs:   {carbsreq   - macromax[x;y]}\:[optional_lunchfoodtypes;`gcarbsPserving];
  protein: {proteinreq - macromax[x;y]}\:[optional_lunchfoodtypes;`gproteinPserving];
  fat:     {fatreq     - macromax[x;y]}\:[optional_lunchfoodtypes;`gfatPserving])

/
Gives a table containing filter functions for the intermediate filtration of
  food combinations that are not going to work, organised by the food type
  that the meat-healthy pair is being tested against and the 3 macronutrients
  that form the basis of each test.
\
checkmacro: {[foodt;macroname;val] val > (intermediatereqs foodt)[macroname]}
intermediatefilterfunc: {[foodt;macro] macrosfilter[sum;checkmacro[foodt;macro]]}
filters: ([foods: optional_lunchfoodtypes]
  carbs:   intermediatefilterfunc\:[optional_lunchfoodtypes;`carbs];
  protein: intermediatefilterfunc\:[optional_lunchfoodtypes;`protein];
  fat:     intermediatefilterfunc\:[optional_lunchfoodtypes;`fat])

/
We must now traverse back through our solutions to convert the FPIS
  (fatpassingindices) to the names of their corresponding food combination
  of an element of AS and an element of BS.

C are the carb passing indices
P are the protein passing indices

To do this it goes from FPIS back into the ppis, selecting only those
  which passes the fat test, then from ppis back into cpis, again,
  selecting only those which have passed the first two tests, and then
  finally it turns these indices into a cross of whatever field you
  choose.

\
mapFPIs: {[fpis;p;c;as;bs;field]
  ppis: p fpis;
  cpis: c ppis;
  fieldcross[field;as;bs] cpis}

/
Returns the names of the 2 food (A and B) combinations that pass all
  of the filters specified in the dictionary FILTERFUNCTIONS.
\
axb_viables: {[a;b;filterfunctions;field]
  axb_carbpassingindices:    filterfunctions[`carbs]   fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: filterfunctions[`protein] fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     filterfunctions[`fat]     fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  mapFPIs[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b;field]}

/
We must convert the list of viable combinations back into a table to
  be compared against their corresponding foodtype for validity.
\
mxh_viables: {[side;field] axb_viables[`meats;`healthys;filters side;field]}
mxh_tabulateviables: {[foodtype]
  ([]
    name: mxh_viables[foodtype;`name];
    gtotalPserving: sum each mxh_viables[foodtype;`gtotalPserving];
    calsPserving: sum each mxh_viables[foodtype;`calsPserving];
    gcarbsPserving: sum each mxh_viables[foodtype;`gcarbsPserving];
    gproteinPserving: sum each mxh_viables[foodtype;`gproteinPserving];
    gfatPserving: sum each mxh_viables[foodtype;`gfatPserving])}

/
For this test, no optimisation is being done, so we check that they
  pass the general requirements in our filter function.
\
generalfilter: {[req] macrosfilter[sum;>[;req]]}
generalfilters: ([foods: optional_lunchfoodtypes]
  carbs:   3 # generalfilter[carbsreq];
  protein: 3 # generalfilter[proteinreq];
  fat:     3 # generalfilter[fatreq])

gensolution: {[supplementfood] axb_viables[mxh_tabulateviables[supplementfood];supplementfood;generalfilters supplementfood;`name]}
mxhxs_solution: gensolution `staples
mxhxb_solution: gensolution `breads
mxhxc_solution: gensolution `canneds

solutions: mxhxs_solution , mxhxb_solution , mxhxc_solution
