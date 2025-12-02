# Build from the official Apache HTTP Server image
FROM httpd:2.4

# Copy all content in web-content into the container filesystem in the default
# web content directory for httpd
# NOTE: This will only work if the Dockerfile is ran in the same directory as the web-content directory
COPY . /usr/local/apache2/htdocs/