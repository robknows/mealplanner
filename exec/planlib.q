.planlib.foodtypes: `breakfast`lunch`dinner

.planlib.spending: {[ft;mealfoodtypes]
  ftidx: first where .planlib.foodtypes=ft;
  select from spending where foodtype in mealfoodtypes, {y x}[ftidx] each inmeals};

.planlib.categorisenutrition: {[ftspending;ftnutrition;ft]
  groupedbyfoodtype: `foodtype xgroup ftspending;
  categorisednames: select name from groupedbyfoodtype where foodtype=ft;
  lj[ungroup categorisednames; ftnutrition]}

/
Triple the used values for bread nutrition because in a meal I would
  of course never eat just one slice, I'd eat 3 or 4. Here I will
  specify that the meal must be valid given that I eat at least 3
  servings (slices, bagels etc..) of the bread.

This applies specifically to things which have "bread" in their name,
  because bagels are much larger than slices of bread, so I probably
  wouldn't eat 3 or 4 of them.

The four arguments of the functional update (![`breads;...]) are:
  `breads                                               :: table name
  enlist ({0 < count ss[;"bread"] string x} each;`name) :: selection condition ie. only the ones which have 'bread' in their name
  0b                                                    :: ???
  make3x_aggregates 1_cols breads                       :: dictionary for the tripling of the numeric columns. (1_ is to leave out 'name')
\
.planlib.breadslicesPmeal: 4
planlib_scalebreads: {.planlib.breadslicesPmeal * x}
.planlib.annotatetripled: {(`planlib_scalebreads;x)}
.planlib.make3x_aggregates: {x ! .planlib.annotatetripled each x}
.planlib.triplebreadvalues: {[breads] ![breads;enlist ({0 < count ss[;"bread"] string x} each;`name);0b;.planlib.make3x_aggregates 1_cols breads]}

/
Returns the result of AS.FIELD cross BS.FIELD
\
.planlib.fieldcross: {[field;as;bs] as[field] cross bs[field]}
  
/
Returns the indices at which L, when flipped and then transformed with
function TF return true for the predicate REQF.
\
.planlib.macrosfilter: {[tf;reqf;l]
  asXbs: tf flip l;
  where reqf asXbs}
        
/
After getting the nested indices of solutions, we must trace back from the FPIS
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
.planlib.mapFPIs: {[fpis;p;c;as;bs;field]
  ppis: p fpis;
  cpis: c ppis;
  .planlib.fieldcross[field;as;bs] cpis}

/
A table of general filters for when no optimisation step is being done
  and you simply want to find the results which pass for a constant
  set of macro requirements
\
.planlib.generalfilter: {[req] .planlib.macrosfilter[sum;>[;req]]}
.planlib.generalfilters: {[carbsreq;proteinreq;fatreq;foods]
  ([foods: foods]
    carbs:   3 # .planlib.generalfilter[carbsreq];
    protein: 3 # .planlib.generalfilter[proteinreq];
    fat:     3 # .planlib.generalfilter[fatreq])}

/
Returns the names of the 2 food (A and B) combinations that pass all
  of the filters specified in the dictionary FILTERFUNCTIONS.
\
.planlib.axb_viables: {[a;b;filterfunctions;field]
  axb_carbpassingindices:    filterfunctions[`carbs]   .planlib.fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: filterfunctions[`protein] .planlib.fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     filterfunctions[`fat]     .planlib.fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  .planlib.mapFPIs[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b;field]}

.planlib.tabulateviables: {[viables]
  ([]
    name: viables[`name];
    gtotalPserving: sum each viables[`gtotalPserving];
    calsPserving: sum each viables[`calsPserving];
    gcarbsPserving: sum each viables[`gcarbsPserving];
    gproteinPserving: sum each viables[`gproteinPserving];
    gfatPserving: sum each viables[`gfatPserving])}

.planlib.pricesols: {[ftcost;sols] {[ftcost;sol] exec sum pricePserving from ftcost where name in sol}[ftcost] each sols}
.planlib.shopsrequiredsols: {[ftspending;sols] {[ftspending;sol] exec distinct boughtfrom from ftspending where name in sol}[ftspending] each sols}

.planlib.annotatesummed: {(sum;x)}
.planlib.make_sum_aggregates: {x ! .planlib.annotatesummed each x}
.planlib.nutritionstats: {[ftnutrition;sols] {[ftnutrition;sol] ?[ftnutrition;enlist (in;`name;`sol);();.planlib.make_sum_aggregates 1_cols ftnutrition]}[ftnutrition] each sols}

.planlib.solutionstable: {[prices;ingredients;requiredshops;nutritionstats]
  ([]
    price:         prices;
    ingredients:   ingredients;
    requiredshops: requiredshops;
    gtotal:        nutritionstats `gtotalPserving;
    cals:          nutritionstats `calsPserving;
    gcarbs:        nutritionstats `gcarbsPserving;
    gprotein:      nutritionstats `gproteinPserving;
    gfat:          nutritionstats `gfatPserving)}
