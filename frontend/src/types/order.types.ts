export interface Order {
  id: number;
  customer: string;
  productId: number;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalAmount: number;
  status: 'CREATED' | 'PENDING' | 'COMPLETED' | 'CANCELLED';
  createdAt: string;
}

export interface OrderCreateRequest {
  customer: string;
  productId: number;
  quantity: number;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

import { Product } from './product.types';
