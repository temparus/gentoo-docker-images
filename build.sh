#!/bin/bash

# Used to create Gentoo stage3 and portage containers simply by specifying a 
# TARGET env variable.
# Example usage: TARGET=stage3-amd64 ./build.sh

if [[ -z "$TARGET" ]]; then
	echo "TARGET environment variable must be set e.g. TARGET=stage3-amd64."
	exit 1
fi

# Split the TARGET variable into three elements separated by hyphens
IFS=- read -r NAME ARCH SUFFIX <<< "${TARGET}"

# Ensure upstream directories for stage3-amd64-hardened+nomultilib work
SUFFIX=${SUFFIX/-/+}

VERSION=${VERSION:-$(date -u +%Y%m%d)}

ORG=${ORG:-gentoo}

# x86 requires the i686 subfolder
if [[ "${ARCH}" == "x86" ]]; then
	MICROARCH="i686"
	BOOTSTRAP="multiarch/alpine:x86-v3.7"
elif [[ "${ARCH}" == "arm64" ]]; then
	MICROARCH="${ARCH}"
	NAME="${NAME}-arm64"
elif [[ "${ARCH}" == "arm" ]]; then
	MICROARCH="armv7a"
else
	MICROARCH="${ARCH}"
fi

# Prefix the suffix with a hyphen to make sure the URL works
if [[ -n "${SUFFIX}" ]]; then
	SUFFIX="-${SUFFIX}"
fi

docker build --build-arg ARCH="${ARCH}" --build-arg MICROARCH="${MICROARCH}" --build-arg BOOTSTRAP="${BOOTSTRAP}" --build-arg SUFFIX="${SUFFIX}"  -t "${ORG}/gentoo-${TARGET}:${VERSION}" -f "${NAME}.Dockerfile" .
docker tag "${ORG}/gentoo-${TARGET}:${VERSION}" "${ORG}/${TARGET}:latest"
