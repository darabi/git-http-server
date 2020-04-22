## -*- docker-image-name: "mcreations/git-http-server" -*-

FROM debian:stable
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV DEBIAN_FRONTEND noninteractive

# if empty, a new key is generated (which might be of little use)
ENV GIT_SSH_PRIVATE_KEY ""
ENV GIT_SSH_PRIVATE_KEY_PASS ""

# prepended to the name of the git repo which is being pulled e.g. 'myproject.git'
ENV GIT_REMOTE_REPO_PREFIX git@github.com:example/

ENV GIT_PROJECT_ROOT /var/www/repo

ENV USER_NAME www-data

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install git-core nginx fcgiwrap libnginx-mod-http-lua procps net-tools -y

ADD image/root /

RUN usermod --uid 10001 www-data &&\
    sed -i -e 's/^user www-data.*//g' /etc/nginx/nginx.conf &&\
    chgrp www-data /run &&\
    chmod g+w /run &&\
    chown www-data /var/lib/nginx &&\
    mkdir -p $GIT_PROJECT_ROOT && \
    mkdir /var/www/.ssh && \
    chown www-data /var/www/.ssh && \
    chmod 0700 /var/www/.ssh && \
    chown www-data $GIT_PROJECT_ROOT &&\
    chgrp -R 0 $GIT_PROJECT_ROOT && \
    rm /var/log/nginx/* &&\
    ln -s /dev/stdout /var/log/nginx/access.log &&\
    ln -s /dev/stderr /var/log/nginx/error.log &&\
    printf " \
    env GIT_REMOTE_REPO_PREFIX; \
    env GIT_PROJECT_ROOT; \
    env GIT_SSH_PRIVATE_KEY; \
    env GIT_SSH_PRIVATE_KEY_PASS;\n" \
      >> /etc/nginx/modules-enabled/my-env-vars.conf && \
    update-rc.d fcgiwrap enable

USER 10001

ENTRYPOINT [ "/start" ]
