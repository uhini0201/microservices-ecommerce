import apiClient from './api';
import { Product, ProductCreateRequest } from '../types/product.types';

export const productService = {
  /**
   * Get all products
   */
  getAll: async (): Promise<Product[]> => {
    const response = await apiClient.get<Product[]>('/products');
    return response.data;
  },

  /**
   * Get product by ID
   */
  getById: async (id: number): Promise<Product> => {
    const response = await apiClient.get<Product>(`/products/${id}`);
    return response.data;
  },

  /**
   * Create new product (admin only)
   */
  create: async (data: ProductCreateRequest): Promise<Product> => {
    const response = await apiClient.post<Product>('/products', data);
    return response.data;
  },

  /**
   * Update product (admin only)
   */
  update: async (id: number, data: Partial<ProductCreateRequest>): Promise<Product> => {
    const response = await apiClient.put<Product>(`/products/${id}`, data);
    return response.data;
  },

  /**
   * Delete product (admin only)
   */
  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/products/${id}`);
  },
};

export default productService;
