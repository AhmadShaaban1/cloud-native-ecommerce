import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Box,
  Grid,
  Button,
  Paper,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import ProductCard from '../components/ProductCard';
import Loading from '../components/Loading';
import productService from '../services/productService';
import { ShoppingBag, LocalShipping, Security, Support } from '@mui/icons-material';

const Home = () => {
  const navigate = useNavigate();
  const [featuredProducts, setFeaturedProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchFeaturedProducts();
  }, []);

  const fetchFeaturedProducts = async () => {
    try {
      setLoading(true);
      const response = await productService.getAllProducts({ limit: 8 });
      setFeaturedProducts(response.products || []);
    } catch (error) {
      console.error('Error fetching products:', error);
    } finally {
      setLoading(false);
    }
  };

  const features = [
    {
      icon: <ShoppingBag sx={{ fontSize: 60 }} />,
      title: 'Wide Selection',
      description: 'Browse thousands of products across multiple categories',
    },
    {
      icon: <LocalShipping sx={{ fontSize: 60 }} />,
      title: 'Fast Delivery',
      description: 'Get your orders delivered quickly and securely',
    },
    {
      icon: <Security sx={{ fontSize: 60 }} />,
      title: 'Secure Payment',
      description: 'Shop with confidence using our secure payment system',
    },
    {
      icon: <Support sx={{ fontSize: 60 }} />,
      title: '24/7 Support',
      description: 'Our customer support team is always here to help',
    },
  ];

  if (loading) {
    return <Loading message="Loading featured products..." />;
  }

  return (
    <>
      {/* Hero Section */}
      <Box
        sx={{
          bgcolor: 'primary.main',
          color: 'white',
          py: 12,
          mb: 6,
        }}
      >
        <Container maxWidth="lg">
          <Grid container spacing={4} alignItems="center">
            <Grid item xs={12} md={6}>
              <Typography variant="h2" gutterBottom>
                Welcome to CloudCommerce
              </Typography>
              <Typography variant="h5" paragraph>
                Your Cloud-Native E-Commerce Solution
              </Typography>
              <Typography variant="body1" paragraph>
                Built with cutting-edge microservices architecture on AWS EKS.
                Experience seamless shopping with enterprise-grade reliability.
              </Typography>
              <Box sx={{ mt: 4 }}>
                <Button
                  variant="contained"
                  size="large"
                  color="secondary"
                  onClick={() => navigate('/products')}
                  sx={{ mr: 2 }}
                >
                  Shop Now
                </Button>
                <Button
                  variant="outlined"
                  size="large"
                  sx={{ color: 'white', borderColor: 'white' }}
                  onClick={() => navigate('/products')}
                >
                  Browse Products
                </Button>
              </Box>
            </Grid>
            <Grid item xs={12} md={6}>
              <Box
                component="img"
                src="https://via.placeholder.com/600x400?text=E-Commerce+Platform"
                alt="Shopping"
                sx={{
                  width: '100%',
                  borderRadius: 2,
                  boxShadow: 3,
                }}
              />
            </Grid>
          </Grid>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" sx={{ mb: 8 }}>
        <Typography variant="h4" align="center" gutterBottom>
          Why Choose Us
        </Typography>
        <Typography variant="body1" align="center" color="textSecondary" paragraph>
          We provide the best shopping experience with modern technology
        </Typography>
        
        <Grid container spacing={4} sx={{ mt: 4 }}>
          {features.map((feature, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Paper
                elevation={2}
                sx={{
                  p: 3,
                  textAlign: 'center',
                  height: '100%',
                  transition: 'transform 0.2s',
                  '&:hover': {
                    transform: 'translateY(-4px)',
                    boxShadow: 4,
                  },
                }}
              >
                <Box sx={{ color: 'primary.main', mb: 2 }}>
                  {feature.icon}
                </Box>
                <Typography variant="h6" gutterBottom>
                  {feature.title}
                </Typography>
                <Typography variant="body2" color="textSecondary">
                  {feature.description}
                </Typography>
              </Paper>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Featured Products */}
      <Container maxWidth="lg" sx={{ mb: 8 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
          <Typography variant="h4">
            Featured Products
          </Typography>
          <Button
            variant="outlined"
            onClick={() => navigate('/products')}
          >
            View All
          </Button>
        </Box>

        <Grid container spacing={3}>
          {featuredProducts.map((product) => (
            <Grid item xs={12} sm={6} md={3} key={product._id}>
              <ProductCard product={product} />
            </Grid>
          ))}
        </Grid>

        {featuredProducts.length === 0 && (
          <Box sx={{ textAlign: 'center', py: 8 }}>
            <Typography variant="h6" color="textSecondary">
              No products available at the moment
            </Typography>
          </Box>
        )}
      </Container>

      {/* CTA Section */}
      <Box sx={{ bgcolor: 'grey.100', py: 8, mb: 0 }}>
        <Container maxWidth="md">
          <Typography variant="h4" align="center" gutterBottom>
            Ready to Start Shopping?
          </Typography>
          <Typography variant="body1" align="center" color="textSecondary" paragraph>
            Join thousands of satisfied customers and experience the future of e-commerce
          </Typography>
          <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, mt: 4 }}>
            <Button
              variant="contained"
              size="large"
              onClick={() => navigate('/register')}
            >
              Create Account
            </Button>
            <Button
              variant="outlined"
              size="large"
              onClick={() => navigate('/products')}
            >
              Browse Products
            </Button>
          </Box>
        </Container>
      </Box>
    </>
  );
};

export default Home;