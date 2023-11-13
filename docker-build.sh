owner=fabianlee
app=$(basename $PWD)
version=latest

set -x
docker build -t $owner/$app:$version -f Dockerfile .
buildCode=$?
set +x
[ $buildCode -eq 0 ] || exit $buildCode

#docker run --name test1 -it --rm --security-opt seccomp=unconfined -e JAVA_OPTS="-Xms128M -Xmx256M" $owner/$app:$version -- /bin/bash
docker images | head -n3

docker tag $owner/$app:$version docker.io/$owner/$app:$version
docker push docker.io/$owner/$app:$version

#echo to exec inside: docker exec -it test1 /bin/bash 
#set -x
#docker run --name test1 -it --rm --network=host --security-opt seccomp=unconfined $owner/$app:$version
#set +x
