# Stage 1: Build the application
FROM ubuntu as builder

# Install dependencies
RUN apt-get update && \
    apt-get install -y git curl

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Use nvm to install Node.js 8.9.4 and npm
RUN /bin/bash -c "source /root/.nvm/nvm.sh && nvm install 8.9.4 && nvm use 8.9.4 && npm install -g npm@6.14.11"

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and gulpfile.js
COPY package.json gulpfile.js /usr/src/app/

# Install npm packages
RUN /bin/bash -c "source /root/.nvm/nvm.sh && npm install -g bower gulp-cli && npm install"

# Remove PhantomJS references (if any)

# Copy the rest of the application
COPY . /usr/src/app

# Install bower dependencies
RUN /bin/bash -c "source /root/.nvm/nvm.sh && bower --allow-root install"

# Build the application
RUN /bin/bash -c "source /root/.nvm/nvm.sh && gulp build"

# Stage 2: Create the final image with Nginx
FROM nginx:1.19.3

# Copy the built application from the builder stage
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]