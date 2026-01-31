import { paymentApi } from './api';

class PaymentService {
  async processPayment(paymentData) {
    try {
      const response = await paymentApi.post('/api/payments/process', paymentData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getPaymentMethods() {
    try {
      const response = await paymentApi.get('/api/payments/methods');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async addPaymentMethod(methodData) {
    try {
      const response = await paymentApi.post('/api/payments/methods', methodData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async deletePaymentMethod(id) {
    try {
      const response = await paymentApi.delete(`/api/payments/methods/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getPaymentHistory() {
    try {
      const response = await paymentApi.get('/api/payments/history');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async refundPayment(paymentId, amount) {
    try {
      const response = await paymentApi.post(`/api/payments/${paymentId}/refund`, {
        amount
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async verifyPayment(paymentId) {
    try {
      const response = await paymentApi.get(`/api/payments/${paymentId}/verify`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

export default new PaymentService();