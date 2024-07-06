FROM alpine/terragrunt:1.7.0

# RUN apk add git \
#     && touch /root/.netrc \
#     && echo machine github.dlsite.com >> /root/.netrc \
#     && echo login ${GITHUB_TOKEN} >> /root/.netrc \
#     && git config --global url."https://github.dlsite.com/".insteadOf ssh://github.dlsite.com/
