import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Paper,
  Chip,
  CircularProgress,
  Alert,
  Button,
} from '@mui/material';
import {
  Receipt as ReceiptIcon,
  ShoppingBag as ShoppingBagIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { orderService } from '../../services/orderService';
import { Order } from '../../types/order.types';

const OrderHistory: React.FC = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const navigate = useNavigate();

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      setLoading(true);
      const data = await orderService.getUserOrders();
      // Sort by creation date (newest first)
      const sorted = data.sort((a, b) => 
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );
      setOrders(sorted);
      setError('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to load orders. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'CREATED':
        return 'info';
      case 'PENDING':
        return 'warning';
      case 'COMPLETED':
        return 'success';
      case 'CANCELLED':
        return 'error';
      default:
        return 'default';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  if (orders.length === 0) {
    return (
      <Container maxWidth="md" sx={{ py: 8, textAlign: 'center' }}>
        <ShoppingBagIcon sx={{ fontSize: 80, color: 'text.secondary', mb: 2 }} />
        <Typography variant="h5" gutterBottom>
          No orders yet
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
          Start shopping to place your first order
        </Typography>
        <Button variant="contained" onClick={() => navigate('/products')}>
          Browse Products
        </Button>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Order History
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Box sx={{ mt: 3 }}>
        {orders.map((order) => (
          <Paper key={order.id} sx={{ p: 3, mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
              <Box>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                  <ReceiptIcon color="action" />
                  <Typography variant="h6">Order #{order.id}</Typography>
                  <Chip
                    label={order.status}
                    color={getStatusColor(order.status) as any}
                    size="small"
                  />
                </Box>
                <Typography variant="body2" color="text.secondary">
                  {formatDate(order.createdAt)}
                </Typography>
              </Box>
              <Typography variant="h6" color="primary">
                ${order.totalAmount.toFixed(2)}
              </Typography>
            </Box>

            <Box sx={{ mt: 2 }}>
              <Typography variant="body1">
                <strong>Product:</strong> {order.productName}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Quantity: {order.quantity} × ${order.unitPrice.toFixed(2)}
              </Typography>
            </Box>

            <Box sx={{ mt: 2, display: 'flex', gap: 2 }}>
              <Button
                variant="outlined"
                size="small"
                onClick={() => navigate(`/orders/${order.id}`)}
              >
                View Details
              </Button>
            </Box>
          </Paper>
        ))}
      </Box>
    </Container>
  );
};

export default OrderHistory;
