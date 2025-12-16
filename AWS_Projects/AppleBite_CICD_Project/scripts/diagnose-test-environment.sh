#!/bin/bash
# Diagnostic script to check AppleBite Test deployment

echo "======================================"
echo "AppleBite Test Environment Diagnostics"
echo "======================================"
echo ""

# Check if containers are running
echo "1. Checking Docker containers..."
docker ps --filter "name=applebite-test" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Check container logs
echo "2. Checking web container logs (last 30 lines)..."
docker logs --tail 30 applebite-test-web 2>&1 || echo "Container not found or not running"
echo ""

# Check if port 8080 is accessible
echo "3. Testing port 8080..."
curl -v http://127.0.0.1:8080 2>&1 | head -20
echo ""

# Check files inside container
echo "4. Checking files inside web container..."
docker exec applebite-test-web ls -la /var/www/html 2>&1 || echo "Cannot access container"
echo ""

# Check Apache configuration
echo "5. Checking Apache configuration..."
docker exec applebite-test-web cat /etc/apache2/sites-enabled/000-default.conf 2>&1 || echo "Cannot access container"
echo ""

# Check Apache error logs
echo "6. Checking Apache error logs..."
docker exec applebite-test-web tail -20 /var/log/apache2/error.log 2>&1 || echo "Cannot access logs"
echo ""

# Check file permissions
echo "7. Checking file permissions in container..."
docker exec applebite-test-web ls -l /var/www/html/index.php 2>&1 || echo "index.php not found"
echo ""

# Test health check endpoint
echo "8. Testing health check..."
docker exec applebite-test-web curl -f http://localhost/ 2>&1 || echo "Health check failed"
echo ""

echo "======================================"
echo "Diagnostics Complete"
echo "======================================"
