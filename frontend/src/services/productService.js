import { productApi } from './api';

class ProductService {
  async getAllProducts(params = {}) {
    try {
      const response = await productApi.get('/api/products', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getProductById(id) {
    try {
      const response = await productApi.get(`/api/products/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async searchProducts(query) {
    try {
      const response = await productApi.get('/api/products/search', {
        params: { q: query }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getProductsByCategory(category) {
    try {
      const response = await productApi.get('/api/products/category', {
        params: { category }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async createProduct(productData) {
    try {
      const response = await productApi.post('/api/products', productData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateProduct(id, productData) {
    try {
      const response = await productApi.put(`/api/products/${id}`, productData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async deleteProduct(id) {
    try {
      const response = await productApi.delete(`/api/products/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateStock(id, quantity) {
    try {
      const response = await productApi.patch(`/api/products/${id}/stock`, {
        quantity
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getCategories() {
    try {
      const response = await productApi.get('/api/products/categories');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getFeaturedProducts() {
    try {
      const response = await productApi.get('/api/products/featured');
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

export default new ProductService();