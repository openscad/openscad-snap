FROM snapcore/snapcraft

ARG SUFFIX=
ARG BRANCH=master
ARG OPENSCAD_VERSION=

WORKDIR /openscad
RUN \
	apt-get update && \
	apt-get -y upgrade && \
	cat /etc/os-release

RUN \
	GIT_TRACE=1 GIT_CURL_VERBOSE=1 git clone --depth 50 https://github.com/openscad/openscad . && \
	git checkout "${BRANCH}" && \
	git rev-parse --abbrev-ref HEAD && \
	git log -n8 --pretty=tformat:"%h %ai (%aN) %s"

RUN \
	snapcraft
