import { orderApi } from './api';

class OrderService {
  async createOrder(orderData) {
    try {
      const response = await orderApi.post('', orderData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getMyOrders() {
    try {
      const response = await orderApi.get('/my-orders');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getOrderById(id) {
    try {
      const response = await orderApi.get(`/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getAllOrders(params = {}) {
    try {
      const response = await orderApi.get('', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async updateOrderStatus(id, status) {
    try {
      const response = await orderApi.patch(`/${id}/status`, {
        status
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async cancelOrder(id) {
    try {
      const response = await orderApi.patch(`/${id}/cancel`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getOrderStats() {
    try {
      const response = await orderApi.get('/stats');
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

const orderService = new OrderService();
export default orderService;
