BRANCHNAME=""

git fetch origin
git checkout -b $BRANCHNAME origin/$BRANCHNAME
git merge main
