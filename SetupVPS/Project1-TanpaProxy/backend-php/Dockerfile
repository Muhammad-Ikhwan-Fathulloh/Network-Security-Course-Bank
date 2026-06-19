FROM php:8.2-apache

# Aktifkan mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy semua file
COPY . /var/www/html/

# Atur izin
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Konfigurasi Apache untuk mengizinkan .htaccess
RUN echo '<Directory /var/www/html/>' >> /etc/apache2/apache2.conf && \
    echo '    Options Indexes FollowSymLinks' >> /etc/apache2/apache2.conf && \
    echo '    AllowOverride All' >> /etc/apache2/apache2.conf && \
    echo '    Require all granted' >> /etc/apache2/apache2.conf && \
    echo '</Directory>' >> /etc/apache2/apache2.conf

EXPOSE 80