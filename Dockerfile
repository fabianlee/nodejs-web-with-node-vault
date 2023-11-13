# https://hub.docker.com/_/node/
# avoiding 21.1.0-bookwork-slim because it makes 'npm install' throw this error
# node[7]: ../src/node_platform.cc:68:std::unique_ptr<long unsigned int> node::WorkerThreadsTaskRunner::DelayedTaskScheduler::Start(): Assertion `(0) == (uv_thread_create(t.get(), start_thread, this))' failed.
FROM node:21.1.0-bullseye-slim

# non-root user name and id
ARG NAME=nodejs
ARG THE_USER_ID=1001
ARG THE_GROUP_ID=1001
# yaml parser, https://github.com/mikefarah/yq
ARG YQ_VERSION=v4.2.0
ARG YQ_BINARY=yq_linux_amd64

# create non-root user and group
# -l and static IDs assigned to avoid delay in lookups and system logging
# modification of 'docker-clean' needed to avoid post-install apt error trying to clean files
RUN DEBIAN_FRONTEND=noninteractive && \
  ls -l /etc/apt/apt.conf.d && \
  sed -i -e 's/^APT/#APT/' -e 's/^DPkg/#DPkg/' /etc/apt/apt.conf.d/docker-clean && \
  cat /etc/apt/apt.conf.d/docker-clean && \
  apt update && \
  apt install -q -y -o Dpkg::Options::="--force-confnew" curl wget jq && \
  /usr/sbin/groupadd -g $THE_GROUP_ID $NAME && \
  /usr/sbin/useradd -l -u $THE_USER_ID -G $NAME -g $THE_GROUP_ID $NAME && \
  wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq && \
  chmod +x /usr/bin/yq && \
  mkdir logs && chgrp $NAME logs && chmod ug+rwx logs

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY index.js ./

# run as non-root
#USER $NAME:$NAME

EXPOSE 4000

# this handles Ctrl-C properly, and looks at "start" script in package.json
CMD [ "npm", "start" ]
# this does not capture Ctrl-C events
#CMD [ "node", "index.js" ]
