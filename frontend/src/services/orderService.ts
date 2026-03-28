import apiClient from './api';
import { Order, OrderCreateRequest, Invoice } from '../types/order.types';

export const orderService = {
  /**
   * Create new order
   */
  create: async (data: OrderCreateRequest): Promise<Order> => {
    const response = await apiClient.post<Order>('/orders', data);
    return response.data;
  },

  /**
   * Get order by ID
   */
  getById: async (id: number): Promise<Order> => {
    const response = await apiClient.get<Order>(`/orders/${id}`);
    return response.data;
  },

  /**
   * Get all orders (will be user-specific in future)
   */
  getUserOrders: async (): Promise<Order[]> => {
    // Note: In the future, backend should filter by logged-in user
    // For now, returns all orders
    const response = await apiClient.get<Order[]>('/orders');
    return response.data;
  },

  /**
   * Get invoice for an order
   */
  getInvoice: async (id: number): Promise<Invoice> => {
    const response = await apiClient.get<Invoice>(`/orders/${id}/invoice`);
    return response.data;
  },

  /**
   * Cancel an order
   */
  cancelOrder: async (id: number): Promise<Order> => {
    const response = await apiClient.put<Order>(`/orders/${id}/cancel`);
    return response.data;
  },
};

export default orderService;
