.planlib.foodtypes: `breakfast`lunch`dinner

.planlib.spending: {[ft;mealfoodtypes]
  ftidx: first where .planlib.foodtypes=ft;
  select from spending where foodtype in mealfoodtypes, {y x}[ftidx] each inmeals};

.planlib.categorisenutrition: {[ftspending;ftnutrition;ft]
  groupedbyfoodtype: `foodtype xgroup ftspending;
  categorisednames: select name from groupedbyfoodtype where foodtype=ft;
  lj[ungroup categorisednames; ftnutrition]}
