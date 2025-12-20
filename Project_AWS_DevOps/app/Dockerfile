# Stage 1: Build
# Using Amazon ECR Public Gallery to avoid Docker Hub rate limits
FROM public.ecr.aws/docker/library/node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Stage 2: Runtime
# Using Amazon ECR Public Gallery to avoid Docker Hub rate limits
FROM public.ecr.aws/docker/library/node:18-alpine

# Add metadata
LABEL maintainer="DevOps Team"
LABEL description="Logicworks AWS DevOps Multi-Region Application"
LABEL version="1.0.0"

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application files
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "server.js"]
