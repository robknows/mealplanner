#!/home/ubuntu/q/l32/q

spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

\l planlib.q
\l planbreakfast.q
\l planlunch.q
\l plandinner.q

carbs_check:   {[table;req] 0 = count select from table where gcarbs   < req}
protein_check: {[table;req] 0 = count select from table where gprotein < req}
fat_check:     {[table;req] 0 = count select from table where gfat     < req}

make_test: {[result;reqs]
  carbs:   carbs_check  [result;reqs 0];
  protein: protein_check[result;reqs 1];
  fat:     fat_check    [result;reqs 2];
  `c`p`f!(carbs;protein;fat)}

breakfast_test: make_test[.breakfast.plan[];(.breakfast.carbsreq;.breakfast.proteinreq;.breakfast.fatreq)]
lunch_test:     make_test[.lunch.plan[];(.lunch.carbsreq;.lunch.proteinreq;.lunch.fatreq)]
dinner_test:    make_test[.dinner.plan[];(.dinner.carbsreq;.dinner.proteinreq;.dinner.fatreq)]

all_tests: ([]
  b: breakfast_test;
  l: lunch_test;
  d: dinner_test)

show all_tests

exit 0
