#! /bin/bash

PROJECT_NAME=dns-update-server
PROJECT_URL=http://www.github.com/edwinek/$PROJECT_NAME
SRC_ARCHIVE=$PROJECT_NAME-src.tar
WAR_FILE=$PROJECT_NAME.war

function cleanup_containers_and_files() {
    rm builder/$SRC_ARCHIVE
    rm deployer/$WAR_FILE
	docker rm dns_getter_container
	docker rm dns_builder_container
	docker rm dns_deployer_container
	docker rm dns_mongo_container
}

cleanup_containers_and_files

docker run --name dns_getter_container -tid edwinek/alpine-git:latest sh
docker exec -ti dns_getter_container git clone $PROJECT_URL /opt/src/$PROJECT_NAME
docker exec -ti dns_getter_container sh -c "cd /opt/src/$PROJECT_NAME && git archive -o /tmp/$SRC_ARCHIVE master"
docker cp dns_getter_container:/tmp/$SRC_ARCHIVE builder/$SRC_ARCHIVE
docker stop dns_getter_container

docker build -t dns_builder_image builder/.
docker run --name dns_builder_container -tid dns_builder_image sh
docker cp dns_builder_container:/opt/src/target/$WAR_FILE deployer/$WAR_FILE
docker stop dns_builder_container

docker build -t dns_deployer_image deployer/.
docker run --name dns_mongo_container -d mvertes/alpine-mongo
docker run --link dns_mongo_container:dnsupdateserver --name dns_deployer_container -ti -p 9999:8080 dns_deployer_image
docker stop dns_deployer_container
docker stop dns_mongo_container

cleanup_containers_and_files
