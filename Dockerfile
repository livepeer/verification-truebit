FROM ubuntu:17.10
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev \
 && opam init -y

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

RUN git clone https://github.com/mrsmkl/verification-truebit \
 && cd verification-truebit \
 && source /emsdk/emsdk_env.sh  \
 && sh ./build_ffprobe_wasm.sh

