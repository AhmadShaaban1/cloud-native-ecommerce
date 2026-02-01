import { orderApi } from './api';

class OrderService {
  async createOrder(orderData) {
    try {
      const response = await orderApi.post('/api/orders', orderData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getMyOrders() {
    try {
      const response = await orderApi.get('/api/orders/my-orders');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getOrderById(id) {
    try {
      const response = await orderApi.get(`/api/orders/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getAllOrders(params = {}) {
    try {
      const response = await orderApi.get('/api/orders', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateOrderStatus(id, status) {
    try {
      const response = await orderApi.patch(`/api/orders/${id}/status`, {
        status
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async cancelOrder(id) {
    try {
      const response = await orderApi.patch(`/api/orders/${id}/cancel`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getOrderStats() {
    try {
      const response = await orderApi.get('/api/orders/stats');
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

const orderService = new OrderService();
export default orderService;
