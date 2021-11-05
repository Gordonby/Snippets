
Simple version
```
git merge origin/main
```


Problematic one
```
BRANCHNAME=""

git fetch origin
git checkout -b $BRANCHNAME origin/$BRANCHNAME
git merge main
```
