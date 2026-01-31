import React from 'react';
import { Box, Container, Grid, Typography, Link, IconButton } from '@mui/material';
import { GitHub, LinkedIn, Twitter } from '@mui/icons-material';

const Footer = () => {
  return (
    <Box
      component="footer"
      sx={{
        bgcolor: 'primary.main',
        color: 'white',
        py: 6,
        mt: 'auto',
      }}
    >
      <Container maxWidth="lg">
        <Grid container spacing={4}>
          <Grid item xs={12} sm={4}>
            <Typography variant="h6" gutterBottom>
              CloudCommerce
            </Typography>
            <Typography variant="body2">
              Your trusted cloud-native e-commerce platform built with modern microservices architecture.
            </Typography>
          </Grid>
          
          <Grid item xs={12} sm={4}>
            <Typography variant="h6" gutterBottom>
              Quick Links
            </Typography>
            <Link href="/" color="inherit" display="block" sx={{ mb: 1 }}>
              Home
            </Link>
            <Link href="/products" color="inherit" display="block" sx={{ mb: 1 }}>
              Products
            </Link>
            <Link href="/cart" color="inherit" display="block" sx={{ mb: 1 }}>
              Cart
            </Link>
            <Link href="/orders" color="inherit" display="block">
              Orders
            </Link>
          </Grid>
          
          <Grid item xs={12} sm={4}>
            <Typography variant="h6" gutterBottom>
              Connect With Us
            </Typography>
            <Box>
              <IconButton color="inherit" aria-label="GitHub">
                <GitHub />
              </IconButton>
              <IconButton color="inherit" aria-label="LinkedIn">
                <LinkedIn />
              </IconButton>
              <IconButton color="inherit" aria-label="Twitter">
                <Twitter />
              </IconButton>
            </Box>
          </Grid>
        </Grid>
        
        <Box mt={5}>
          <Typography variant="body2" align="center">
            © {new Date().getFullYear()} CloudCommerce. Built with ❤️ using AWS EKS, Kubernetes & React.
          </Typography>
        </Box>
      </Container>
    </Box>
  );
};

export default Footer;