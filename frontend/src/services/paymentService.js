import { paymentApi } from './api';

class PaymentService {
  async processPayment(paymentData) {
    try {
      const response = await paymentApi.post('/process', paymentData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getPaymentMethods() {
    try {
      const response = await paymentApi.get('/methods');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async addPaymentMethod(methodData) {
    try {
      const response = await paymentApi.post('/methods', methodData);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async deletePaymentMethod(id) {
    try {
      const response = await paymentApi.delete(`/methods/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async getPaymentHistory() {
    try {
      const response = await paymentApi.get('/history');
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async refundPayment(paymentId, amount) {
    try {
      const response = await paymentApi.post(`/${paymentId}/refund`, {
        amount
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

  async verifyPayment(paymentId) {
    try {
      const response = await paymentApi.get(`/${paymentId}/verify`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }
}

const paymentService = new PaymentService();
export default paymentService;
