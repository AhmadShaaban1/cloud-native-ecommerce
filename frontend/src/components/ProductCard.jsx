import React from 'react';
import {
  Card,
  CardMedia,
  CardContent,
  CardActions,
  Typography,
  Button,
  Chip,
  Box,
  IconButton,
} from '@mui/material';
import { ShoppingCart, Favorite, Visibility } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';

const ProductCard = ({ product }) => {
  const navigate = useNavigate();
  const { addToCart, isInCart } = useCart();

  const handleAddToCart = (e) => {
    e.stopPropagation();
    addToCart(product);
  };

  const handleViewDetails = () => {
    navigate(`/products/${product._id}`);
  };

  const formatPrice = (price) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(price);
  };

  return (
    <Card
      sx={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        cursor: 'pointer',
        transition: 'transform 0.2s, box-shadow 0.2s',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: 6,
        },
      }}
      onClick={handleViewDetails}
    >
      <CardMedia
        component="img"
        height="200"
        image={product.image || 'https://via.placeholder.com/300x200?text=Product+Image'}
        alt={product.name}
        sx={{ objectFit: 'cover' }}
      />
      
      <CardContent sx={{ flexGrow: 1 }}>
        <Typography gutterBottom variant="h6" component="div" noWrap>
          {product.name}
        </Typography>
        
        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
          {product.description?.substring(0, 80)}
          {product.description?.length > 80 ? '...' : ''}
        </Typography>
        
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
          <Typography variant="h6" color="primary">
            {formatPrice(product.price)}
          </Typography>
          {product.discount && (
            <Chip
              label={`-${product.discount}%`}
              color="error"
              size="small"
            />
          )}
        </Box>
        
        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
          {product.category && (
            <Chip label={product.category} size="small" variant="outlined" />
          )}
          {product.stock > 0 ? (
            <Chip label="In Stock" size="small" color="success" variant="outlined" />
          ) : (
            <Chip label="Out of Stock" size="small" color="error" variant="outlined" />
          )}
        </Box>
      </CardContent>
      
      <CardActions sx={{ justifyContent: 'space-between', px: 2, pb: 2 }}>
        <Box>
          <IconButton size="small" aria-label="add to favorites">
            <Favorite />
          </IconButton>
          <IconButton size="small" aria-label="view details">
            <Visibility />
          </IconButton>
        </Box>
        
        <Button
          variant="contained"
          startIcon={<ShoppingCart />}
          onClick={handleAddToCart}
          disabled={product.stock === 0}
          size="small"
        >
          {isInCart(product._id) ? 'Added' : 'Add to Cart'}
        </Button>
      </CardActions>
    </Card>
  );
};

export default ProductCard;