import React, { useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Button,
  Paper,
  IconButton,
  TextField,
  Divider,
  Grid,
  Alert,
} from '@mui/material';
import {
  Delete as DeleteIcon,
  ShoppingCart as ShoppingCartIcon,
  ArrowBack as ArrowBackIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';
import { useAuth } from '../../contexts/AuthContext';
import { orderService } from '../../services/orderService';

const CartPage: React.FC = () => {
  const navigate = useNavigate();
  const { cart, removeFromCart, updateQuantity, clearCart, getTotalPrice } = useCart();
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>('');
  const [success, setSuccess] = useState<string>('');

  const handleQuantityChange = (productId: number, newQuantity: number) => {
    if (newQuantity >= 1) {
      updateQuantity(productId, newQuantity);
    }
  };

  const handleCheckout = async () => {
    if (cart.length === 0) return;

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      // Create a single order with all cart items
      await orderService.create({
        customer: user?.username || 'guest',
        items: cart.map((item) => ({
          productId: item.product.id,
          quantity: item.quantity,
        })),
      });

      setSuccess('Order placed successfully!');
      clearCart();

      // Redirect to orders page after 2 seconds
      setTimeout(() => {
        navigate('/orders');
      }, 2000);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to place order. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (cart.length === 0) {
    return (
      <Container maxWidth="md" sx={{ py: 8, textAlign: 'center' }}>
        <ShoppingCartIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
        <Typography variant="h5" gutterBottom>
          Your cart is empty
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
          Start shopping to add items to your cart
        </Typography>
        <Button
          variant="contained"
          onClick={() => navigate('/products')}
          startIcon={<ArrowBackIcon />}
        >
          Continue Shopping
        </Button>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Shopping Cart
      </Typography>

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

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          {cart.map((item) => (
            <Paper key={item.product.id} sx={{ p: 3, mb: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Box sx={{ flexGrow: 1 }}>
                  <Typography variant="h6">{item.product.name}</Typography>
                  {item.product.description && (
                    <Typography variant="body2" color="text.secondary">
                      {item.product.description}
                    </Typography>
                  )}
                  <Typography variant="h6" color="primary" sx={{ mt: 1 }}>
                    ₹{item.product.price.toFixed(2)}
                  </Typography>
                </Box>

                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <TextField
                    type="number"
                    value={item.quantity}
                    onChange={(e) =>
                      handleQuantityChange(item.product.id, parseInt(e.target.value) || 1)
                    }
                    inputProps={{ min: 1, max: item.product.stock }}
                    sx={{ width: 80 }}
                    size="small"
                  />
                  <Typography variant="body1" sx={{ minWidth: 80, textAlign: 'right' }}>
                    ₹{(item.product.price * item.quantity).toFixed(2)}
                  </Typography>
                  <IconButton
                    color="error"
                    onClick={() => removeFromCart(item.product.id)}
                    aria-label="Remove item"
                  >
                    <DeleteIcon />
                  </IconButton>
                </Box>
              </Box>
            </Paper>
          ))}

          <Button
            variant="outlined"
            onClick={() => navigate('/products')}
            startIcon={<ArrowBackIcon />}
            sx={{ mt: 2 }}
          >
            Continue Shopping
          </Button>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, position: 'sticky', top: 80 }}>
            <Typography variant="h6" gutterBottom>
              Order Summary
            </Typography>
            <Divider sx={{ my: 2 }} />

            <Box sx={{ mb: 2 }}>
              {cart.map((item) => (
                <Box
                  key={item.product.id}
                  sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}
                >
                  <Typography variant="body2" color="text.secondary">
                    {item.product.name} × {item.quantity}
                  </Typography>
                  <Typography variant="body2">
                    ₹{(item.product.price * item.quantity).toFixed(2)}
                  </Typography>
                </Box>
              ))}
            </Box>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
              <Typography variant="h6">Total</Typography>
              <Typography variant="h6" color="primary">
                ₹{getTotalPrice().toFixed(2)}
              </Typography>
            </Box>

            <Button
              fullWidth
              variant="contained"
              size="large"
              onClick={handleCheckout}
              disabled={loading}
            >
              {loading ? 'Processing...' : 'Checkout'}
            </Button>

            <Button
              fullWidth
              variant="outlined"
              color="error"
              sx={{ mt: 2 }}
              onClick={clearCart}
            >
              Clear Cart
            </Button>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};

export default CartPage;
