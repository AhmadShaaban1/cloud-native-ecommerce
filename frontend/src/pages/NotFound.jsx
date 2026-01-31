import React from 'react';
import { Container, Typography, Button, Box } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { Error as ErrorIcon } from '@mui/icons-material';

const NotFound = () => {
  const navigate = useNavigate();

  return (
    <Container sx={{ py: 8, textAlign: 'center' }}>
      <ErrorIcon sx={{ fontSize: 100, color: 'text.secondary', mb: 2 }} />
      <Typography variant="h1" gutterBottom>
        404
      </Typography>
      <Typography variant="h5" gutterBottom>
        Page Not Found
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        The page you're looking for doesn't exist or has been moved.
      </Typography>
      <Box sx={{ mt: 4 }}>
        <Button variant="contained" onClick={() => navigate('/')} sx={{ mr: 2 }}>
          Go Home
        </Button>
        <Button variant="outlined" onClick={() => navigate('/products')}>
          Browse Products
        </Button>
      </Box>
    </Container>
  );
};

export default NotFound;