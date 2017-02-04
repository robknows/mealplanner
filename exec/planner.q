#!/home/rob/q/l32/q

spending: value`:../tables/spending
nutrition: value`:../tables/nutrition
cost: value`:../tables/cost

input: first "S"$.z.x

meals:`breakfast`lunch`dinner
if[not input in meals;1 "\nInput must be one of breakfast lunch dinner.\n";exit 1]

reqs: ([meal:meals] 
  i: 0 1 2;
  carbsreq: 70 80 50; 
  proteinreq: 10 40 50; 
  fatreq: 10 50 70)

carbsreq: (reqs input)[`carbsreq]
proteinreq: (reqs input)[`proteinreq]
fatreq: (reqs input)[`fatreq]
index: (reqs input)[`i]
mealfilter: {x index}

mealappropriatefoods: exec name from spending where mealfilter each inmeals
nutrition: 0!(select from nutrition where name in mealappropriatefoods)

maxcarbs: max exec gcarbsPserving from nutrition
maxprotein: max exec gproteinPserving from nutrition
maxfat: max exec gfatPserving from nutrition

filter: {y where x each y}

checkcarbs: {<[x;sum (nutrition y)[`gcarbsPserving]]}
checkprotein: {<[x;sum (nutrition y)[`gproteinPserving]]}
checkfat: {<[x;sum (nutrition y)[`gfatPserving]]}

applyallfilters2i: {
  filter[checkfat[fatreq - maxfat]] 
  filter[checkprotein[proteinreq - maxprotein]] 
  filter[checkcarbs[carbsreq - maxcarbs]] x}

applyallfilters3i: {
  filter[checkfat[fatreq]]
  filter[checkprotein[proteinreq]]
  filter[checkcarbs[carbsreq]] x}

/
a=all
i=ingredient
p=potentially
v=valid
o=optimised
\
a2i: {x cross x} til count nutrition
pv2i: applyallfilters2i a2i
opv3i: pv2i cross (til count nutrition)
v3i: applyallfilters3i opv3i
solutions: distinct asc each v3i

sumquantity: {sum (nutrition y)[x]}
solingredients: {exec name from (nutrition x)}
solgtotal: sumquantity[`gtotalPserving]
solcals: sumquantity[`calsPserving]
solcarbs: sumquantity[`gcarbsPserving]
solprotein: sumquantity[`gproteinPserving]
solfat: sumquantity[`gfatPserving]

fromsolutions: {x each solutions}
ingredientsols: fromsolutions solingredients

mealprice: {exec sum pricePserving from (cost each x)}
mealprices: mealprice each ingredientsols

presentsymbols: {sv[","] string x}
ingredients: presentsymbols each ingredientsols

solutionstable: asc ([] 
  price: mealprices;
  ingredients: ingredients;
  gtotal: fromsolutions solgtotal; 
  cals: fromsolutions solcals; 
  carbs: fromsolutions solcarbs; 
  protein: fromsolutions solprotein; 
  fat: fromsolutions solfat)

save `:solutionstable.txt
lastsolutions: solutionstable
save `:../tables/lastsolutions

exit 0
