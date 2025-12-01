export interface UserProfile {
  id: number;
  username: string;
  email: string;
  fullName?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  bio?: string;
  avatarUrl?: string;
  emailNotifications: boolean;
  smsNotifications: boolean;
  pushNotifications: boolean;
  preferredLanguage: string;
  preferredCurrency: string;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateUserProfileRequest {
  fullName?: string;
  phoneNumber?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  bio?: string;
  avatarUrl?: string;
  emailNotifications?: boolean;
  smsNotifications?: boolean;
  pushNotifications?: boolean;
  preferredLanguage?: string;
  preferredCurrency?: string;
}
