FROM ubuntu:17.10
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo curl mongodb \
 && opam init -y

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.4.20/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN wget http://d1h4xl4cr1h0mo.cloudfront.net/v1.9.5/x86_64-unknown-linux-gnu/parity_1.9.5_ubuntu_amd64.deb && \
   dpkg --install parity_1.9.5_ubuntu_amd64.deb && \
   (parity --chain dev &) && \
   sleep 10 && \
   killall parity

RUN wget https://dist.ipfs.io/go-ipfs/v0.4.11/go-ipfs_v0.4.11_linux-amd64.tar.gz && \
  tar xf go-ipfs_v0.4.11_linux-amd64.tar.gz && \
  cd go-ipfs && \
  ./install.sh && \
  ipfs init

RUN eval `opam config env` \
 && opam install cryptokit yojson -y \
 && git clone https://github.com/TrueBitFoundation/ocaml-offchain \
 && cd ocaml-offchain/interpreter \
 && make

RUN git clone https://github.com/juj/emsdk \
 && cd emsdk \
 && ./emsdk update-tags \
 && LLVM_CMAKE_ARGS="-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly" ./emsdk install sdk-tag-1.37.36-64bit \
 && ./emsdk activate sdk-tag-1.37.36-64bit \
 && ./emsdk install binaryen-master-64bit \
 && ./emsdk activate binaryen-master-64bit

RUN git clone https://github.com/TrueBitFoundation/emscripten-module-wrapper \
 && cd emscripten-module-wrapper \
 && source /emsdk/emsdk_env.sh \
 && npm install

RUN git clone https://github.com/TrueBitFoundation/webasm-solidity \
 && cd  webasm-solidity/node \
 && source /emsdk/emsdk_env.sh \
 && npm install \
 && cd .. \
 && sh ./compile.sh

RUN cd emsdk \
 && ./emsdk install  binaryen-tag-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

RUN git clone https://github.com/mrsmkl/verification-truebit \
 && cd verification-truebit \
 && source /emsdk/emsdk_env.sh \
 && sh ./build_ffprobe_wasm.sh \
 && solc --abi --optimize --overwrite --bin -o compiled task.sol \
 && npm install

RUN cd webasm-solidity/node \
 && cp app.html /var/www/html/index.html \
 && cp socketio.js /var/www/html/

RUN cd verification-truebit \
 && git pull \
 && source /emsdk/emsdk_env.sh \
 && npm install 

EXPOSE 80 22448 4001


