#!/usr/bin/env bash

yum install -y wget iproute

eval "$(curl -sL https://raw.githubusercontent.com/travis-ci/gimme/master/gimme | GIMME_GO_VERSION=1.7 bash)"

pwd
ip addr
export GOPATH=/gopath
mkdir -p ${GOPATH}/src/github.com/rekby/lets-proxy
cp -R ./ ${GOPATH}/src/github.com/rekby/lets-proxy/

go build -o http-ok gitlab/http-ok.go
./http-ok &

echo "Test http-ok: "
curl http://localhost
echo

DOMAIN="gitlab-test.1gb.ru"

TMP_SUBDOMAIN="tmp-`date +%Y-%m-%d--%H-%M-%S--%N--$RANDOM$RANDOM`.ya"
TMP_DOMAIN="$TMP_SUBDOMAIN.$DOMAIN"

echo "Tmp domain: $TMP_DOMAIN"

wget https://github.com/rekby/ypdd/releases/download/v0.2/ypdd-linux-amd64.tar.gz
tar -zxvf ypdd-linux-amd64.tar.gz

MY_IPv6=`curl -6 ifconfig.io/ip`
echo MY IPv6: ${MY_IPv6}
./ypdd --sync ${DOMAIN} add ${TMP_SUBDOMAIN} AAAA ${MY_IPv6}

go build github.com/rekby/lets-proxy -o proxy

./proxy &

TEST=`curl http://${TMP_DOMAIN}`
test "$TEST" == "OK"
