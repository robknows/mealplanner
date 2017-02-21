#!/home/rob/q/l32/q

\l planbreakfast.q
\l planlunch.q
\l plandinner.q

input: first "S"$.z.x

meals:`breakfast`lunch`dinner
if[not input in meals;1 "\nInput must be one of breakfast lunch dinner.\n";exit 1]

plan: first (.breakfast.plan ; .lunch.plan ; .dinner.plan) where input=meals

/
We can introduce a stochastic element here later using a random seed
  as an argument to the planningmethod functions.
\
solutions: `price xasc plan[]
n: min (100;count solutions)
solutions: n#solutions

/
Fix up the columns with symbols so that they are presentable strings
  (Q is not happy to save symbol lists to a .txt file)
\
presentsymbols: {sv[","] string x}
update ingredients: presentsymbols each ingredients,requiredshops: presentsymbols each requiredshops from `solutions;

save `:solutions.txt
lastsolutions: solutions
save `:../tables/lastsolutions

exit 0
