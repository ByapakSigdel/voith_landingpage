FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY . .

# Ensure uploads directory exists
RUN mkdir -p uploads/images

EXPOSE 5000

# Run migrations then start the server
COPY scripts/wait-for-db.js ./scripts/wait-for-db.js

CMD ["sh", "-c", "node ./scripts/wait-for-db.js && npm run migrate && npm start"]
