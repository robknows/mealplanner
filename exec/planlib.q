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
  `breads                                               = table name
  enlist ({0 < count ss[;"bread"] string x} each;`name) = selection condition ie. only the ones which have 'bread' in their name
  0b                                                    = ???
  make3x_aggregates 1_cols breads                       = dictionary for the tripling of the numeric columns. (1_ is to leave out 'name')
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
Ensure the first argument to tabulate_multifoods is always a single table.
\
.planlib.combine_fields: {[field;a;b] sum each .planlib.fieldcross[field;a;b]}
.planlib.tabulate_multifoods: {[a;b]
  if[2 = count b; b:.planlib.tabulate_multifoods[b 0;b 1]];
  ([] name: .planlib.fieldcross[`name;a;b];
    gtotalPserving:   .planlib.combine_fields[`gtotalPserving;a;b];
    calsPserving:     .planlib.combine_fields[`calsPserving;a;b];
    gcarbsPserving:   .planlib.combine_fields[`gcarbsPserving;a;b];
    gproteinPserving: .planlib.combine_fields[`gproteinPserving;a;b];
    gfatPserving:     .planlib.combine_fields[`gfatPserving;a;b])}

/
Returns the indices at which the sum of the items in MACROSLIST 
  is greater than THRESHHOLD.
\
.planlib.macrosidxfilter: {[threshhold;macroslist] where threshhold < sum each macroslist}

/
Takes a list of lists of food types (fts)
Produces a table of filter functions for the given (macro)nutrients
\

.planlib.macromax: {[nutrient;ft] max ft[nutrient]}
.planlib.makefilter: {[nutrient;req;fts]
  macromaxfts: sum .planlib.macromax[nutrient] each fts;
  .planlib.macrosidxfilter[req - macromaxfts]}

.planlib.makenutrientfilter: {[n;req;fts] .planlib.makefilter[n;req] fts}

.planlib.filters: {[fts;reqs]
  ([name: fts]
    carbs:   .planlib.makenutrientfilter[`gcarbsPserving;  reqs 0] each fts;
    protein: .planlib.makenutrientfilter[`gproteinPserving;reqs 1] each fts;
    fat:     .planlib.makenutrientfilter[`gfatPserving;    reqs 2] each fts)}

/
A table of general filters for when no optimisation step is being done
  and you simply want to find the results which pass for a constant
  set of macro requirements
\
.planlib.generalfilters: {[carbsreq;proteinreq;fatreq;foods]
  n: count foods;
  ([foods: foods]
    carbs:   n # .planlib.macrosidxfilter[carbsreq];
    protein: n # .planlib.macrosidxfilter[proteinreq];
    fat:     n # .planlib.macrosidxfilter[fatreq])}

/
After getting the nested indices of solutions, we must trace back from the FPIS
  (fatpassingindices) to the names of their corresponding food combination
  of an element of AS and an element of BS.

CPIS are the carb passing indices
PPIS are the protein passing indices

To do this it goes from FPIS back into the ppis, selecting only those
  which passes the fat test, then from ppis back into cpis, again,
  selecting only those which have passed the first two tests, and then
  finally it turns these indices into a cross of whatever field you
  choose.          
\
.planlib.mapFPIs: {[fpis;ppis;cpis;fttable;field]
  idxs: cpis (ppis fpis);
  fttable[field] idxs}

/
Returns the names of the 2 food (A and B) combinations that pass all
  of the filters specified in the dictionary FILTERFUNCTIONS.
\
.planlib.viables: {[fttable;filterfunctions;field]
  cpis: filterfunctions[`carbs]   fttable[`gcarbsPserving];
  ppis: filterfunctions[`protein] fttable[`gproteinPserving] cpis;
  fpis: filterfunctions[`fat]     fttable[`gfatPserving] (cpis ppis);
  fttable[field] (cpis ppis fpis)}

.planlib.tabulateviables: {[viables]
  ([]
    name: viables[`name];
    gtotalPserving: sum each viables[`gtotalPserving];
    calsPserving: sum each viables[`calsPserving];
    gcarbsPserving: sum each viables[`gcarbsPserving];
    gproteinPserving: sum each viables[`gproteinPserving];
    gfatPserving: sum each viables[`gfatPserving])}

.planlib.concatmap: {[f;l] over[,;f each l]}

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

.planlib.solution: {[ftspending;ftnutrition;ftcost;solutions]
  price:          .planlib.pricesols[ftcost;solutions];
  ingredients:    solutions;
  requiredshops:  .planlib.shopsrequiredsols[ftspending;solutions];
  nutritionstats: .planlib.nutritionstats[ftnutrition;solutions];
  .planlib.solutionstable[price;ingredients;requiredshops;nutritionstats]}
