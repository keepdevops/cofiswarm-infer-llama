#!/bin/bash
# =============================================
# llama.cpp Build Script for M3 Mac - Fixed v3 (mlx-env safe)
# =============================================

BASE_DIR="/Users/Shared/llama"
LLAMA_DIR="$BASE_DIR/llama.cpp-master"
MODELS_DIR="$BASE_DIR/models"

echo "🔧 Setting permissions..."
sudo chown -R $USER:staff "$BASE_DIR" 2>/dev/null || true
sudo chmod -R u+rwX "$BASE_DIR" 2>/dev/null || true

mkdir -p "$MODELS_DIR"

# === Environment Cleanup (Critical for mlx-env) ===
echo "🧼 Cleaning conflicting environment variables..."
unset CC
unset CXX
unset CMAKE_C_COMPILER
unset CMAKE_CXX_COMPILER
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
unset SDKROOT
unset CPATH
unset CONDA_PREFIX  # Helps reduce conda interference

# Force native Apple Clang
export CC="$(xcrun -find clang)"
export CXX="$(xcrun -find clang++)"

echo "Using compiler: $CC"

# === Git Setup ===
if [ -d "$LLAMA_DIR" ]; then
    echo "📁 Found existing folder at $LLAMA_DIR"
    cd "$LLAMA_DIR" || { echo "❌ Cannot enter directory"; exit 1; }
    
    if [ ! -d ".git" ]; then
        echo "🔄 Re-cloning to ensure clean git repo..."
        cd ..
        rm -rf llama.cpp-master
        git clone https://github.com/ggml-org/llama.cpp.git llama.cpp-master
        cd llama.cpp-master
    else
        echo "📥 Pulling latest..."
        git pull --ff-only || echo "⚠️ Pull skipped"
    fi
else
    echo "📥 Cloning fresh..."
    git clone https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR"
    cd "$LLAMA_DIR"
fi

# === Build ===
echo "🔨 Configuring build with Metal for M3..."
rm -rf build

cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DGGML_METAL_EMBED_LIBRARY=ON \
    -DLLAMA_CURL=ON \
    -DLLAMA_SERVER=ON \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX"

if [ $? -ne 0 ]; then
    echo "❌ CMake failed. Try deactivating conda first: conda deactivate"
    exit 1
fi

echo "🔨 Building (3-8 minutes)..."
cmake --build build --config Release -j $(sysctl -n hw.logicalcpu)

if [ $? -ne 0 ]; then
    echo "❌ Build failed."
    exit 1
fi

echo ""
echo "🎉 Build Complete!"
echo "📍 Binaries → $LLAMA_DIR/build/bin/"
echo ""
echo "Test:"
echo "cd $LLAMA_DIR"
echo "./build/bin/llama-cli --version"
