.planlib.foodtypes: `breakfast`lunch`dinner

.planlib.spending: {[ft;mealfoodtypes]
  ftidx: first where .planlib.foodtypes=ft;
  select from spending where foodtype in mealfoodtypes, {y x}[ftidx] each inmeals};

.planlib.categorisenutrition: {[ftspending;ftnutrition;ft]
  groupedbyfoodtype: `foodtype xgroup ftspending;
  categorisednames: select name from groupedbyfoodtype where foodtype=ft;
  lj[ungroup categorisednames; ftnutrition]}

/
Returns the result of AS.FIELD cross BS.FIELD
\
.planlib.fieldcross: {[field;as;bs]
  as[field] cross bs[field]}
  
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
Returns the names of the 2 food (A and B) combinations that pass all
  of the filters specified in the dictionary FILTERFUNCTIONS.
\
.planlib.axb_viables: {[a;b;filterfunctions;field]
  axb_carbpassingindices:    filterfunctions[`carbs]   .planlib.fieldcross[`gcarbsPserving;  a;b];
  axb_proteinpassingindices: filterfunctions[`protein] .planlib.fieldcross[`gproteinPserving;a;b] axb_carbpassingindices;
  axb_fatpassingindices:     filterfunctions[`fat]     .planlib.fieldcross[`gfatPserving;    a;b] axb_proteinpassingindices;
  .planlib.mapFPIs[axb_fatpassingindices;axb_proteinpassingindices;axb_carbpassingindices;a;b;field]}

.planlib.pricesols: {[ftcost;sols] {[ftcost;sol] exec sum pricePserving from ftcost where name in sol}[ftcost] each sols}
