# Fork layout

This is a personal fork of [dmilin1/hydra](https://github.com/dmilin1/hydra).

## Remotes

| Remote | URL | Use |
| --- | --- | --- |
| `origin` | `github.com/BenIsLegit/hydra` | Everything gets pushed here |
| `upstream` | `github.com/dmilin1/hydra` | Fetch only. Its push URL is set to `DISABLED_use_origin`, so a push to it fails |

## Branches

| Branch | Based on | Purpose |
| --- | --- | --- |
| `master` | `upstream/master` | Exact mirror of upstream. Never commit to it directly |
| `personal` | `master` | The Apollo build: name, icon, app ID, built-in server. Never PR this |
| `pr/<topic>` | `master` | One branch per upstream pull request |

## Syncing with upstream

```bash
git fetch upstream
git switch master && git merge --ff-only upstream/master && git push origin master
git switch personal && git merge master && git push origin personal
```

If `--ff-only` fails, something was committed to `master` by mistake. Move it to a `pr/*` branch before resetting `master`.

Icon conflicts on `personal` (upstream changing `assets/images/icon*.png`) resolve with `git checkout --ours <file>`.

## Upstream pull requests

```bash
git fetch upstream
git switch -c pr/<topic> upstream/master
# commit the change
git push -u origin pr/<topic>
gh pr create --repo dmilin1/hydra --base master --head BenIsLegit:pr/<topic>
```

Branch PRs from `upstream/master`, never from `personal`, so no Apollo changes leak into them. Upstream asks for `npm run lint:fix` and `npm run tsc` before opening a PR. To try a PR in the Apollo build, merge the `pr/*` branch into `personal`.

## Building Apollo (Android APK)

1. Create `.env.local` (gitignored) with the self-hosted server URL, including its access token:

   ```
   EXPO_PUBLIC_APOLLO_SERVER_URL=https://reddit.cathedral.gg/<ACCESS_TOKEN>
   ```

2. Install the SDK's CMake 3.31.6 once (the default 3.22.1 ships a ninja that hits the Windows 260-character path limit on react-native-reanimated):

   ```bash
   "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "cmake;3.31.6"
   ```

3. Build from Git Bash:

   ```bash
   scripts/build-apollo-apk.sh --clean
   ```

   It writes `android/app/build/outputs/apk/release/apollo-<version>-arm64-v8a.apk`. Drop `--clean` to reuse the existing `android/` folder, which is much faster.

The APK is signed with the React Native template's debug key. It's the same on every machine and every prebuild, so new builds install over old ones, but anyone could sign an APK with it. Don't distribute it.

The server is packaged for Cloudron at [git.cathedral.gg/Ben/hydra-server-cloudron-app](https://git.cathedral.gg/Ben/hydra-server-cloudron-app).
