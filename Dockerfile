# Use an official lightweight base image, such as Alpine
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the compiled executable and any other needed files from your host machine to the container
copy .build/release/microservice Sources/MicroService/specs.csv .

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the microservice when the container launches
CMD ["./microservice"]
