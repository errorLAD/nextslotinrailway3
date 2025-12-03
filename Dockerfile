# Koyeb Dockerfile for Django Application
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Set work directory
WORKDIR /app

# Install system dependencies for psycopg2 and Pillow
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Collect static files (with dummy database to avoid DB connection during build)
ENV DATABASE_URL=sqlite:///tmp.db
ENV SECRET_KEY=build-time-secret-key
RUN python manage.py collectstatic --noinput --clear
ENV DATABASE_URL=
ENV SECRET_KEY=

# Expose port
EXPOSE 8000

# Run the application
CMD python manage.py migrate && gunicorn booking_saas.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --threads 4 --timeout 120
