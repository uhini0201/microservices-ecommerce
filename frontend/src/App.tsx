import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box } from '@mui/material';
import theme from './theme';
import { AuthProvider } from './contexts/AuthContext';
import { CartProvider } from './contexts/CartContext';
import Header from './components/common/Header';
import HomePage from './components/common/HomePage';
import LoginPage from './components/auth/LoginPage';
import RegisterPage from './components/auth/RegisterPage';
import ProductList from './components/products/ProductList';
import CartPage from './components/cart/CartPage';
import OrderHistory from './components/orders/OrderHistory';
import UserProfile from './components/profile/UserProfile';
import ProtectedRoute from './components/common/ProtectedRoute';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <CartProvider>
          <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
            <Header />
            <Box component="main" sx={{ flexGrow: 1, bgcolor: 'background.default' }}>
              <Routes>
                {/* Public Routes */}
                <Route path="/" element={<HomePage />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/products" element={<ProductList />} />

                {/* Protected Routes */}
                <Route element={<ProtectedRoute />}>
                  <Route path="/cart" element={<CartPage />} />
                  <Route path="/orders" element={<OrderHistory />} />
                  <Route path="/profile" element={<UserProfile />} />
                </Route>

                {/* Catch all - redirect to home */}
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </Box>
          </Box>
        </CartProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
