import apiClient from './api';
import { UserProfile, UpdateUserProfileRequest } from '../types/user.types';

export const userService = {
  /**
   * Get current user's profile
   */
  getProfile: async (): Promise<UserProfile> => {
    const response = await apiClient.get<UserProfile>('/users/me');
    return response.data;
  },

  /**
   * Update current user's profile
   */
  updateProfile: async (data: UpdateUserProfileRequest): Promise<UserProfile> => {
    const response = await apiClient.put<UserProfile>('/users/me', data);
    return response.data;
  },

  /**
   * Get profile by username (public)
   */
  getByUsername: async (username: string): Promise<UserProfile> => {
    const response = await apiClient.get<UserProfile>(`/users/${username}`);
    return response.data;
  },
};

export default userService;
