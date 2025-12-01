import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Paper,
  TextField,
  Button,
  Grid,
  CircularProgress,
  Alert,
  Switch,
  FormControlLabel,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
} from '@mui/material';
import { AccountCircle as AccountCircleIcon } from '@mui/icons-material';
import { userService } from '../../services/userService';
import { UserProfile, UpdateUserProfileRequest } from '../../types/user.types';
import { useAuth } from '../../contexts/AuthContext';

const UserProfilePage: React.FC = () => {
  const { user } = useAuth();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [formData, setFormData] = useState<UpdateUserProfileRequest>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string>('');
  const [success, setSuccess] = useState<string>('');
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      setLoading(true);
      const data = await userService.getProfile();
      setProfile(data);
      setFormData({
        fullName: data.fullName || '',
        phoneNumber: data.phoneNumber || '',
        address: data.address || '',
        city: data.city || '',
        state: data.state || '',
        country: data.country || '',
        postalCode: data.postalCode || '',
        bio: data.bio || '',
        emailNotifications: data.emailNotifications,
        smsNotifications: data.smsNotifications,
        pushNotifications: data.pushNotifications,
        preferredLanguage: data.preferredLanguage,
        preferredCurrency: data.preferredCurrency,
      });
      setError('');
    } catch (err: any) {
      // Profile doesn't exist yet, that's ok
      if (err.response?.status === 404) {
        setError('Profile not found. You can create one by filling out the form below.');
        setIsEditing(true);
      } else {
        setError(err.response?.data?.message || 'Failed to load profile.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (field: keyof UpdateUserProfileRequest, value: any) => {
    setFormData({ ...formData, [field]: value });
    setError('');
    setSuccess('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError('');
    setSuccess('');

    try {
      const updated = await userService.updateProfile(formData);
      setProfile(updated);
      setSuccess('Profile updated successfully!');
      setIsEditing(false);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to update profile. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
        <AccountCircleIcon sx={{ fontSize: 40, mr: 2 }} />
        <Typography variant="h4" component="h1">
          My Profile
        </Typography>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }} onClose={() => setSuccess('')}>
          {success}
        </Alert>
      )}

      <Paper sx={{ p: 3 }}>
        <form onSubmit={handleSubmit}>
          <Typography variant="h6" gutterBottom>
            Account Information
          </Typography>
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Username"
                value={user?.username || ''}
                disabled
                helperText="Username cannot be changed"
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Email"
                value={profile?.email || ''}
                disabled
                helperText="Email is set during registration"
              />
            </Grid>
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h6" gutterBottom>
            Personal Information
          </Typography>
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Full Name"
                value={formData.fullName || ''}
                onChange={(e) => handleChange('fullName', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Phone Number"
                value={formData.phoneNumber || ''}
                onChange={(e) => handleChange('phoneNumber', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Bio"
                value={formData.bio || ''}
                onChange={(e) => handleChange('bio', e.target.value)}
                multiline
                rows={3}
                disabled={!isEditing}
              />
            </Grid>
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h6" gutterBottom>
            Address
          </Typography>
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Street Address"
                value={formData.address || ''}
                onChange={(e) => handleChange('address', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="City"
                value={formData.city || ''}
                onChange={(e) => handleChange('city', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="State/Province"
                value={formData.state || ''}
                onChange={(e) => handleChange('state', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Country"
                value={formData.country || ''}
                onChange={(e) => handleChange('country', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Postal Code"
                value={formData.postalCode || ''}
                onChange={(e) => handleChange('postalCode', e.target.value)}
                disabled={!isEditing}
              />
            </Grid>
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Typography variant="h6" gutterBottom>
            Preferences
          </Typography>
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel>Preferred Language</InputLabel>
                <Select
                  label="Preferred Language"
                  value={formData.preferredLanguage || 'en'}
                  onChange={(e) => handleChange('preferredLanguage', e.target.value)}
                  disabled={!isEditing}
                >
                  <MenuItem value="en">English</MenuItem>
                  <MenuItem value="es">Spanish</MenuItem>
                  <MenuItem value="fr">French</MenuItem>
                  <MenuItem value="de">German</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel>Preferred Currency</InputLabel>
                <Select
                  label="Preferred Currency"
                  value={formData.preferredCurrency || 'USD'}
                  onChange={(e) => handleChange('preferredCurrency', e.target.value)}
                  disabled={!isEditing}
                >
                  <MenuItem value="USD">USD ($)</MenuItem>
                  <MenuItem value="EUR">EUR (€)</MenuItem>
                  <MenuItem value="GBP">GBP (£)</MenuItem>
                  <MenuItem value="JPY">JPY (¥)</MenuItem>
                </Select>
              </FormControl>
            </Grid>
          </Grid>

          <Typography variant="h6" gutterBottom>
            Notification Preferences
          </Typography>
          <Box sx={{ mb: 3 }}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.emailNotifications ?? true}
                  onChange={(e) => handleChange('emailNotifications', e.target.checked)}
                  disabled={!isEditing}
                />
              }
              label="Email Notifications"
            />
            <FormControlLabel
              control={
                <Switch
                  checked={formData.smsNotifications ?? false}
                  onChange={(e) => handleChange('smsNotifications', e.target.checked)}
                  disabled={!isEditing}
                />
              }
              label="SMS Notifications"
            />
            <FormControlLabel
              control={
                <Switch
                  checked={formData.pushNotifications ?? true}
                  onChange={(e) => handleChange('pushNotifications', e.target.checked)}
                  disabled={!isEditing}
                />
              }
              label="Push Notifications"
            />
          </Box>

          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
            {!isEditing ? (
              <Button variant="contained" onClick={() => setIsEditing(true)}>
                Edit Profile
              </Button>
            ) : (
              <>
                <Button
                  variant="outlined"
                  onClick={() => {
                    setIsEditing(false);
                    loadProfile();
                  }}
                  disabled={saving}
                >
                  Cancel
                </Button>
                <Button type="submit" variant="contained" disabled={saving}>
                  {saving ? <CircularProgress size={24} /> : 'Save Changes'}
                </Button>
              </>
            )}
          </Box>
        </form>
      </Paper>
    </Container>
  );
};

export default UserProfilePage;
