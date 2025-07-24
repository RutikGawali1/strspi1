# Use official Node.js image
FROM node:22-alpine

# Create app directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Install better-sqlite3 for SQLite support
RUN npm install better-sqlite3 --save

# Copy rest of the application
COPY . .

# Build admin panel (if not built yet)
RUN npm run build

# Expose the default Strapi port
EXPOSE 1337

# Start the app
CMD ["npm", "start"]
