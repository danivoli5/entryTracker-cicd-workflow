# Python Application CI/CD Workflow

This document describes the automated workflow for building, testing, tagging, and deploying a Python Flask application to an AWS EC2 instance using GitHub Actions, Docker, and Amazon ECR.

---

## Key Features
The application is a 3-tier architecture, orchestrated by Docker Compose, include:

- Nginx: Acting as a reverse proxy to handle incoming requests.

- Python: Flask server running as the application layer.
- MySQL: Functioning as the database backend.

### 1. Build and Test
- **Python Environment**: Installs Python 3.10 and application dependencies (`flask`, `pymysql`).
- **Run the App**: Starts the Flask application directly (without Docker) to ensure functionality.
- **Docker Build and Test**:
  - Builds the Docker image using the `docker-compose.yaml` configuration.
  - Runs the application in Docker Compose and validates it using `curl` to confirm proper functionality.
- **Versioning**: Applies semantic version tags (`major`, `minor`, `patch`) using the `git_update.sh` script.
- **Push to Amazon ECR**: Tags and pushes the validated Docker image to Amazon Elastic Container Registry (ECR) for deployment.


### 2. Deployment
The deployment process is managed by the **deploy** job in the GitHub Actions workflow. Key steps include:

- **SSH into EC2 and Deploy**:
   - Connects to the EC2 instance via SSH.
   - Executes the `deploy.sh` script stored on the instance to restart services using the latest Docker image.
   - Exports required environment variables (e.g., database credentials and image tag).

- **Validate Deployment**:
   - Confirms the application is running by sending a `curl` request to the EC2 instance's public address.

The application is hosted at **[http://ec2-13-234-122-242.ap-south-1.compute.amazonaws.com/](http://ec2-13-234-122-242.ap-south-1.compute.amazonaws.com/)**.

---

## Environment Variables

Sensitive values are securely stored in **GitHub Secrets** and loaded during the workflow. These include:
- **Database**: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- **AWS Configuration**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ECR_REGISTRY`, `ECR_REPOSITORY`

---
## Supporting Scripts

1. **`deploy.sh`**:
   - Handles the deployment process on the EC2 instance.
   - Logs into Amazon ECR
   - Stops and restarts the Docker services using `docker-compose` with the latest tagged image.

2. **`user-data.sh`**:
   - A bootstrap script executed only once when the EC2 instance is created.
   - Installs essential tools like Docker and AWS CLI.

3. **`git_update.sh`**:
   - Implements semantic versioning for tagging Docker images.
   - Automatically determines the next version based on the specified update type (`major`, `minor`, `patch`).
   - Pushes the new tags to the Git repository, ensuring consistent version tracking.

## Version In Json Payload

The Flask application has been adjusted to include a version field in the API response, dynamically sourced from the Docker image tag (IMAGE_TAG). This feature provides clear identification of deployments and their associated versions.

Example API response:

```json
{
  "version": "1.2.3",
  "message": "Data fetched successfully from the database.",
  "current_entry": {
    "hostname": "example-host",
    "ip_address": "127.0.0.1",
    "timestamp": "2025-01-10 15:30:00"
  },
  "previous_entries": [...]
}


