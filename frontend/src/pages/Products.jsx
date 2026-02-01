import React, { useState, useEffect, useCallback } from 'react';
import {
  Container,
  Grid,
  Typography,
  Box,
  TextField,
  MenuItem,
  Pagination,
  Paper,
  InputAdornment,
} from '@mui/material';
import { Search as SearchIcon } from '@mui/icons-material';
import { useSearchParams } from 'react-router-dom';
import ProductCard from '../components/ProductCard';
import Loading from '../components/Loading';
import productService from '../services/productService';

const Products = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchQuery, setSearchQuery] = useState(searchParams.get('search') || '');
  const [category, setCategory] = useState(searchParams.get('category') || 'all');
  const [sortBy, setSortBy] = useState('newest');
  const [categories, setCategories] = useState([]);

  const itemsPerPage = 12;

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      const response = await productService.getCategories();
      setCategories(response.categories || []);
    } catch (error) {
      console.error('Error fetching categories:', error);
      setCategories([]);
    }
  };

  const fetchProducts = useCallback(async () => {
    try {
      setLoading(true);
      
      const params = {
        page,
        limit: itemsPerPage,
        sort: sortBy,
      };

      if (category && category !== 'all') {
        params.category = category;
      }

      const searchTerm = searchParams.get('search');
      if (searchTerm) {
        params.search = searchTerm;
      }

      const response = await productService.getAllProducts(params);
      setProducts(response.products || []);
      setTotalPages(response.totalPages || 1);
    } catch (error) {
      console.error('Error fetching products:', error);
      setProducts([]);
    } finally {
      setLoading(false);
    }
  }, [page, category, sortBy, searchParams]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  const handleSearch = (e) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      setSearchParams({ search: searchQuery });
      setPage(1);
    } else {
      setSearchParams({});
    }
  };

  const handleCategoryChange = (e) => {
    const newCategory = e.target.value;
    setCategory(newCategory);
    setPage(1);
    
    const params = {};
    if (newCategory !== 'all') {
      params.category = newCategory;
    }
    const searchTerm = searchParams.get('search');
    if (searchTerm) {
      params.search = searchTerm;
    }
    setSearchParams(params);
  };

  const handleSortChange = (e) => {
    setSortBy(e.target.value);
    setPage(1);
  };

  const handlePageChange = (event, value) => {
    setPage(value);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (loading && products.length === 0) {
    return <Loading message="Loading products..." />;
  }

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Typography variant="h4" gutterBottom>
        Products
      </Typography>

      {/* Filters */}
      <Paper elevation={1} sx={{ p: 3, mb: 4 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} md={6}>
            <form onSubmit={handleSearch}>
              <TextField
                fullWidth
                placeholder="Search products..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <SearchIcon />
                    </InputAdornment>
                  ),
                }}
              />
            </form>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <TextField
              select
              fullWidth
              label="Category"
              value={category}
              onChange={handleCategoryChange}
            >
              <MenuItem value="all">All Categories</MenuItem>
              {categories.map((cat) => (
                <MenuItem key={cat} value={cat}>
                  {cat}
                </MenuItem>
              ))}
            </TextField>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <TextField
              select
              fullWidth
              label="Sort By"
              value={sortBy}
              onChange={handleSortChange}
            >
              <MenuItem value="newest">Newest First</MenuItem>
              <MenuItem value="price-low">Price: Low to High</MenuItem>
              <MenuItem value="price-high">Price: High to Low</MenuItem>
              <MenuItem value="name">Name: A to Z</MenuItem>
            </TextField>
          </Grid>
        </Grid>
      </Paper>

      {/* Products Grid */}
      {loading ? (
        <Loading message="Loading products..." />
      ) : products.length > 0 ? (
        <>
          <Grid container spacing={3}>
            {products.map((product) => (
              <Grid item xs={12} sm={6} md={4} lg={3} key={product._id}>
                <ProductCard product={product} />
              </Grid>
            ))}
          </Grid>

          {/* Pagination */}
          {totalPages > 1 && (
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
              <Pagination
                count={totalPages}
                page={page}
                onChange={handlePageChange}
                color="primary"
                size="large"
              />
            </Box>
          )}
        </>
      ) : (
        <Box sx={{ textAlign: 'center', py: 8 }}>
          <Typography variant="h5" color="textSecondary" gutterBottom>
            No products found
          </Typography>
          <Typography variant="body1" color="textSecondary">
            Try adjusting your search or filter criteria
          </Typography>
        </Box>
      )}
    </Container>
  );
};

export default Products;
