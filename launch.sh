#!/bin/bash

set -x

cd /data

if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 9
fi

# check for serverstarter jar
if ! [[ -f minecraft_server.1.16.5.jar ]]; then
	# download missing minecraft jar
	URL="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"

	if command -v wget &> /dev/null; then
		echo "DEBUG: (wget) Downloading ${URL}"
		wget -O minecraft_server.1.16.5.jar "${URL}"
	elif command -v curl &> /dev/null; then
		echo "DEBUG: (curl) Downloading ${URL}"
		curl -o minecraft_server.1.16.5.jar "${URL}"
	else
		echo "Neither wget or curl were found on your system. Please install one and try again"
		exit 1
	fi
fi
if ! [[ -f server-1.0.3.jar ]]; then
	rm -fr config defaultconfigs global_data_packs global_resource_packs kubejs libraries mods server-1.0.2.jar server.properties
	mv /server/* /data/
	rm -rf /server

fi

if [[ -n "$MOTD" ]]; then
    sed -i "/motd\s*=/ c motd=$MOTD" server.properties
fi
if [[ -n "$LEVEL" ]]; then
    sed -i "/level-name\s*=/ c level-name=$LEVEL" server.properties
fi
if [[ -n "$LEVELTYPE" ]]; then
    sed -i "/level-type\s*=/ c level-type=$LEVELTYPE" server.properties
fi

if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' >> ops.txt
fi

curl -o log4j2_112-116.xml https://launcher.mojang.com/v1/objects/02937d122c86ce73319ef9975b58896fc1b491d1/log4j2_112-116.xml


java $JAVA_FLAGS $JVM_OPTS -Dlog4j.configurationFile=log4j2_112-116.xml -jar server-1.0.3.jar