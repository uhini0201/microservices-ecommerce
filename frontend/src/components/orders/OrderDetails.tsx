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
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Divider,
} from '@mui/material';
import {
  Receipt as ReceiptIcon,
  ArrowBack as ArrowBackIcon,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';
import { orderService } from '../../services/orderService';
import { Order } from '../../types/order.types';

const OrderDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const [success, setSuccess] = useState<string>('');
  const [cancelling, setCancelling] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (id) {
      loadOrder(parseInt(id));
    }
  }, [id]);

  const loadOrder = async (orderId: number) => {
    try {
      setLoading(true);
      const data = await orderService.getById(orderId);
      setOrder(data);
      setError('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to load order details.');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelOrder = async () => {
    if (!order) return;
    
    if (!window.confirm('Are you sure you want to cancel this order?')) {
      return;
    }

    try {
      setCancelling(true);
      setError('');
      setSuccess('');
      const cancelledOrder = await orderService.cancelOrder(order.id);
      setOrder(cancelledOrder);
      setSuccess('Order cancelled successfully');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to cancel order');
    } finally {
      setCancelling(false);
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

  if (error || !order) {
    return (
      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Alert severity="error" sx={{ mb: 3 }}>
          {error || 'Order not found'}
        </Alert>
        <Button variant="outlined" onClick={() => navigate('/orders')} startIcon={<ArrowBackIcon />}>
          Back to Orders
        </Button>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <Button variant="outlined" onClick={() => navigate('/orders')} startIcon={<ArrowBackIcon />}>
          Back
        </Button>
        <Typography variant="h4" component="h1">
          Order Details
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

      <Paper sx={{ p: 4 }}>
        {/* Order Header */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
          <Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 1 }}>
              <ReceiptIcon color="action" fontSize="large" />
              <Typography variant="h5">Order #{order.id}</Typography>
              <Chip
                label={order.status}
                color={getStatusColor(order.status) as any}
                size="medium"
              />
            </Box>
            <Typography variant="body1" color="text.secondary">
              Placed on {formatDate(order.createdAt)}
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
              Customer: {order.customer}
            </Typography>
          </Box>
          <Box sx={{ textAlign: 'right' }}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Total Items: {order.itemCount || order.items?.length || 0}
            </Typography>
            <Typography variant="h4" color="primary">
              ₹{order.totalAmount.toFixed(2)}
            </Typography>
          </Box>
        </Box>

        <Divider sx={{ my: 3 }} />

        {/* Order Items Table */}
        <Typography variant="h6" gutterBottom sx={{ mb: 2 }}>
          Items Ordered
        </Typography>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>Product</strong></TableCell>
                <TableCell align="center"><strong>Quantity</strong></TableCell>
                <TableCell align="right"><strong>Unit Price</strong></TableCell>
                <TableCell align="right"><strong>Subtotal</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {order.items && order.items.length > 0 ? (
                order.items.map((item, index) => (
                  <TableRow key={index}>
                    <TableCell>{item.productName}</TableCell>
                    <TableCell align="center">{item.quantity}</TableCell>
                    <TableCell align="right">₹{item.unitPrice.toFixed(2)}</TableCell>
                    <TableCell align="right">₹{item.subtotal.toFixed(2)}</TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={4} align="center">
                    <Typography variant="body2" color="text.secondary">
                      No items found
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <Divider sx={{ my: 3 }} />

        {/* Order Summary */}
        <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
          <Box sx={{ minWidth: 300 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
              <Typography variant="h6">Total Amount:</Typography>
              <Typography variant="h6" color="primary">
                ₹{order.totalAmount.toFixed(2)}
              </Typography>
            </Box>
            <Typography variant="caption" color="text.secondary">
              * All prices are inclusive of applicable taxes
            </Typography>
          </Box>
        </Box>

        <Divider sx={{ my: 3 }} />

        {/* Actions */}
        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
          <Button
            variant="outlined"
            onClick={() => navigate('/orders')}
          >
            Back to Orders
          </Button>
          <Button
            variant="contained"
            startIcon={<ReceiptIcon />}
            onClick={() => navigate(`/orders/${order.id}/invoice`)}
          >
            View Invoice
          </Button>
          {order.status === 'CREATED' && (
            <Button
              variant="outlined"
              color="error"
              onClick={handleCancelOrder}
              disabled={cancelling}
            >
              {cancelling ? 'Cancelling...' : 'Cancel Order'}
            </Button>
          )}
        </Box>
      </Paper>
    </Container>
  );
};

export default OrderDetails;
