FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo curl mongodb \
 && opam init -y

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get install -y nodejs

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN wget http://d1h4xl4cr1h0mo.cloudfront.net/v1.10.1/x86_64-unknown-linux-gnu/parity_1.10.1_ubuntu_amd64.deb \
 && dpkg --install parity_1.10.1_ubuntu_amd64.deb \
 && (parity --chain dev &) \
 && sleep 10 \
 && killall parity

RUN wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.8.3-329ac18e.tar.gz && \
  tar xf geth-linux-amd64-*.tar.gz && \
  rm geth-linux-amd64-*.tar.gz && \
  cp geth-linux-amd64*/geth /bin/geth

RUN wget https://dist.ipfs.io/go-ipfs/v0.4.14/go-ipfs_v0.4.14_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.14_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init

RUN eval `opam config env` \
 && opam install cryptokit yojson -y \
 && git clone https://github.com/TrueBitFoundation/ocaml-offchain \
 && cd ocaml-offchain/interpreter \
 && git checkout asmjs \
 && make

RUN git clone https://github.com/mrsmkl/webasm-solidity \
 && cd webasm-solidity \
 && git checkout livepeer \
 && sh ./scripts/compile.sh \
 && npm install

RUN git clone https://github.com/mrsmkl/verification-truebit \
 && cd verification-truebit \
 && solc --abi --optimize --overwrite --bin -o compiled task.sol \
 && npm install

RUN cd webasm-solidity/node \
 && cp app.html /var/www/html/index.html \
 && cp socketio.js /var/www/html/ \
 && apt-get install -y tmux

EXPOSE 80 22448 4001

# docker build . -t truebit-livepeer-client:latest
# docker run -it -p 8080:80 -p 4001:4001 -p 22448:22448 truebit-livepeer-client:latest /bin/bash

# The run sh verification-truebit/dev.sh

