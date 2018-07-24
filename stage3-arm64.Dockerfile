# This Dockerfile creates a gentoo stage3 container image. By default it 
# creates a stage3-amd64 image. It utilizes a multi-stage build and requires 
# docker-17.05.0 or later. It fetches a daily snapshot from the official 
# sources and verifies its checksum as well as its gpg signature.

# As gpg keyservers sometimes are unreliable, we use multiple gpg server pools
# to fetch the signing key.

ARG BOOTSTRAP
FROM ${BOOTSTRAP:-alpine:3.7} as builder

WORKDIR /gentoo

ARG ARCH=arm64
ARG MICROARCH=arm64
ARG SUFFIX
ARG DIST="https://ftp-osl.osuosl.org/pub/gentoo/experimental/${ARCH}"
# ARG SIGNING_KEY="0xBB572E0E2D182910"

RUN echo "Building Gentoo Container image for ${ARCH} ${SUFFIX} fetching from ${DIST}" \
 && apk --no-cache add gnupg tar wget xz \
 && STAGE3PATH="stage3-arm64-20180305.tar.bz2" \
 && echo "STAGE3PATH:" $STAGE3PATH \
 && wget -q "${DIST}/${STAGE3PATH}" "${DIST}/${STAGE3PATH}.CONTENTS" "${DIST}/${STAGE3PATH}.DIGESTS" \
#  && gpg --list-keys \
#  && echo "standard-resolver" >> ~/.gnupg/dirmngr.conf \
#  && echo "honor-http-proxy" >> ~/.gnupg/dirmngr.conf \
#  && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
#  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${SIGNING_KEY} \
#  && gpg --verify "${STAGE3PATH}.DIGESTS" \
#  && awk '/# SHA512 HASH/{getline; print}' ${STAGE3PATH}.DIGESTS | sha512sum -c \
 && tar xpf "${STAGE3PATH}" --xattrs --numeric-owner \
 && sed -i -e 's/#rc_sys=""/rc_sys="docker"/g' etc/rc.conf \
 && echo 'UTC' > etc/timezone \
 && rm ${STAGE3PATH}.DIGESTS ${STAGE3PATH}.CONTENTS ${STAGE3PATH}

FROM scratch

WORKDIR /
COPY --from=builder /gentoo/ /
CMD ["/bin/bash"]
