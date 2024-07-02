FROM alpine/terragrunt:1.7.0

ENV ECSPRESSO_VER=2.2.4

RUN apk update --no-cache && \
        apk add --no-cache git curl binutils

# ecspresso のダウンロードとインストール
RUN curl -L https://github.com/kayac/ecspresso/releases/download/v${ECSPRESSO_VER}/ecspresso_${ECSPRESSO_VER}_linux_amd64.tar.gz -o ecspresso.tar.gz \
        && tar -zxvf ecspresso.tar.gz -C /usr/local/bin \
        && chmod +x /usr/local/bin/ecspresso \
        && rm ecspresso.tar.gz
