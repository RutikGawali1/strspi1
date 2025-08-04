# Use official Node.js image
FROM node:22-alpine

<<<<<<< HEAD
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
=======
# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install 

# Copy the rest of the application code
COPY . .

# Build the Strapi admin panel
>>>>>>> f4a04ae (Implemented Blue/Green deployment strategy)
RUN npm run build

# Expose the default Strapi port
EXPOSE 1337

<<<<<<< HEAD
# Start the app
CMD ["npm", "start"]
=======
# Start the Strapi app
CMD ["npm", "run", "start"]
>>>>>>> f4a04ae (Implemented Blue/Green deployment strategy)
