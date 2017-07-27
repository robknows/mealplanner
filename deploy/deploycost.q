#!/home/ubuntu/q/l32/q

spending: value`:../tables/spending
givenstats: value`:../tables/givenstats
nutrition: value`:../tables/nutrition

\l sattr.q

names: exec name from spending
namesB: exec name from givenstats
namesC: exec name from nutrition

if[not {&[x = y;y = z]}[count names;count namesB;count namesC]; 1 "spending, givenstats and nutrition keys doesn't match up. Fix before deploying cost."; exit 1]

pricePserving: exec price%nServings from spending
gramsPpound: (exec nGrams from givenstats) % (exec price from spending)
caloriesPpound: (exec reciprocal price from spending) * 0.01 * exec calsP100g * nGrams from givenstats
proteinPpound: (exec reciprocal price from spending) * 0.01 * exec gproteinP100g * nGrams from givenstats

cost: ([name:names]
  pricePserving;
  gramsPpound;
  caloriesPpound;
  proteinPpound)

sattr `cost;

save `:../tables/cost

\\
