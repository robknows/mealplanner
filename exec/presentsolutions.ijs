#!/usr/ijconsole

boxedfn =: 2{ARGV
readfile =: 1!:1
writefile =: 1!:2

rawtxt =: readfile boxedfn
lines =: (] ;. _2) rawtxt
headers =: 0{lines
data =: 1}.lines

exit''
