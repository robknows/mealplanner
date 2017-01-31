#!/home/rob/q/l32/q

spending: value`:../tables/spending
givenstats: value`:../tables/givenstats

names: exec name from givenstats
extendablespendstats: select from spending where name in names

gtotalPservings: (1 % (exec nServings from extendablespendstats)) * (exec nGrams from givenstats)
calsPservings: (exec calsP100g from givenstats) * 0.01 * gtotalPservings
gcarbsPservings: (exec gcarbsP100g from givenstats) * 0.01 * gtotalPservings
gproteinPservings: (exec gproteinP100g from givenstats) * 0.01 * gtotalPservings
gfatPservings: (exec gfatP100g from givenstats) * 0.01 * gtotalPservings

nutrition: ([name: names]
  gtotalPserving: gtotalPservings;
  calsPserving: calsPservings;
  gcarbsPserving: gcarbsPservings;
  gproteinPserving: gproteinPservings;
  gfatPserving: gfatPservings)

save `:../tables/nutrition

\\
