import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Paper,
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
  ArrowBack as ArrowBackIcon,
  Print as PrintIcon,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';
import { orderService } from '../../services/orderService';
import { Invoice } from '../../types/order.types';

const InvoicePage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [invoice, setInvoice] = useState<Invoice | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const navigate = useNavigate();

  useEffect(() => {
    if (id) {
      loadInvoice(parseInt(id));
    }
  }, [id]);

  const loadInvoice = async (orderId: number) => {
    try {
      setLoading(true);
      const data = await orderService.getInvoice(orderId);
      setInvoice(data);
      setError('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to load invoice.');
    } finally {
      setLoading(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  if (error || !invoice) {
    return (
      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Alert severity="error" sx={{ mb: 3 }}>
          {error || 'Invoice not found'}
        </Alert>
        <Button variant="outlined" onClick={() => navigate('/orders')} startIcon={<ArrowBackIcon />}>
          Back to Orders
        </Button>
      </Container>
    );
  }

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Box sx={{ mb: 3, display: 'flex', gap: 2, '@media print': { display: 'none' } }}>
        <Button variant="outlined" onClick={() => navigate(`/orders/${invoice.orderId}`)} startIcon={<ArrowBackIcon />}>
          Back
        </Button>
        <Button variant="contained" onClick={handlePrint} startIcon={<PrintIcon />}>
          Print Invoice
        </Button>
      </Box>

      <Paper sx={{ p: 4 }}>
        {/* Invoice Header */}
        <Box sx={{ mb: 4, textAlign: 'center' }}>
          <Typography variant="h4" gutterBottom>
            TAX INVOICE
          </Typography>
          <Typography variant="body1" color="text.secondary">
            E-Commerce Platform
          </Typography>
        </Box>

        <Divider sx={{ mb: 3 }} />

        {/* Invoice Details */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 4 }}>
          <Box>
            <Typography variant="subtitle2" gutterBottom>
              Invoice Number:
            </Typography>
            <Typography variant="body1" gutterBottom fontWeight="bold">
              {invoice.invoiceNumber}
            </Typography>
            <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
              Customer:
            </Typography>
            <Typography variant="body1" fontWeight="bold">
              {invoice.customerName}
            </Typography>
          </Box>
          <Box sx={{ textAlign: 'right' }}>
            <Typography variant="subtitle2" gutterBottom>
              Invoice Date:
            </Typography>
            <Typography variant="body1" gutterBottom fontWeight="bold">
              {invoice.invoiceDate}
            </Typography>
            <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
              Order ID:
            </Typography>
            <Typography variant="body1" fontWeight="bold">
              #{invoice.orderId}
            </Typography>
          </Box>
        </Box>

        <Divider sx={{ mb: 3 }} />

        {/* Items Table */}
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>Item</strong></TableCell>
                <TableCell align="center"><strong>Qty</strong></TableCell>
                <TableCell align="right"><strong>Unit Price</strong></TableCell>
                <TableCell align="right"><strong>Subtotal</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {invoice.items.map((item, index) => (
                <TableRow key={index}>
                  <TableCell>{item.productName}</TableCell>
                  <TableCell align="center">{item.quantity}</TableCell>
                  <TableCell align="right">₹{item.unitPrice.toFixed(2)}</TableCell>
                  <TableCell align="right">₹{item.subtotal.toFixed(2)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>

        <Divider sx={{ my: 3 }} />

        {/* Totals */}
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 1 }}>
          <Box sx={{ display: 'flex', gap: 4, width: '300px', justifyContent: 'space-between' }}>
            <Typography variant="body1">Subtotal:</Typography>
            <Typography variant="body1">₹{invoice.subtotal.toFixed(2)}</Typography>
          </Box>
          <Box sx={{ display: 'flex', gap: 4, width: '300px', justifyContent: 'space-between' }}>
            <Typography variant="body1">GST ({invoice.taxRate}):</Typography>
            <Typography variant="body1">₹{invoice.tax.toFixed(2)}</Typography>
          </Box>
          <Divider sx={{ width: '300px', my: 1 }} />
          <Box sx={{ display: 'flex', gap: 4, width: '300px', justifyContent: 'space-between' }}>
            <Typography variant="h6" fontWeight="bold">Total Amount:</Typography>
            <Typography variant="h6" color="primary" fontWeight="bold">
              ₹{invoice.totalAmount.toFixed(2)}
            </Typography>
          </Box>
        </Box>

        <Box sx={{ mt: 4, pt: 3, borderTop: '1px dashed #ccc', textAlign: 'center' }}>
          <Typography variant="caption" color="text.secondary">
            Thank you for your business!
          </Typography>
          <Typography variant="caption" color="text.secondary" display="block" sx={{ mt: 1 }}>
            This is a computer-generated invoice and does not require a signature.
          </Typography>
        </Box>
      </Paper>
    </Container>
  );
};

export default InvoicePage;
