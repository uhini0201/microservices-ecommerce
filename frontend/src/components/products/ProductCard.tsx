import React from 'react';
import {
  Card,
  CardContent,
  CardActions,
  Typography,
  Button,
  Box,
  Chip,
} from '@mui/material';
import {
  ShoppingCart as ShoppingCartIcon,
  Inventory as InventoryIcon,
} from '@mui/icons-material';
import { Product } from '../../types/product.types';
import { useCart } from '../../contexts/CartContext';
import { useAuth } from '../../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

interface ProductCardProps {
  product: Product;
}

const ProductCard: React.FC<ProductCardProps> = ({ product }) => {
  const { addToCart } = useCart();
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const handleAddToCart = () => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    addToCart(product, 1);
  };

  const isLowStock = product.stock < 10;
  const isOutOfStock = product.stock === 0;

  return (
    <Card 
      sx={{ 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column',
        transition: 'transform 0.2s, box-shadow 0.2s',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: 4,
        }
      }}
    >
      <CardContent sx={{ flexGrow: 1 }}>
        <Box sx={{ mb: 2 }}>
          <Typography variant="h6" component="h2" gutterBottom>
            {product.name}
          </Typography>
          {product.description && (
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              {product.description}
            </Typography>
          )}
        </Box>

        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <Typography variant="h5" color="primary" fontWeight="bold">
            ₹{product.price.toFixed(2)}
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
            <InventoryIcon fontSize="small" color="action" />
            <Typography variant="body2" color="text.secondary">
              {product.stock} in stock
            </Typography>
          </Box>
        </Box>

        {isOutOfStock && (
          <Chip label="Out of Stock" color="error" size="small" />
        )}
        {!isOutOfStock && isLowStock && (
          <Chip label="Low Stock" color="warning" size="small" />
        )}
      </CardContent>

      <CardActions sx={{ p: 2, pt: 0 }}>
        <Button
          fullWidth
          variant="contained"
          startIcon={<ShoppingCartIcon />}
          onClick={handleAddToCart}
          disabled={isOutOfStock}
        >
          {isOutOfStock ? 'Out of Stock' : 'Add to Cart'}
        </Button>
      </CardActions>
    </Card>
  );
};

export default ProductCard;
