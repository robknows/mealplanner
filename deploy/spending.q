names: (`tomatoes`bread`sandwich)
boughtfroms: (`tesco`sainsburys`waitrose)
prices: 1.5 1 2
nServingses: 5 20 1
servingDescriptions: ("1 tomato";"1 slice";"both halves")
inmealses:(011b;110b;010b)

spending: ([name: names] 
  boughtfrom: boughtfroms;
  price: prices;
  nServings: nServingses;
  servingDescription: servingDescriptions;
  inmeals: inmealses)

save `:../tables/spending
