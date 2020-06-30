FROM golang:alpine as builder

LABEL maintainer="GoScrum"

# Install git.
RUN apk update && apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download 

COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Start a new stage from scratch
FROM golang:alpine
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage. Observe we also copied the .env file
COPY --from=builder /app/main .
COPY --from=builder /app/.env .       

# Expose port 8080 to the outside world
EXPOSE 8080

#Command to run the executable
CMD ["./main"]