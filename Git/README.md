# Git commands i keep forgetting

## Push fails as would clobber existing tag

> would clobber existing tag

```bash
git fetch --tags -f
```
## Pushed to the wrong branch

Undo the last commit, then force update the remote with

```bash
git push origin +HEAD
```
