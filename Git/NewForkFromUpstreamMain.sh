git remote show upstream

git checkout -b mynewbranch
git fetch upstream
git reset --hard upstream/main
git push --set-upstream origin mynewbranch
