#!/bin/bash -e

docker-build(){
    local from_tag=${1}
    local to_tag=${2}
    echo "docker build --rm --force-rm -t lpiglowski-arista/my-bloody-jenkins:${to_tag} --build-arg=FROM_TAG=${from_tag} ."
    docker build --rm --pull --force-rm -t lpiglowski-arista/my-bloody-jenkins:${to_tag} --build-arg=FROM_TAG=${from_tag} .
    docker tag lpiglowski-arista/my-bloody-jenkins:${to_tag} lpiglowski-arista/my-bloody-jenkins:${to_tag}
    echo "docker push lpiglowski-arista/my-bloody-jenkins:${to_tag}"
    docker push ghcr.io/lpiglowski-arista/my-bloody-jenkins:${to_tag}
}

lts_version=$(cat LTS_VERSION.txt)
version_type=$1
case $version_type in
latest)
    docker-build ${lts_version}-jdk21 jdk21
    ;;
v*)
    tag=$(echo $version_type | sed 's/v//g')
    short_tag=$(echo $tag | cut -d '-' -f 1)

    docker-build ${lts_version}-alpine $tag
    docker-build ${lts_version}-alpine $short_tag
    docker-build ${lts_version}-alpine lts
    docker-build ${lts_version}-alpine lts-alpine

    docker-build ${lts_version} ${tag}-debian
    docker-build ${lts_version} ${short_tag}-debian
    docker-build ${lts_version} lts-debian

    docker-build ${lts_version}-jdk21 ${tag}-jdk11
    docker-build ${lts_version}-jdk21 ${short_tag}-jdk21
    docker-build ${lts_version}-jdk21 lts-jdk21
    ;;
*)
    tag=$version_type
    docker-build ${lts_version}-alpine $tag
    docker-build ${lts_version}-alpine $tag-alpine
    docker-build ${lts_version} $tag-debian
    docker-build ${lts_version}-jdk21 $tag-jdk21
    ;;
esac
#docker-build $1 $2
