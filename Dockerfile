# --------------------------
# Stage 1: Install dependencies (builder)
# --------------------------
    FROM node:20-alpine AS builder
    WORKDIR /app
    
    # copy package files first for better layer caching
    COPY package*.json ./
    
    # install production deps only (lighter)
    RUN npm ci --only=production
    
    # copy app source
    COPY . .
    
    # --------------------------
    # Stage 2: Runtime (final)
    # --------------------------
    FROM node:20-alpine
    WORKDIR /app
    
    # copy app from builder
    COPY --from=builder /app /app
    
    # create non-root user for security
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    USER appuser
    
    # expose port your app listens on
    EXPOSE 5006
    
    # run the app
    CMD ["npm", "start"]
    