#!/bin/bash

cd exec
./planner.q $1
./presentsolutions.ijs solutions.txt
cat solutions.txt
rm solutions.txt
cd ..

exit 0
