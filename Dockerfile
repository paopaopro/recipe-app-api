FROM python:3.9-alpine3.13
LABEL maintainer="paola"

# Set environment variables

# Ensures output is sent straight to terminal without buffering
ENV PYTHONUNBUFFERED 1 
# Prevents Python from writing .pyc files to disc
COPY ./requirements.txt /tmp/requirements.txt
# Development requirements 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Sets the working directory to /app
COPY ./app /app
# Sets the working directory to /app
WORKDIR /app
# Expose port 8000 for the application
EXPOSE 8000
# Build argument to determine if development dependencies should be installed 
ARG DEV=false

# Create a virtual environment and install dependencies
RUN python -m venv /py && \
    # Upgrade pip and install requirements
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-dev \
        build-base postgresql-dev musl-dev && \
    # Install dependencies from requirements.txt
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    # Clean up temporary files
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    # Create a non-root user
    adduser \
        # Create a system user without home directory and with no password
        --disabled-password \
        --no-create-home \
        django-user

# Update PATH environment variable
ENV PATH="/py/bin:$PATH"
# Switch to the new user
USER django-user
