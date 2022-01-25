#Your GH username or org name
export GH_USERNAME=gordonby

#Create new GitHub PAT with scope to write to write:packages.
export CR_PAT=ghp_blahblah1221423423423423

#Login to GitHub Container Registry
echo $CR_PAT | docker login ghcr.io -u $GH_USERNAME --password-stdin

#Build and tag your container image
docker build -t ghcr.io/$GH_USERNAME/openjdk-demo:0.0.1 .

#Push the container iamge
docker push ghcr.io/$GH_USERNAME/openjdk-demo:0.0.1
