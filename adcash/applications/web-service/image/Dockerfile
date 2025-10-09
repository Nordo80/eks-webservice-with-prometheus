FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy the Python script and requirements file into the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the Flask app port
EXPOSE 80

# Set environment variables
ENV FLASK_APP=app.py

# Run the Flask application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=80"]
