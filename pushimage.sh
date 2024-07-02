#!/bin/bash    
set -e
# DOCKER_MIRROR_REP=<yourrep>/<namespace>/<imagename>

IFS='/' read -r -a array <<< "$1"
LEN=${#array[@]}
if [[ LEN -eq 1 ]]; then
NAMESPACE=library
IMAGE=${array[0]}
elif [[ LEN -eq 2 ]]; then
NAMESPACE=${array[0]}
IMAGE=${array[1]}
elif [[ LEN -eq 3 ]]; then
REGISTRY=${array[0]}
NAMESPACE=${array[1]}
IMAGE=${array[2]}
else
echo "wrong image name"
exit 1
fi

IFS=':' read -r -a array1 <<< "$IMAGE"
LEN1=${#array1[@]}
if [[ LEN1 -eq 1 ]]; then
TAG=latest
IMAGENAME=${array1[0]}
elif [[ LEN1 -eq 2 ]]; then
TAG=${array1[1]}
IMAGENAME=${array1[0]}
else 
echo "wrong image name"
exit 1
fi

echo pull $1
docker pull $1
echo tag $1 $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
docker tag $1 $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
echo push $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
docker push $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}

# echo pull $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
# {
# docker pull $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
# } ||
# {
# if [ -z "${DOCKER_TRANSPORT_SERVER_HOST}" ]; then
#     ssh -o StrictHostKeyChecking=no pushimage $1
#     docker pull $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG}
# else 
#     echo "$1 not exist"
#     exit 1
# fi
# }
# echo tag $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG} $1
# docker tag $DOCKER_MIRROR_REP:${NAMESPACE}_${IMAGENAME}_${TAG} $1
