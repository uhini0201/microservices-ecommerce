import React, { useEffect, useState } from 'react';
import {
  Container,
  Grid,
  Typography,
  Box,
  TextField,
  InputAdornment,
  CircularProgress,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  SelectChangeEvent,
} from '@mui/material';
import { Search as SearchIcon } from '@mui/icons-material';
import { productService } from '../../services/productService';
import { Product } from '../../types/product.types';
import ProductCard from './ProductCard';

const ProductList: React.FC = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState<string>('name');

  useEffect(() => {
    loadProducts();
  }, []);

  useEffect(() => {
    filterAndSortProducts();
  }, [products, searchTerm, sortBy]);

  const loadProducts = async () => {
    try {
      setLoading(true);
      const data = await productService.getAll();
      setProducts(data);
      setError('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to load products. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const filterAndSortProducts = () => {
    let filtered = [...products];

    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(
        (product) =>
          product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          product.description?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Sort products
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'price-asc':
          return a.price - b.price;
        case 'price-desc':
          return b.price - a.price;
        case 'stock':
          return b.stock - a.stock;
        default:
          return 0;
      }
    });

    setFilteredProducts(filtered);
  };

  const handleSortChange = (event: SelectChangeEvent) => {
    setSortBy(event.target.value);
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Products
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Box sx={{ mb: 4, display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        <TextField
          placeholder="Search products..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          sx={{ flexGrow: 1, minWidth: 250 }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
        />

        <FormControl sx={{ minWidth: 200 }}>
          <InputLabel id="sort-label">Sort By</InputLabel>
          <Select
            labelId="sort-label"
            label="Sort By"
            value={sortBy}
            onChange={handleSortChange}
          >
            <MenuItem value="name">Name (A-Z)</MenuItem>
            <MenuItem value="price-asc">Price (Low to High)</MenuItem>
            <MenuItem value="price-desc">Price (High to Low)</MenuItem>
            <MenuItem value="stock">Stock (High to Low)</MenuItem>
          </Select>
        </FormControl>
      </Box>

      {filteredProducts.length === 0 ? (
        <Box textAlign="center" py={8}>
          <Typography variant="h6" color="text.secondary">
            {searchTerm ? 'No products found matching your search.' : 'No products available.'}
          </Typography>
        </Box>
      ) : (
        <Grid container spacing={3}>
          {filteredProducts.map((product) => (
            <Grid item xs={12} sm={6} md={4} key={product.id}>
              <ProductCard product={product} />
            </Grid>
          ))}
        </Grid>
      )}

      <Box sx={{ mt: 4, textAlign: 'center' }}>
        <Typography variant="body2" color="text.secondary">
          Showing {filteredProducts.length} of {products.length} products
        </Typography>
      </Box>
    </Container>
  );
};

export default ProductList;
