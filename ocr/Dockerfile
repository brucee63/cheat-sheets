# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Install Tesseract and any additional packages you need
RUN apt-get update && \
    apt-get install -y tesseract-ocr \
    libtesseract-dev \
    # Optional: add additional language packages, e.g. for German, French, etc.
    tesseract-ocr-eng \
    # (Add any more languages you need)
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the app
WORKDIR /usr/src/app

# Copy requirements first to leverage Docker cache
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY . .

# Expose the service port
EXPOSE 5000

# Run the Flask app
CMD [ "python", "app.py" ]