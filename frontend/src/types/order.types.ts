import { Product } from './product.types';

export interface OrderItem {
  id?: number;
  orderId?: number;
  productId: number;
  productName: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
}

export interface Order {
  id: number;
  customer: string;
  totalAmount: number;
  status: 'CREATED' | 'PENDING' | 'COMPLETED' | 'CANCELLED';
  createdAt: string;
  items: OrderItem[];
  itemCount: number;
  currency: string;
}

export interface Invoice {
  invoiceNumber: string;
  invoiceDate: string;
  customerName: string;
  orderId: number;
  orderStatus: string;
  items: InvoiceItem[];
  subtotal: number;
  tax: number;
  totalAmount: number;
  currency: string;
  taxRate: string;
}

export interface InvoiceItem {
  productName: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
}

export interface OrderItemRequest {
  productId: number;
  quantity: number;
}

export interface OrderCreateRequest {
  customer: string;
  items: OrderItemRequest[];
}

export interface CartItem {
  product: Product;
  quantity: number;
}

