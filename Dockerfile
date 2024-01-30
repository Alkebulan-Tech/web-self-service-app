# Stage 1: Build the application
FROM ubuntu as builder

# Install dependencies
RUN apt-get update && \
    apt-get install -y git nodejs npm

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and gulpfile.js
COPY package.json gulpfile.js /usr/src/app/

# Install npm packages
RUN npm install -g bower gulp-cli && npm install

# Remove PhantomJS references (if any)

# Copy the rest of the application
COPY . /usr/src/app

# Install bower dependencies
RUN bower --allow-root install

# Build the application
RUN gulp build

# Stage 2: Create the final image with Nginx
FROM nginx:1.19.3

# Copy the built application from the builder stage
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]