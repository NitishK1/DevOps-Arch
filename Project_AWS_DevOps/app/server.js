const express = require('express');
const os = require('os');
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        hostname: os.hostname(),
        region: process.env.AWS_REGION || 'unknown'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logicworks DevOps - Multi-Region Deployment</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.2em;
        }
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .info-card h3 {
            color: #333;
            margin-bottom: 15px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: bold;
            color: #555;
        }
        .value {
            color: #667eea;
            font-family: monospace;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            background: #28a745;
            color: white;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .features {
            margin-top: 30px;
        }
        .features ul {
            list-style: none;
            padding-left: 0;
        }
        .features li {
            padding: 10px 0;
            padding-left: 30px;
            position: relative;
        }
        .features li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #28a745;
            font-weight: bold;
            font-size: 1.5em;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Logicworks DevOps</h1>
        <p class="subtitle">AWS Multi-Region Deployment</p>

        <div class="info-card">
            <h3>Deployment Information</h3>
            <div class="info-row">
                <span class="label">Status:</span>
                <span class="status-badge">RUNNING</span>
            </div>
            <div class="info-row">
                <span class="label">Container:</span>
                <span class="value">${os.hostname()}</span>
            </div>
            <div class="info-row">
                <span class="label">Region:</span>
                <span class="value">${process.env.AWS_REGION || 'Not set'}</span>
            </div>
            <div class="info-row">
                <span class="label">Environment:</span>
                <span class="value">${process.env.ENVIRONMENT || 'production'}</span>
            </div>
            <div class="info-row">
                <span class="label">Timestamp:</span>
                <span class="value">${new Date().toISOString()}</span>
            </div>
            <div class="info-row">
                <span class="label">Uptime:</span>
                <span class="value">${Math.floor(process.uptime())} seconds</span>
            </div>
        </div>

        <div class="features">
            <h3>✨ Infrastructure Features</h3>
            <ul>
                <li>Multi-region deployment (us-east-1 & us-west-2)</li>
                <li>Container orchestration with ECS Fargate</li>
                <li>Automated CI/CD pipeline with manual approval</li>
                <li>Docker images stored in ECR</li>
                <li>High availability across multiple AZs</li>
                <li>CloudWatch monitoring and alerting</li>
                <li>Infrastructure as Code with Terraform</li>
            </ul>
        </div>

        <div class="footer">
            <p>Powered by AWS ECS Fargate | Built with ❤️ by DevOps Team</p>
            <p style="margin-top: 10px;">
                <a href="/health" style="color: #667eea; text-decoration: none;">Health Check</a> |
                <a href="/api/info" style="color: #667eea; text-decoration: none;">API Info</a>
            </p>
        </div>
    </div>
</body>
</html>
  `;
    res.send(html);
});

// API info endpoint
app.get('/api/info', (req, res) => {
    res.json({
        application: 'Logicworks DevOps App',
        version: '1.0.0',
        hostname: os.hostname(),
        platform: os.platform(),
        architecture: os.arch(),
        nodeVersion: process.version,
        uptime: process.uptime(),
        memory: {
            total: os.totalmem(),
            free: os.freemem(),
            used: os.totalmem() - os.freemem()
        },
        cpus: os.cpus().length,
        environment: {
            region: process.env.AWS_REGION || 'not set',
            environment: process.env.ENVIRONMENT || 'production',
            port: PORT
        },
        timestamp: new Date().toISOString()
    });
});

// Readiness endpoint (for ALB health checks)
app.get('/ready', (req, res) => {
    res.status(200).send('OK');
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Cannot ${req.method} ${req.url}`,
        timestamp: new Date().toISOString()
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: err.message,
        timestamp: new Date().toISOString()
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`
╔═══════════════════════════════════════════════════════════════╗
║                   Logicworks DevOps App                       ║
║                                                                 ║
║  Server running on port ${PORT}                                ║
║  Region: ${process.env.AWS_REGION || 'Not set'}               ║
║  Environment: ${process.env.ENVIRONMENT || 'production'}       ║
║  Hostname: ${os.hostname()}                                    ║
║                                                                 ║
║  Endpoints:                                                     ║
║    GET  /           - Main page                                ║
║    GET  /health     - Health check                             ║
║    GET  /ready      - Readiness check                          ║
║    GET  /api/info   - System information                       ║
╚═══════════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    process.exit(0);
});

module.exports = app;
