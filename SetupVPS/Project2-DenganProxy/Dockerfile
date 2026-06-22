FROM php:8.2-apache

# Install SQLite extensions
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update php.ini
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

# Copy Frontend to Root
COPY frontend-js/ .

# Copy Backend to /api/
COPY backend-php/ api/

# Database setup
RUN mkdir -p /var/www/html/database \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/database

# Global AllowOverride
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Add .htaccess inside api/ directory for better routing
RUN echo "RewriteEngine On\n\
RewriteBase /api/\n\
CGIPassAuth On\n\
RewriteCond %{REQUEST_FILENAME} !-f\n\
RewriteCond %{REQUEST_FILENAME} !-d\n\
RewriteRule ^(.*)$ index.php [QSA,L]" > /var/www/html/api/.htaccess

EXPOSE 80

CMD ["apache2-foreground"]
