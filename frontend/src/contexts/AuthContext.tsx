import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { LoginRequest, RegisterRequest, AuthResponse, User } from '../types/auth.types';
import { storage } from '../utils/storage';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  register: (data: RegisterRequest) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  // Initialize auth state from localStorage
  useEffect(() => {
    const initializeAuth = () => {
      const storedUser = storage.getUser();
      const token = storage.getAccessToken();
      
      if (storedUser && token) {
        setUser(storedUser);
      }
      
      setLoading(false);
    };

    initializeAuth();
  }, []);

  const login = async (credentials: LoginRequest): Promise<void> => {
    try {
      const response: AuthResponse = await authService.login(credentials);
      
      // Store tokens
      storage.setAccessToken(response.accessToken);
      storage.setRefreshToken(response.refreshToken);
      
      // Store user info
      const userData: User = {
        username: response.username,
        role: response.role,
      };
      storage.setUser(userData);
      setUser(userData);

      // Redirect to home page
      navigate('/');
    } catch (error) {
      throw error;
    }
  };

  const register = async (data: RegisterRequest): Promise<void> => {
    try {
      const response: AuthResponse = await authService.register(data);
      
      // Store tokens
      storage.setAccessToken(response.accessToken);
      storage.setRefreshToken(response.refreshToken);
      
      // Store user info
      const userData: User = {
        username: response.username,
        role: response.role,
      };
      storage.setUser(userData);
      setUser(userData);

      // Redirect to home page
      navigate('/');
    } catch (error) {
      throw error;
    }
  };

  const logout = async (): Promise<void> => {
    try {
      const refreshToken = storage.getRefreshToken();
      if (refreshToken) {
        await authService.logout(refreshToken);
      }
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      // Clear local storage and state regardless of API success
      storage.clearAuth();
      setUser(null);
      navigate('/login');
    }
  };

  const value: AuthContextType = {
    user,
    loading,
    login,
    register,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export default AuthContext;
