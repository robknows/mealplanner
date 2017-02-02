#!/usr/bin/ijconsole

boxedfn =: 2{ARGV
readfile =: 1!:1
writefile =: 1!:2

rawtxt =: readfile boxedfn
lines =: (] ;. _2) rawtxt

taketofirst =: i. {. [
headcol =: i.&(9{a.) {. ]
tailcols =: >:@:i.&(9{a.) }. ]

NB. x=A string with columns seperated by tabs
NB. y=number of the column you want
col =: 4 : '(taketofirst&'' '') headcol tailcols^:y x'

NB. x=A stringified table whose columns are seperated by tabs on each row
NB. y=number of the column you want
tablecol =: 4 : '(col&y)"1 x'

NB. 
NB. 00 01 02 03 04 05
NB. 10 11 12 13 14 15
NB. 20 21 22 23 24 25
NB. ...
NB.
ncols =: 6
nrows =: #lines
dimensions =: nrows , ncols
indices =: ;/"2 ((dimensions$ncols#i.nrows) ;"1@:;"0 (dimensions$i.ncols))

substitute =: (0&{) ({ lines&tablecol) (1&{)
substituted =: substitute L:0 indices
spacecolumns =: ;"1 ((,&'  ') L:0 substituted)
emphasisecolnames =: (toupper (0 { spacecolumns)) (0}) spacecolumns
makewriteable =: , (,&LF)"1 emphasisecolnames
formatted =: makewriteable

formatted writefile boxedfn

exit''
