#!/bin/sh -e
#
#

IMAGE_NAME=forj-oss-jenkins

if [ "$LOGNAME" = jenkins ]
then
   REPO=forj-oss
   IMAGE_VERSION=
else
   REPO=$LOGNAME
   IMAGE_VERSION=test
fi

if [ -f build_opts.sh ]
then
   source build_opts.sh
fi

TAG_NAME=hub.docker.com/$REPO/$IMAGE_NAME:$IMAGE_VERSION

if [ "$http_proxy" != "" ]
then
   PROXY=" --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy=$no_proxy"
   echo "Using your local proxy setting : $http_proxy"
   if [ "$no_proxy" != "" ]
   then
      PROXY="$PROXY --build-arg no_proxy=$no_proxy"
      echo "no_proxy : $no_proxy"
   fi
fi

if [ -z "$MYFORK" ]
then
   MYFORK="forj-oss/jenkins-install-inits"
   echo "Using default Organisation/repo ($MYFORK) for jenkins-install-inits. Add MYFORK= to change it."
fi

if [ -z "$BRANCH" ]
then
   BRANCH=master
   echo "Using current git branch 'master'. Add BRANCH= to change it."
fi

JENKINS_INSTALL_INITS_URL="https://github.com/$MYFORK"
FEATURES="--build-arg JENKINS_INSTALL_INITS_URL=$JENKINS_INSTALL_INITS_URL"

# Added DOOD docker group
BUILD_OPTS="$BUILD_OPTS --build-arg DOOD_DOCKER_GROUP=$(stat /var/run/docker.sock -c %g)"

IMAGE_BASE=forjdevops/jenkins

set -x
sudo -n docker pull $IMAGE_BASE
sudo -n docker run -di --name jplugins $RUN_PROXY -v $DEPLOY/jenkins:/src -w /src -u $(id -u) $IMAGE_BASE /bin/cat
sudo -n docker exec jplugins git clone https://github.com/forj-oss/jenkins-install-inits /tmp/jenkins-install-inits
sudo -n docker exec jplugins /usr/local/bin/jplugins init --feature-file features.lst --features-repo-path /tmp/jenkins-install-inits
sudo -n docker rm -f jplugins
sudo -n docker build -t $TAG_NAME $FEATURES $PROXY $BUILD_OPTS .
set +x


if [ "$AUTO_PUSH" = true ]
then
   set -x
   sudo -n docker push $TAG_NAME
fi
