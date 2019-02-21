FROM serafinlabs/alpine:3.9
LABEL maintainer="Nicolas Degardin <degardin.n@gmail.com>"

RUN adduser -D -s /bin/false -u 1000 node
RUN mkdir -p /home/node/.npm && chown node -R /home/node/.npm && chown node /srv

ENV NPM_CONFIG_PREFIX="/home/node/.npm"
RUN apk --update --no-cache add nodejs nodejs-npm git make musl musl-utils openssh-client jq libcap yarn fontconfig ghostscript-fonts
RUN npm i -g npm
RUN setcap cap_net_bind_service=+ep /usr/bin/node
RUN curl -Ls "https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz" | tar xz -C /

USER node
ENV PATH="/home/node/.npm/bin:$PATH"

RUN mkdir -p $HOME/.ssh && ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

EXPOSE 80

WORKDIR /srv
CMD ["npm", "start"]
