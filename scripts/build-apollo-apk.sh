#!/bin/bash
# Builds the Apollo release APK (arm64) on Windows with Git Bash.
#
#   scripts/build-apollo-apk.sh           reuse android/ if it exists
#   scripts/build-apollo-apk.sh --clean   regenerate android/ with expo prebuild
#
# Needs ANDROID_HOME, a JDK, and the SDK's "cmake;3.31.6" package. The default CMake 3.22.1
# ships ninja 1.10, which can't create paths over 260 characters on Windows, and
# react-native-reanimated's object paths are longer than that.
#
# The built-in server comes from EXPO_PUBLIC_APOLLO_SERVER_URL in .env.local.
set -eo pipefail

CMAKE_VERSION=3.31.6
ABI=arm64-v8a

cd "$(dirname "$0")/.."

if [[ -z "$ANDROID_HOME" ]]; then
  echo "ERROR: ANDROID_HOME is not set" >&2
  exit 1
fi
if [[ ! -x "$ANDROID_HOME/cmake/$CMAKE_VERSION/bin/ninja.exe" && ! -x "$ANDROID_HOME/cmake/$CMAKE_VERSION/bin/ninja" ]]; then
  echo "ERROR: CMake $CMAKE_VERSION is missing. Install it with:" >&2
  echo "  \"\$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager\" \"cmake;$CMAKE_VERSION\"" >&2
  exit 1
fi
if ! grep -qs '^EXPO_PUBLIC_APOLLO_SERVER_URL=.\+' .env.local; then
  echo "WARNING: EXPO_PUBLIC_APOLLO_SERVER_URL is not set in .env.local; the build won't have a built-in server" >&2
fi

export SENTRY_DISABLE_AUTO_UPLOAD=true
export NODE_ENV=production

if [[ "$1" == "--clean" || ! -d android ]]; then
  echo "=== expo prebuild"
  CI=1 node node_modules/expo/bin/cli prebuild -p android --clean --no-install
fi

# android/ is generated, so these are reapplied on every build.
cmake_dir=$(cygpath -w "$ANDROID_HOME/cmake/$CMAKE_VERSION" 2>/dev/null || echo "$ANDROID_HOME/cmake/$CMAKE_VERSION")
cmake_dir=${cmake_dir//\\/\\\\}
cmake_dir=${cmake_dir//:/\\:}
sed -i '/^cmake.dir=/d' android/local.properties 2>/dev/null || true
echo "cmake.dir=$cmake_dir" >> android/local.properties
# Expo's template gives Gradle 512 MB of metaspace; R8 runs out on this app.
sed -i 's/^org.gradle.jvmargs=.*/org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1536m/' android/gradle.properties

# Gradle doesn't track .env.local, so drop the old bundle to pick up changes to it.
rm -rf android/app/build/generated/assets/react android/app/build/generated/assets/createBundleReleaseJsAndAssets

echo "=== gradle assembleRelease ($ABI)"
gradlew=./gradlew
[[ "$OS" == "Windows_NT" ]] && gradlew=./gradlew.bat
(cd android && $gradlew assembleRelease -PreactNativeArchitectures=$ABI --console=plain -q)

version=$(node -p "require('./package.json').version")
out="android/app/build/outputs/apk/release/apollo-$version-$ABI.apk"
cp android/app/build/outputs/apk/release/app-release.apk "$out"
echo "=== built $out"
