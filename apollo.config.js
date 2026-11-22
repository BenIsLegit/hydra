/**
 * Apollo: personal build of Hydra. Every app.config.ts difference from upstream lives here,
 * so upstream changes to app.config.ts merge cleanly into the `personal` branch.
 *
 * CommonJS for the same reason as constants/appIcons.js: Expo loads app.config.ts in plain
 * Node and can't resolve local .ts imports.
 */

const APP_ID = "gg.cathedral.apollo";

/**
 * @param {{ expo: Record<string, any> }} config upstream's app config
 * @returns {{ expo: Record<string, any> }}
 */
function withApollo(config) {
  const expo = { ...config.expo };

  expo.name = "Apollo";
  expo.slug = "apollo";

  // Own app ID, so it installs alongside the store build of Hydra.
  const { appStoreUrl: _appStoreUrl, ...ios } = expo.ios;
  expo.ios = { ...ios, bundleIdentifier: APP_ID };
  expo.android = {
    ...expo.android,
    package: APP_ID,
    adaptiveIcon: {
      foregroundImage: "./assets/images/icon_android.png",
      backgroundImage: "./assets/images/icon_android_background.png",
    },
  };

  // Drop upstream's EAS project: builds can't run under its owner, and its OTA updates
  // would replace this build's JavaScript with upstream's.
  delete expo.owner;
  expo.extra = { ...expo.extra, eas: {} };
  expo.updates = { enabled: false };

  return { ...config, expo };
}

module.exports = { withApollo, APP_ID };
