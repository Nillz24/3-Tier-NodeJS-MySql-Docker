# Use an alpine Node.js runtime as a parent image
FROM node:20-alpine

# Set the working directory in the container for the client
WORKDIR /usr/src/app/client

# Copy the client package.json and package-lock.json
COPY client/package*.json ./



RUN npm config set registry https://registry.npmjs.org/ \
 && npm config set fetch-retries 5 \
 && npm config set fetch-retry-maxtimeout 600000 \
 && npm config set fetch-timeout 600000 

# Install the client dependencies
RUN npm ci

# Copy the client source code
COPY client/ ./

# Fix permission (important)
RUN chmod -R +x node_modules/.bin

# Build the client application
RUN npm run build

# Set the working directory in the container for the server
WORKDIR /usr/src/app/server

# Copy the server package.json and package-lock.json
COPY server/package*.json ./

# Install the server dependencies
RUN npm ci

# Copy the server source code
COPY server/ ./

# Copy the client build files to the server's public directory
RUN mkdir -p ./public && cp -R /usr/src/app/client/dist/* ./public/

# Expose the port the server will run on
EXPOSE 5000
# Fix permission (important)
RUN chmod -R +x node_modules/.bin

# Command to run the server
CMD ["npm", "start"]

