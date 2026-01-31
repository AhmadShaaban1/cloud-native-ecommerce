import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Typography,
  Box,
  Button,
  Paper,
  Chip,
  Divider,
  TextField,
} from '@mui/material';
import { ShoppingCart, Add, Remove } from '@mui/icons-material';
import { useParams, useNavigate } from 'react-router-dom';
import Loading from '../components/Loading';
import productService from '../services/productService';
import { useCart } from '../context/CartContext';

const ProductDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { addToCart } = useCart();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);

  useEffect(() => {
    fetchProduct();
  }, [id]);

  const fetchProduct = async () => {
    try {
      setLoading(true);
      const response = await productService.getProductById(id);
      setProduct(response.product);
    } catch (error) {
      console.error('Error fetching product:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleQuantityChange = (delta) => {
    const newQuantity = quantity + delta;
    if (newQuantity >= 1 && newQuantity <= (product?.stock || 1)) {
      setQuantity(newQuantity);
    }
  };

  const handleAddToCart = () => {
    if (product) {
      addToCart(product, quantity);
      navigate('/cart');
    }
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(price);
  };

  if (loading) {
    return <Loading message="Loading product details..." />;
  }

  if (!product) {
    return (
      <Container sx={{ py: 8, textAlign: 'center' }}>
        <Typography variant="h5" gutterBottom>
          Product not found
        </Typography>
        <Button variant="contained" onClick={() => navigate('/products')}>
          Back to Products
        </Button>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Button onClick={() => navigate('/products')} sx={{ mb: 2 }}>
        ← Back to Products
      </Button>

      <Paper elevation={2} sx={{ p: 4 }}>
        <Grid container spacing={4}>
          <Grid item xs={12} md={6}>
            <Box
              component="img"
              src={product.image || 'https://via.placeholder.com/600x600?text=Product+Image'}
              alt={product.name}
              sx={{
                width: '100%',
                borderRadius: 2,
                boxShadow: 2,
              }}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <Typography variant="h4" gutterBottom>
              {product.name}
            </Typography>

            <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
              {product.category && (
                <Chip label={product.category} color="primary" />
              )}
              {product.stock > 0 ? (
                <Chip label="In Stock" color="success" />
              ) : (
                <Chip label="Out of Stock" color="error" />
              )}
            </Box>

            <Typography variant="h3" color="primary" gutterBottom>
              {formatPrice(product.price)}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Typography variant="h6" gutterBottom>
              Description
            </Typography>
            <Typography variant="body1" paragraph color="textSecondary">
              {product.description}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ mb: 3 }}>
              <Typography variant="body2" color="textSecondary" gutterBottom>
                SKU: {product.sku || 'N/A'}
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Available: {product.stock} units
              </Typography>
            </Box>

            {product.stock > 0 && (
              <>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
                  <Typography variant="body1">Quantity:</Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <Button
                      variant="outlined"
                      size="small"
                      onClick={() => handleQuantityChange(-1)}
                      disabled={quantity <= 1}
                    >
                      <Remove />
                    </Button>
                    <TextField
                      value={quantity}
                      inputProps={{
                        style: { textAlign: 'center' },
                        readOnly: true,
                      }}
                      sx={{ width: 60, mx: 1 }}
                    />
                    <Button
                      variant="outlined"
                      size="small"
                      onClick={() => handleQuantityChange(1)}
                      disabled={quantity >= product.stock}
                    >
                      <Add />
                    </Button>
                  </Box>
                </Box>

                <Button
                  variant="contained"
                  size="large"
                  fullWidth
                  startIcon={<ShoppingCart />}
                  onClick={handleAddToCart}
                >
                  Add to Cart
                </Button>
              </>
            )}

            {product.features && product.features.length > 0 && (
              <>
                <Divider sx={{ my: 3 }} />
                <Typography variant="h6" gutterBottom>
                  Features
                </Typography>
                <Box component="ul" sx={{ pl: 2 }}>
                  {product.features.map((feature, index) => (
                    <Typography component="li" key={index} variant="body2" paragraph>
                      {feature}
                    </Typography>
                  ))}
                </Box>
              </>
            )}
          </Grid>
        </Grid>
      </Paper>
    </Container>
  );
};

export default ProductDetail;