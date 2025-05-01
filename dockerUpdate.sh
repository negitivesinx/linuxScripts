#/bin/zsh
docker images | grep -v REPOSITORY | awk '{print $1}' | xargs -L1 docker pull
docker image prune -af
