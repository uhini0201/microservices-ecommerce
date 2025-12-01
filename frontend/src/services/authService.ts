import apiClient from './api';
import { LoginRequest, RegisterRequest, AuthResponse, RefreshTokenRequest } from '../types/auth.types';

export const authService = {
  /**
   * Register a new user
   */
  register: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>('/auth/register', data);
    return response.data;
  },

  /**
   * Login user
   */
  login: async (data: LoginRequest): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>('/auth/login', data);
    return response.data;
  },

  /**
   * Refresh access token
   */
  refreshToken: async (data: RefreshTokenRequest): Promise<AuthResponse> => {
    const response = await apiClient.post<AuthResponse>('/auth/refresh', data);
    return response.data;
  },

  /**
   * Logout user (invalidate refresh token)
   */
  logout: async (refreshToken: string): Promise<void> => {
    await apiClient.post('/auth/logout', { refreshToken });
  },
};

export default authService;
