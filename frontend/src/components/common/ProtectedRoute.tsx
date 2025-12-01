import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { CircularProgress, Box } from '@mui/material';

interface ProtectedRouteProps {
  redirectPath?: string;
}

/**
 * Protected route component that redirects to login if user is not authenticated
 */
const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ redirectPath = '/login' }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        <CircularProgress />
      </Box>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to={redirectPath} replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
