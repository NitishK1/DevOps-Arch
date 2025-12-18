const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Mock database (in-memory for demo purposes)
const mockDB = {
    users: [],
    products: [
        { id: 1, name: 'Laptop', price: 999.99, stock: 50, category: 'Electronics' },
        { id: 2, name: 'Mouse', price: 29.99, stock: 200, category: 'Electronics' },
        { id: 3, name: 'Keyboard', price: 79.99, stock: 150, category: 'Electronics' },
        { id: 4, name: 'Monitor', price: 299.99, stock: 75, category: 'Electronics' },
        { id: 5, name: 'Desk Chair', price: 199.99, stock: 30, category: 'Furniture' }
    ],
    orders: [],
    cart: []
};

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development'
    });
});

// Authentication endpoints
app.post('/api/auth/register', (req, res) => {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    const existingUser = mockDB.users.find(u => u.email === email);
    if (existingUser) {
        return res.status(409).json({ error: 'User already exists' });
    }

    const newUser = {
        id: mockDB.users.length + 1,
        email,
        name,
        role: 'customer',
        createdAt: new Date().toISOString()
    };

    mockDB.users.push(newUser);

    res.status(201).json({
        message: 'User registered successfully',
        user: { id: newUser.id, email: newUser.email, name: newUser.name, role: newUser.role }
    });
});

app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = mockDB.users.find(u => u.email === email);
    if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
    }

    res.json({
        message: 'Login successful',
        token: 'mock-jwt-token-' + user.id,
        user: { id: user.id, email: user.email, name: user.name, role: user.role }
    });
});

// Product endpoints
app.get('/api/products', (req, res) => {
    const { category, search } = req.query;
    let products = [...mockDB.products];

    if (category) {
        products = products.filter(p => p.category === category);
    }

    if (search) {
        products = products.filter(p =>
            p.name.toLowerCase().includes(search.toLowerCase())
        );
    }

    res.json({ products, total: products.length });
});

app.get('/api/products/:id', (req, res) => {
    const product = mockDB.products.find(p => p.id === parseInt(req.params.id));

    if (!product) {
        return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ product });
});

// Order endpoints
app.post('/api/orders', (req, res) => {
    const { userId, items } = req.body;

    if (!userId || !items || !items.length) {
        return res.status(400).json({ error: 'Invalid order data' });
    }

    let total = 0;
    const orderItems = items.map(item => {
        const product = mockDB.products.find(p => p.id === item.productId);
        if (!product) {
            throw new Error('Product not found');
        }
        const itemTotal = product.price * item.quantity;
        total += itemTotal;
        return {
            productId: product.id,
            productName: product.name,
            quantity: item.quantity,
            price: product.price,
            subtotal: itemTotal
        };
    });

    const newOrder = {
        id: mockDB.orders.length + 1,
        userId,
        items: orderItems,
        total,
        status: 'Pending',
        createdAt: new Date().toISOString(),
        statusHistory: [
            { status: 'Pending', timestamp: new Date().toISOString() }
        ]
    };

    mockDB.orders.push(newOrder);

    res.status(201).json({
        message: 'Order created successfully',
        order: newOrder
    });
});

app.get('/api/orders', (req, res) => {
    const { userId } = req.query;

    let orders = [...mockDB.orders];

    if (userId) {
        orders = orders.filter(o => o.userId === parseInt(userId));
    }

    res.json({ orders, total: orders.length });
});

app.get('/api/orders/:id', (req, res) => {
    const order = mockDB.orders.find(o => o.id === parseInt(req.params.id));

    if (!order) {
        return res.status(404).json({ error: 'Order not found' });
    }

    res.json({ order });
});

// Admin endpoints
app.get('/api/admin/orders', (req, res) => {
    const { status, startDate, endDate } = req.query;
    let orders = [...mockDB.orders];

    if (status) {
        orders = orders.filter(o => o.status === status);
    }

    if (startDate) {
        orders = orders.filter(o => new Date(o.createdAt) >= new Date(startDate));
    }

    if (endDate) {
        orders = orders.filter(o => new Date(o.createdAt) <= new Date(endDate));
    }

    const stats = {
        total: orders.length,
        pending: orders.filter(o => o.status === 'Pending').length,
        processing: orders.filter(o => o.status === 'Processing').length,
        shipped: orders.filter(o => o.status === 'Shipped').length,
        delivered: orders.filter(o => o.status === 'Delivered').length,
        cancelled: orders.filter(o => o.status === 'Cancelled').length,
        totalRevenue: orders.reduce((sum, o) => sum + o.total, 0)
    };

    res.json({ orders, stats });
});

app.patch('/api/admin/orders/:id/status', (req, res) => {
    const { status, notes } = req.body;
    const order = mockDB.orders.find(o => o.id === parseInt(req.params.id));

    if (!order) {
        return res.status(404).json({ error: 'Order not found' });
    }

    order.status = status;
    order.statusHistory.push({
        status,
        notes,
        timestamp: new Date().toISOString()
    });

    res.json({
        message: 'Order status updated successfully',
        order
    });
});

app.get('/api/admin/dashboard', (req, res) => {
    const stats = {
        totalOrders: mockDB.orders.length,
        totalRevenue: mockDB.orders.reduce((sum, o) => sum + o.total, 0),
        totalProducts: mockDB.products.length,
        totalUsers: mockDB.users.length,
        pendingOrders: mockDB.orders.filter(o => o.status === 'Pending').length,
        lowStockProducts: mockDB.products.filter(p => p.stock < 50).length,
        recentOrders: mockDB.orders.slice(-10).reverse()
    };

    res.json({ dashboard: stats });
});

// Admin product management
app.post('/api/admin/products', (req, res) => {
    const { name, price, stock, category } = req.body;

    if (!name || !price || !category) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const newProduct = {
        id: mockDB.products.length + 1,
        name,
        price: parseFloat(price),
        stock: parseInt(stock) || 0,
        category,
        createdAt: new Date().toISOString()
    };

    mockDB.products.push(newProduct);

    res.status(201).json({
        message: 'Product created successfully',
        product: newProduct
    });
});

app.put('/api/admin/products/:id', (req, res) => {
    const product = mockDB.products.find(p => p.id === parseInt(req.params.id));

    if (!product) {
        return res.status(404).json({ error: 'Product not found' });
    }

    const { name, price, stock, category } = req.body;

    if (name) product.name = name;
    if (price) product.price = parseFloat(price);
    if (stock !== undefined) product.stock = parseInt(stock);
    if (category) product.category = category;
    product.updatedAt = new Date().toISOString();

    res.json({
        message: 'Product updated successfully',
        product
    });
});

// Serve frontend
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 ProjectX Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
