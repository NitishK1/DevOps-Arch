# Use official PHP 7.4 with Apache
FROM php:7.4-apache

# Set maintainer label
LABEL maintainer="applebite@example.com"
LABEL description="AppleBite PHP Application"

# Install required extensions
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy application files to the container
COPY app/ /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start Apache in foreground (inherited from php:7.4-apache base image)
CMD ["apache2-foreground"]
