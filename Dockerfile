FROM marcelocorreia/base-alpine
MAINTAINER marcelo correia <marcelo@correia.io>

ARG packer_version="1.3.5"

RUN set -ex && \
    apk add --no-cache --update \
        curl \
        unzip \
        make \
        tzdata

RUN curl https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip \
    -o packer_${packer_version}_linux_amd64.zip
RUN unzip packer_${packer_version}_linux_amd64.zip -d /usr/local/bin

RUN set -ex && apk del curl unzip
#RUN rm /var/cache/apk/*
RUN rm packer_${packer_version}_linux_amd64.zip

RUN mkdir -p /app
WORKDIR /app

ENTRYPOINT ["packer"]
