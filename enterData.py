#!/usr/bin/python3
fields = ["name", "shop", "price", "nServings", "servingDesc", "inmeals", "foodtype", "nGrams", "cals", "carbs", "protein", "fat"]
data = ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"]

print("b = step back, f = step forward, s = submit now\n")

nFields = len(fields)
i = 0

while (i < nFields):
  prompt = ("Enter " +  fields[i] + ", whose current value is " + data[i] + "\n")
  s = input(prompt)
  if (s == "b"):
    i -= 1
  elif (s == "f"):
    i += 1
  elif (s == "s"):
    i = nFields
  else:
    data[i] = s
    i += 1

spending = "`spending insert (name:`"+ data[0] +";boughtfrom:`"+ data[1] +";price:"+ data[2] +"f;nServings:"+ data[3] +";servingDescription:\""+ data[4] +"\";inmeals:"+ data[5] +"b;foodtype:`"+ data[6] +")"
givenstats = "`givenstats insert (name:`"+ data[0] +";nGrams:"+ data[7] +";calsP100g:"+ data[8] +";carbsP100g:"+ data[9] +"f;proteinP100g:"+ data[10] +"f;fatP100g:"+ data[11] +"f)"

f = open("insertFoods.q", "w")
print("#!/home/rob/q/l32/q", file=f)
print("spending: value`:tables/spending", file=f)
print("givenstats: value`:tables/givenstats", file=f)
print(spending, file=f)
print("save `:tables/spending", file=f)
print(givenstats, file=f)
print("save `:tables/givenstats", file=f)
print("exit 0", file=f)
f.close()
exit(0)
