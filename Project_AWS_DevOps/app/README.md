# Logicworks DevOps Application

A sample Node.js application demonstrating containerized deployment on AWS ECS
with multi-region architecture.

## Features

- Express.js web server
- Health check endpoints
- System information API
- Docker containerized
- Production-ready configuration

## Local Development

### Prerequisites
- Node.js 18+
- Docker (optional)

### Run Locally
```bash
# Install dependencies
npm install

# Start server
npm start

# Development mode with auto-reload
npm run dev
```

Access the application at http://localhost:8080

### Run with Docker
```bash
# Build image
docker build -t logicworks-app .

# Run container
docker run -p 8080:8080 -e AWS_REGION=us-east-1 logicworks-app
```

## API Endpoints

- `GET /` - Main application page
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness probe
- `GET /api/info` - System information

## Environment Variables

- `PORT` - Server port (default: 8080)
- `AWS_REGION` - AWS region (for display)
- `ENVIRONMENT` - Environment name (production/staging)

## Testing

```bash
npm test
```

## Docker Image

The Docker image uses multi-stage builds for optimization:
- Base: Node.js 18 Alpine
- Non-root user for security
- Health checks included
- Production dependencies only

## Deployment

This application is deployed automatically via AWS CodePipeline to ECS Fargate
across multiple regions.

## License

MIT
