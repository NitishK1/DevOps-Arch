const request = require('supertest');
const app = require('../server');

describe('ProjectX API Tests', () => {

    describe('Health Check', () => {
        it('should return healthy status', async () => {
            const response = await request(app)
                .get('/api/health')
                .expect(200);

            expect(response.body.status).toBe('healthy');
            expect(response.body).toHaveProperty('timestamp');
            expect(response.body).toHaveProperty('version');
        });
    });

    describe('Authentication', () => {
        it('should register a new user', async () => {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    email: 'test@example.com',
                    password: 'password123',
                    name: 'Test User'
                })
                .expect(201);

            expect(response.body.message).toBe('User registered successfully');
            expect(response.body.user).toHaveProperty('id');
            expect(response.body.user.email).toBe('test@example.com');
        });

        it('should not register user with missing fields', async () => {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    email: 'test@example.com'
                })
                .expect(400);

            expect(response.body).toHaveProperty('error');
        });
    });

    describe('Products', () => {
        it('should get all products', async () => {
            const response = await request(app)
                .get('/api/products')
                .expect(200);

            expect(response.body).toHaveProperty('products');
            expect(response.body.products).toBeInstanceOf(Array);
            expect(response.body.products.length).toBeGreaterThan(0);
        });

        it('should get a specific product', async () => {
            const response = await request(app)
                .get('/api/products/1')
                .expect(200);

            expect(response.body).toHaveProperty('product');
            expect(response.body.product).toHaveProperty('id');
            expect(response.body.product).toHaveProperty('name');
            expect(response.body.product).toHaveProperty('price');
        });

        it('should return 404 for non-existent product', async () => {
            await request(app)
                .get('/api/products/9999')
                .expect(404);
        });

        it('should filter products by category', async () => {
            const response = await request(app)
                .get('/api/products?category=Electronics')
                .expect(200);

            expect(response.body.products).toBeInstanceOf(Array);
            response.body.products.forEach(product => {
                expect(product.category).toBe('Electronics');
            });
        });
    });

    describe('Orders', () => {
        it('should create a new order', async () => {
            const response = await request(app)
                .post('/api/orders')
                .send({
                    userId: 1,
                    items: [
                        { productId: 1, quantity: 2 },
                        { productId: 2, quantity: 1 }
                    ]
                })
                .expect(201);

            expect(response.body.message).toBe('Order created successfully');
            expect(response.body.order).toHaveProperty('id');
            expect(response.body.order).toHaveProperty('total');
            expect(response.body.order.status).toBe('Pending');
        });

        it('should not create order with missing data', async () => {
            await request(app)
                .post('/api/orders')
                .send({
                    userId: 1
                })
                .expect(400);
        });

        it('should get all orders', async () => {
            const response = await request(app)
                .get('/api/orders')
                .expect(200);

            expect(response.body).toHaveProperty('orders');
            expect(response.body.orders).toBeInstanceOf(Array);
        });
    });

    describe('Admin Endpoints', () => {
        it('should get admin dashboard stats', async () => {
            const response = await request(app)
                .get('/api/admin/dashboard')
                .expect(200);

            expect(response.body).toHaveProperty('dashboard');
            expect(response.body.dashboard).toHaveProperty('totalOrders');
            expect(response.body.dashboard).toHaveProperty('totalRevenue');
            expect(response.body.dashboard).toHaveProperty('totalProducts');
        });

        it('should create a new product', async () => {
            const response = await request(app)
                .post('/api/admin/products')
                .send({
                    name: 'Test Product',
                    price: 99.99,
                    stock: 10,
                    category: 'Test'
                })
                .expect(201);

            expect(response.body.message).toBe('Product created successfully');
            expect(response.body.product).toHaveProperty('id');
            expect(response.body.product.name).toBe('Test Product');
        });

        it('should update order status', async () => {
            // First create an order
            const createResponse = await request(app)
                .post('/api/orders')
                .send({
                    userId: 1,
                    items: [{ productId: 1, quantity: 1 }]
                });

            const orderId = createResponse.body.order.id;

            // Then update its status
            const response = await request(app)
                .patch(`/api/admin/orders/${orderId}/status`)
                .send({
                    status: 'Processing',
                    notes: 'Order is being processed'
                })
                .expect(200);

            expect(response.body.order.status).toBe('Processing');
            expect(response.body.order.statusHistory).toBeInstanceOf(Array);
        });
    });
});
