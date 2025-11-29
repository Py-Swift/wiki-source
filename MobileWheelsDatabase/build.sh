#!/bin/bash
# Build script for MobileWheelsDatabase
# Builds Swift WASM using Swift 6.2.1 official WASM support

set -e

# Use Swift 6.2.1 WASM toolchain
echo "🔨 Building Swift WASM..."
swift build --swift-sdk swift-6.2.1-RELEASE_wasm -c release \
  -Xswiftc -Xclang-linker -Xswiftc -mexec-model=reactor

echo "📦 Copying WASM binary..."
cp .build/release/MobileWheelsDatabaseWasm.wasm ./

SIZE=$(ls -lh MobileWheelsDatabaseWasm.wasm | awk '{print $5}')
echo "✅ WASM built: $SIZE"

# Copy to docs directory if it exists
if [ -d "../docs/mobile-wheels-support" ]; then
    echo "📋 Copying to docs/mobile-wheels-support/wasm/..."
    mkdir -p ../docs/mobile-wheels-support/wasm
    cp MobileWheelsDatabaseWasm.wasm ../docs/mobile-wheels-support/wasm/
    echo "✅ Files copied to docs/mobile-wheels-support/wasm/"
fi

echo ""
echo "🎉 Build complete!"
echo "To test locally: python3 -m http.server 8000"
