FROM php:8.1-apache

# Maintainer information
LABEL maintainer="DevOps Team"
LABEL description="Company Website - Drupal-based Application"

# Enable Apache modules required for Drupal
RUN a2enmod rewrite headers expires

# Install additional PHP extensions that might be needed
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/lib/apt/lists/*

# Copy website code into container
# Note: For production with volumes, this serves as the default content
# COPY ["dockerContent/Case-study app/", "/var/www/html/"]

# Set correct permissions for Drupal-like PHP app
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Create a volume mount point for persistent data
VOLUME /var/www/html

# Expose web port
EXPOSE 80

# Health check to ensure Apache is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start Apache in foreground
CMD ["apache2-foreground"]
