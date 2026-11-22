import KeyStore from "../utils/KeyStore";

export const USE_CUSTOM_HYDRA_SERVER_KEY = "useHydraServer";
export const CUSTOM_HYDRA_SERVER_URL_KEY = "customHydraServerUrl";
export const DEFAULT_HYDRA_SERVER_URL = "https://api.hydraapp.io";

/**
 * Apollo: a self-hosted server baked in at build time from EXPO_PUBLIC_APOLLO_SERVER_URL
 * (set it in .env.local, which is gitignored because the URL carries the server's access
 * token). It's the default until changed in Settings > Advanced.
 */
export const BUILT_IN_HYDRA_SERVER_URL =
  process.env.EXPO_PUBLIC_APOLLO_SERVER_URL || undefined;

const customServerEnabled =
  KeyStore.getBoolean(USE_CUSTOM_HYDRA_SERVER_KEY) ??
  BUILT_IN_HYDRA_SERVER_URL !== undefined;
const customServerUrl = customServerEnabled
  ? (KeyStore.getString(CUSTOM_HYDRA_SERVER_URL_KEY) ??
    BUILT_IN_HYDRA_SERVER_URL)
  : undefined;

export const HYDRA_SERVER_URL = __DEV__
  ? (process.env.EXPO_PUBLIC_HYDRA_SERVER ?? DEFAULT_HYDRA_SERVER_URL)
  : (customServerUrl ?? DEFAULT_HYDRA_SERVER_URL);

export const USING_CUSTOM_HYDRA_SERVER =
  customServerUrl !== undefined && !customServerUrl.includes("hydraapp.io");
