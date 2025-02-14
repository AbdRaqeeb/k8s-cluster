# Use Node.js official image
FROM node:22.14.0-alpine3.20

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./

RUN npm install

# Copy the rest of the app
COPY . .

# Expose port and run the app
EXPOSE 3000

CMD ["node", "server.js"]
