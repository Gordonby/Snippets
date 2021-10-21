ref:https://github.com/containers/buildah/blob/main/install.md#ubuntu

Working script for building and pushing to dockerhub.
```bash
. /etc/os-release
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${ID^}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${ID^}_${VERSION_ID}/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt-get update -qq
sudo apt-get -qq -y install buildah

sudo buildah bud --format=docker -f Dockerfile -t gordonbmsft/openjdk-demo:0.0.1 .

sudo buildah images

#sudo buildah login registry.hub.docker.com
sudo buildah login registry-1.docker.io

sudo buildah push gordonbmsft/openjdk-demo:0.0.1
```
