#!/home/rob/q/l32/q

input: first "S"$.z.x

meals:`breakfast`lunch`dinner
if[not input in meals;1 "\nInput must be one of breakfast lunch dinner.\n";exit 1]

breakfast: {
  \l planbreakfast.q
  planbreakfast}

lunch: {
  \l planlunch.q
  planlunch}

dinner: {
  \l plandinner.q
  plandinner}

plan: first (breakfast ; lunch ; dinner) where input=meals

\
We can introduce a stochastic element here later using a random seed
  as an argument to the planningmethod functions.
/
solutionstable: plan[]

save `:solutionstable.txt
lastsolutions: solutionstable
save `:../tables/lastsolutions

exit 0
