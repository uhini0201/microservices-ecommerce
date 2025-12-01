# User Service

User profile management service providing CRUD operations for user profiles with preferences and notification settings.

## Port
- **8087**

## Features

### Core Functionality
- **Create User Profile**: Register new user profile with personal information
- **Get Profile**: Retrieve user profile by username or current authenticated user
- **Update Profile**: Modify user information, preferences, and notification settings
- **Delete Profile**: Remove user profile
- **List All Profiles**: Admin function to list all user profiles

### User Profile Fields
- **Personal Information**: Full name, email, phone number
- **Address**: Address, city, state, country, postal code
- **Profile**: Bio, avatar URL
- **Preferences**: Preferred language, preferred currency
- **Notifications**: Email, SMS, and push notification settings

### Security
- **JWT Authentication**: All endpoints (except health) require JWT token
- **User Context**: Automatically extracts username from JWT for `/me` endpoints
- **Authorization Ready**: Prepared for role-based access control

## API Endpoints

### Health Check
```
GET /users/health
```
Returns service health status (public endpoint).

### Create Profile
```
POST /users
Content-Type: application/json
Authorization: Bearer <token>

{
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "country": "USA",
  "postalCode": "10001",
  "bio": "Software engineer",
  "avatarUrl": "https://example.com/avatar.jpg",
  "emailNotifications": true,
  "smsNotifications": false,
  "pushNotifications": true,
  "preferredLanguage": "en",
  "preferredCurrency": "USD"
}
```

### Get My Profile
```
GET /users/me
Authorization: Bearer <token>
```
Returns the profile of the authenticated user (from JWT token).

### Get All Profiles
```
GET /users
Authorization: Bearer <token>
```
Returns list of all user profiles (admin function).

### Get Profile by Username
```
GET /users/{username}
Authorization: Bearer <token>
```

### Update My Profile
```
PUT /users/me
Content-Type: application/json
Authorization: Bearer <token>

{
  "fullName": "John Smith",
  "phoneNumber": "+1234567890",
  "bio": "Senior Software Engineer",
  "emailNotifications": false
}
```
All fields are optional. Only provided fields will be updated.

### Update Profile by Username
```
PUT /users/{username}
Content-Type: application/json
Authorization: Bearer <token>

{
  "fullName": "Updated Name"
}
```
Admin function to update any user's profile.

### Delete My Profile
```
DELETE /users/me
Authorization: Bearer <token>
```
Deletes the authenticated user's profile.

### Delete Profile by Username
```
DELETE /users/{username}
Authorization: Bearer <token>
```
Admin function to delete any user's profile.

## Database Schema

### user_profiles Table
```sql
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    bio VARCHAR(1000),
    avatar_url VARCHAR(255),
    email_notifications BOOLEAN NOT NULL DEFAULT true,
    sms_notifications BOOLEAN NOT NULL DEFAULT false,
    push_notifications BOOLEAN NOT NULL DEFAULT true,
    preferred_language VARCHAR(10) DEFAULT 'en',
    preferred_currency VARCHAR(10) DEFAULT 'USD',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

## Integration with Auth Service

The user-service integrates with auth-service by:
1. Using the same JWT secret for token validation
2. Extracting username from JWT tokens
3. Linking profiles to users via username field
4. Allowing profile creation after user registration

## Configuration

### Environment Variables
- `JWT_SECRET`: Secret key for JWT token validation
- `SPRING_PROFILES_ACTIVE`: Profile to use (local/docker)

### Database
- PostgreSQL database connection configured via Spring profiles
- Automatic table creation with Hibernate DDL

## Testing

### Example Workflow
1. Register user in auth-service
2. Login to get JWT token
3. Create user profile with token
4. Update profile information
5. Retrieve profile data

## Future Enhancements
- Profile picture upload
- Social media links
- Privacy settings
- Account verification status
- Two-factor authentication preferences
- Activity log
