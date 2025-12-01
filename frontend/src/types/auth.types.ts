export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
  role?: 'USER' | 'ADMIN' | 'GUEST';
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  username: string;
  role: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface User {
  username: string;
  role: string;
}
