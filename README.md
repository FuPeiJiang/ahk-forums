make sure to have the folder `lib` in your working dir, or you can have it here https://www.autohotkey.com/docs/Functions.htm#lib

`d(arr)` will put arr in your clipboard as a newline seperated string<br>
```autohotkey
arr:=["foo","bar","foobar", 653]
d(arr)
```
your clipboard will become
```autohotkey
foo
bar
foobar
653
```