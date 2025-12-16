# AppleBite PHP Application Docker Image
# Multi-stage build for optimized image size

FROM php:7.4-apache as base

LABEL maintainer="AppleBite DevOps Team"
LABEL description="AppleBite PHP Application Container"
LABEL version="1.0"

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Production stage
FROM base as production

# Copy application files from the website subdirectory
COPY ./app/website/ /var/www/html/

# Set permissions for application files
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Run as www-data user for security
USER www-data

# Start Apache
CMD ["apache2-foreground"]

# Development stage (with debugging tools)
FROM base as development

# Install additional dev dependencies
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install Xdebug (compatible version for PHP 7.4)
RUN pecl install xdebug-3.1.6 \
    && docker-php-ext-enable xdebug

# Copy application files from the website subdirectory
COPY ./app/website/ /var/www/html/

# Set permissions - allow directory listing for development
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configure Apache for development - allow directory index
RUN echo '<Directory /var/www/html/>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>' > /etc/apache2/conf-available/dev-directory.conf \
    && a2enconf dev-directory

EXPOSE 80

# Health check for development
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start Apache in foreground
CMD ["apache2-foreground"]
