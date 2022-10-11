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

eg. 

![image](https://user-images.githubusercontent.com/17914476/195082353-ed708c03-6966-45a4-ae03-b46470a35a75.png)
