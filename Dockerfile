# Get the Python image
FROM python:3.12-slim

# Set the folder inside the container where commands will run
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Refresh Debian packages so Trivy does not flag vulnerable base image libraries
RUN apt-get update && apt-get upgrade -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python packages inside the container
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your app's code into the container
COPY . .

# Expose the port that FastAPI runs on
EXPOSE 8000

# The command to start the API when the container boots up
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
