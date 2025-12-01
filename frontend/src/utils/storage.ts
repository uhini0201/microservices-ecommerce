/**
 * Storage utility for managing localStorage operations
 */

const STORAGE_KEYS = {
  ACCESS_TOKEN: 'accessToken',
  REFRESH_TOKEN: 'refreshToken',
  USER: 'user',
} as const;

export const storage = {
  // Token operations
  getAccessToken: (): string | null => {
    return localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  },

  setAccessToken: (token: string): void => {
    localStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, token);
  },

  getRefreshToken: (): string | null => {
    return localStorage.getItem(STORAGE_KEYS.REFRESH_TOKEN);
  },

  setRefreshToken: (token: string): void => {
    localStorage.setItem(STORAGE_KEYS.REFRESH_TOKEN, token);
  },

  // User operations
  getUser: (): { username: string; role: string } | null => {
    const userStr = localStorage.getItem(STORAGE_KEYS.USER);
    if (!userStr) return null;
    try {
      return JSON.parse(userStr);
    } catch {
      return null;
    }
  },

  setUser: (user: { username: string; role: string }): void => {
    localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(user));
  },

  // Clear all auth data
  clearAuth: (): void => {
    localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
    localStorage.removeItem(STORAGE_KEYS.USER);
  },

  // Check if user is authenticated
  isAuthenticated: (): boolean => {
    return !!storage.getAccessToken();
  },
};

export default storage;
