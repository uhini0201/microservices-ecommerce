import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
  Link,
  CircularProgress,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { LoginRequest } from '../../types/auth.types';

const LoginPage: React.FC = () => {
  const [credentials, setCredentials] = useState<LoginRequest>({
    username: '',
    password: '',
  });
  const [error, setError] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setCredentials({
      ...credentials,
      [e.target.name]: e.target.value,
    });
    setError(''); // Clear error when user types
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(credentials);
      // Navigation handled by AuthContext
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      display="flex"
      justifyContent="center"
      alignItems="center"
      minHeight="100vh"
      bgcolor="background.default"
      px={2}
    >
      <Card sx={{ maxWidth: 450, width: '100%' }}>
        <CardContent sx={{ p: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom textAlign="center">
            Login
          </Typography>
          <Typography variant="body2" color="text.secondary" textAlign="center" mb={3}>
            Sign in to your account to continue
          </Typography>

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <form onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Username"
              name="username"
              value={credentials.username}
              onChange={handleChange}
              required
              margin="normal"
              autoFocus
              disabled={loading}
            />
            <TextField
              fullWidth
              label="Password"
              name="password"
              type="password"
              value={credentials.password}
              onChange={handleChange}
              required
              margin="normal"
              disabled={loading}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading}
            >
              {loading ? <CircularProgress size={24} /> : 'Login'}
            </Button>

            <Typography variant="body2" textAlign="center">
              Don't have an account?{' '}
              <Link
                component="button"
                type="button"
                onClick={() => navigate('/register')}
                underline="hover"
              >
                Register here
              </Link>
            </Typography>
          </form>
        </CardContent>
      </Card>
    </Box>
  );
};

export default LoginPage;
