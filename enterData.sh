#!/bin/bash

cd dataEntry/
./enterData.py
mv insertFoods.q ../insertFoods.q
cd ..
cat insertFoods.q
while true; do
  read -p "Do you want to continue? (s = show generated q file again, y = yes, n = no)." yn
    case $yn in
      [Yy]* ) chmod +x insertFoods.q; ./insertFoods.q; ./unifyTables.sh; break;;
      [Nn]* ) break;;
      [Ss]* ) cat insertFoods.q;;
      * ) echo "Answer y, n or s";;
  esac
done
rm -f insertFoods.q
exit 0
