FROM node:18

WORKDIR /app

# Copy package.json and package-lock.json if available
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your source code
COPY . .

CMD ["npm", "start"]

