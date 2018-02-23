# Clone ffmpeg project
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg

echo "Beginning build..."

# Configure
EMCC_WASM_BACKEND=1
EM_PKG_CONFIG_PATH="$HOME/compiled/wasm/lib/pkgconfig"
emconfigure ./configure --disable-programs --disable-doc --disable-sdl2 \
            --disable-iconv --disable-muxers --disable-demuxers --disable-parsers \
            --disable-protocols --disable-encoders --disable-decoders --disable-filters \
            --disable-bsfs --disable-postproc --disable-lzma --enable-protocol=rtmp,file \
            --enable-muxer=mpegts,hls,segment,image2 \
            --enable-demuxer=flv,mpegts,mp4,mkv,mov \
            --enable-bsf=h264_mp4toannexb,aac_adtstoasc,h264_metadata,h264_redundant_pps \
            --enable-parser=aac,aac_latm,h264 --enable-encoder=png,mjpeg \
            --enable-filter=abuffer,buffer,abuffersink,buffersink,afifo,fifo,aformat \
            --enable-filter=aresample,asetnsamples,fps,scale --enable-decoder=aac,h264 \
            --prefix="$HOME/compiled/wasm" --cc=emcc --enable-cross-compile \
            --target-os=none --arch=x86_32 --cpu=generic --enable-ffprobe --disable-asm \
            --disable-devices --disable-pthreads --disable-network --disable-hwaccels \
            --disable-stripping

# Generate linked LLVM bitcode
make
make install

cd ..

cp $HOME/compiled/wasm/bin/ffprobe ffprobe.bc

emcc -o ffprobe.js ffprobe.bc

cp data/correct.ts input.ts

node ../emscripten-module-wrapper/prepare.js ffprobe.js --arg=-i --arg=input.ts --file input.ts
# Use the below line if you want to use the floating point emulator
# node ../emscripten-module-wrapper/prepare.js ffprobe.js --float --arg=-i --arg=input.ts --file input.ts
