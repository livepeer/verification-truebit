# Clone ffmpeg project
# Generate linked LLVM bitcode
cd ffmpeg
make || exit 0
make install

cd ..

cp $HOME/compiled/wasm/bin/ffcheck ffcheck.bc

emcc -o ffcheck.js ffcheck.bc

#cp data/correct.ts input.ts

#node ../emscripten-module-wrapper/prepare.js ffprobe.js --arg=-show_format --arg=-i --arg=input.ts --file input.ts
node ../emscripten-module-wrapper/prepare.js ffcheck.js --file output.data --file input.ts

# Use the below line if you want to use the floating point emulator
# node ../emscripten-module-wrapper/prepare.js ffprobe.js --float --arg=-i --arg=input.ts --file input.ts
