import { productApi } from './api';

class ProductService {
  async getAllProducts(params = {}) {
    try {
      const response = await productApi.get('', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getProductById(id) {
    try {
      const response = await productApi.get(`/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async searchProducts(query) {
    try {
      const response = await productApi.get('/search', {
        params: { q: query }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getProductsByCategory(category) {
    try {
      const response = await productApi.get('/category', {
        params: { category }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async createProduct(productData) {
    try {
      const response = await productApi.post('', productData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateProduct(id, productData) {
    try {
      const response = await productApi.put(`/${id}`, productData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async deleteProduct(id) {
    try {
      const response = await productApi.delete(`/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateStock(id, quantity) {
    try {
      const response = await productApi.patch(`/${id}/stock`, {
        quantity
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getCategories() {
    try {
      const response = await productApi.get('/categories');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getFeaturedProducts() {
    try {
      const response = await productApi.get('/featured');
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

const productService = new ProductService();
export default productService;
