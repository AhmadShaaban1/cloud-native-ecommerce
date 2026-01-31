import axios from 'axios';
import { toast } from 'react-toastify';


// Base URLs from environment variables
const USER_SERVICE_URL = process.env.REACT_APP_USER_SERVICE_URL || '/api/auth';
const PRODUCT_SERVICE_URL = process.env.REACT_APP_PRODUCT_SERVICE_URL || '/api/products';
const ORDER_SERVICE_URL = process.env.REACT_APP_ORDER_SERVICE_URL || '/api/orders';
const PAYMENT_SERVICE_URL = process.env.REACT_APP_PAYMENT_SERVICE_URL || '/api/payments';

// Create axios instances for each service
const createApiClient = (baseURL) => {
  const client = axios.create({
    baseURL,
    headers: {
      'Content-Type': 'application/json',
    },
    timeout: 10000,
  });

  // Request interceptor
  client.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor
  client.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response) {
        const { status, data } = error.response;
        
        switch (status) {
          case 401:
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            toast.error('Session expired. Please login again.');
            window.location.href = '/login';
            break;
          case 403:
            toast.error('Access denied. Insufficient permissions.');
            break;
          case 404:
            toast.error('Resource not found.');
            break;
          case 500:
            toast.error('Server error. Please try again later.');
            break;
          default:
            toast.error(data?.message || 'An error occurred.');
        }
      } else if (error.request) {
        toast.error('Network error. Please check your connection.');
      } else {
        toast.error('An unexpected error occurred.');
      }
      
      return Promise.reject(error);
    }
  );

  return client;
};

export const userApi = createApiClient(USER_SERVICE_URL);
export const productApi = createApiClient(PRODUCT_SERVICE_URL);
export const orderApi = createApiClient(ORDER_SERVICE_URL);
export const paymentApi = createApiClient(PAYMENT_SERVICE_URL);

export const healthCheck = async () => {
  try {
    const [user, product, order, payment] = await Promise.allSettled([
      userApi.get('/health'),
      productApi.get('/health'),
      orderApi.get('/health'),
      paymentApi.get('/health'),
    ]);

    return {
      user: user.status === 'fulfilled',
      product: product.status === 'fulfilled',
      order: order.status === 'fulfilled',
      payment: payment.status === 'fulfilled',
    };
  } catch (error) {
    console.error('Health check failed:', error);
    return {
      user: false,
      product: false,
      order: false,
      payment: false,
    };
  }
};

export default {
  userApi,
  productApi,
  orderApi,
  paymentApi,
  healthCheck,
};