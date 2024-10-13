# Use the official Golang image
FROM golang:1.21

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files to the container
COPY go.mod go.sum ./

# Download Go modules
RUN go mod download

# Copy the rest of the application files to the container
COPY . .

# Install air (for hot-reloading)
RUN go install github.com/cosmtrek/air@v1.28.0

# Build the application
RUN go build -o silly-demo

# Expose the application's port
EXPOSE 8080

# Start air for hot-reloading
CMD ["air"]
