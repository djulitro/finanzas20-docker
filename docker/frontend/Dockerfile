FROM node:18-alpine

# Set working directory
WORKDIR /app

# Add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Install app dependencies
COPY package*.json ./
RUN npm ci --silent
RUN npm install react-scripts@5.0.1 -g --silent

# Copy app files
COPY . ./

# Start app
CMD ["npm", "start"]