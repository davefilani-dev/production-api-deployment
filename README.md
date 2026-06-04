# Personal API Deployment with FastAPI, Nginx and AWS EC2

## Project Overview

This project was built as part of a DevOps-focused deployment challenge.

The objective was to build a lightweight API, deploy it to a Linux server, and expose it publicly through an Nginx reverse proxy. While the API itself is intentionally small, the focus of this project was understanding the deployment lifecycle from source code to a publicly accessible service.

Rather than exposing the application directly to the internet, the deployment follows a layered architecture:

- FastAPI handles application logic
- Uvicorn serves the application
- Nginx acts as a reverse proxy
- systemd manages the application process
- DuckDNS provides public DNS resolution
- AWS EC2 hosts the infrastructure
- Certbot and Let's Encrypt provide SSL/TLS encryption

---

## Live API

**Production URL**

```text
https://findave-api.duckdns.org
```

---

## Available Endpoints

### GET /

```json
{
  "message": "API is running"
}
```

### GET /health

```json
{
  "message": "healthy"
}
```

### GET /me

```json
{
  "name": "Oluwaseun Filani",
  "email": "ooluwaseunfilani@gmail.com",
  "github": "https://github.com/davefilani-dev"
}
```

---

## Architecture

```text
Client
   │
   ▼
DuckDNS
   │
   ▼
AWS EC2
   │
   ▼
Nginx Reverse Proxy
   │
   ▼
FastAPI (localhost:8000)
   │
   ▼
systemd Service
```

The FastAPI application listens only on localhost and is never directly exposed to the public internet.

All incoming traffic is received by Nginx on ports 80 and 443 and forwarded internally to FastAPI running on port 8000.

---

## Project Structure

```text
production-api-deployment/
│
├── app/
│   ├── __init__.py
│   ├── main.py
│   │
│   └── routes/
│       ├── __init__.py
│       └── api.py
│
├── tests/
│   ├── __init__.py
│   └── test_routes.py
│
├── deployment/
│   ├── nginx/
│   │   └── personal-api.conf
│   │
│   └── systemd/
│       └── personal-api.service
│
├── requirements.txt
├── pytest.ini
└── README.md
```

The `deployment` directory contains production configuration files that are copied into the operating system during deployment.

Keeping these files in source control makes the deployment reproducible and easier to maintain.

---

## Local Development

### Clone the Repository

```bash
git clone <repository-url>
cd production-api-deployment
```

### Create a Virtual Environment

```bash
python3 -m venv venv
```

### Activate the Environment

```bash
source venv/bin/activate
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Run the Application

```bash
uvicorn app.main:app --reload
```

The API will be available at:

```text
http://127.0.0.1:8000
```

---

## Testing

Pytest was used to validate endpoint behavior and application functionality.

Run tests using:

```bash
pytest -v
```

### Challenge Encountered

During development, pytest initially failed because Python could not properly resolve package imports.

The issue was resolved by:

- adding `__init__.py` files to Python package directories
- ensuring the application structure followed Python package conventions
- configuring pytest correctly

This reinforced the importance of Python package discovery and import resolution.

---

## Infrastructure Provisioning

The deployment server was provisioned using the AWS CLI rather than the AWS Management Console.

Provisioning included:

- EC2 instance creation
- Security Group configuration
- SSH key management
- Firewall rule configuration

### Security Group Rules

| Port | Purpose |
|--------|----------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 8000 | Internal Application Port |

Port `8000` remains inaccessible from the public internet and is only reachable from localhost through Nginx.

---

## Nginx Reverse Proxy

Nginx was configured to receive public traffic and forward requests to the FastAPI application.

Request flow:

```text
Browser
   │
   ▼
Nginx
   │
   ▼
127.0.0.1:8000
   │
   ▼
FastAPI
```

### Deployment Challenge Encountered

After removing the default Nginx site configuration, requests continued serving the Nginx welcome page.

The configuration itself was correct, but Nginx was still running with the previously loaded configuration.

The issue was resolved by restarting Nginx:

```bash
sudo systemctl restart nginx
```

This highlighted the difference between modifying configuration files on disk and reloading active runtime configuration.

---

## systemd Service Configuration

The FastAPI application is managed by systemd.

Benefits include:

- automatic startup after reboot
- automatic restart on failure
- background execution
- service lifecycle management

The service definition is maintained in:

```text
deployment/systemd/personal-api.service
```

and deployed to:

```text
/etc/systemd/system/
```

during server configuration.

---

## Logging and Monitoring

Operational visibility for the application is provided through systemd and Nginx logging.

These tools were used throughout deployment and troubleshooting to validate service health, diagnose reverse proxy issues, and verify incoming traffic.

### Application Logs

The FastAPI application runs as a systemd-managed service.

View logs:

```bash
sudo journalctl -u personal-api
```

Stream logs in real time:

```bash
sudo journalctl -u personal-api -f
```

These logs provide visibility into:

- application startup events
- runtime errors
- service restarts
- application output

---

### Nginx Access Logs

Incoming requests are recorded in:

```text
/var/log/nginx/access.log
```

View access logs:

```bash
sudo tail -f /var/log/nginx/access.log
```

These logs help verify:

- request routing
- endpoint activity
- response status codes
- client connections

---

### Nginx Error Logs

Reverse proxy and web server errors are recorded in:

```text
/var/log/nginx/error.log
```

View error logs:

```bash
sudo tail -f /var/log/nginx/error.log
```

These logs assist with troubleshooting:

- upstream connectivity issues
- configuration errors
- application availability problems

---

### Service Monitoring

Application health can be monitored through systemd:

```bash
sudo systemctl status personal-api
```

This provides visibility into:

- service status
- uptime
- restart history
- process state

The combination of systemd and Nginx logging provided sufficient operational monitoring for this project and was used extensively during deployment and debugging.

---

## DNS Configuration

DuckDNS was used to map a public hostname to the EC2 public IP address.

```text
findave-api.duckdns.org
```

This allows the application to be accessed through a stable hostname rather than a raw IP address.

---

## HTTPS Configuration

HTTPS is enabled using:

- Let's Encrypt
- Certbot

SSL certificates are terminated at the Nginx layer before requests are forwarded internally to FastAPI.

Certificate provisioning was completed using:

```bash
sudo certbot --nginx -d findave-api.duckdns.org
```

Certbot automatically:

- validated domain ownership
- issued SSL certificates
- updated Nginx configuration
- configured automatic certificate renewal

Public access is available through:

```text
https://findave-api.duckdns.org
```
## Deployment Workflow

### Development

Application development was performed locally, where the FastAPI application and tests were created and validated before deployment.

### Initial Deployment

The repository was cloned onto the EC2 instance after provisioning the server. Deployment-specific configurations, including Nginx reverse proxy settings and the systemd service definition, were created and configured directly on the server.

### Version Control

Once the deployment was fully configured and validated, the infrastructure-related changes were committed and pushed back to the GitHub repository to ensure the deployed environment remained represented in source control.

```bash
git add .
git commit -m "Add production deployment configuration"
git push origin main
```

This approach ensured that both application code and deployment configurations remained version-controlled and reproducible.

---

## Services can then be restarted if required:

```bash
sudo systemctl restart personal-api
sudo systemctl reload nginx
```

---

## Lessons Learned

This project provided hands-on experience with:

- FastAPI application deployment
- Linux server administration
- AWS EC2 provisioning
- Nginx reverse proxy configuration
- systemd service management
- DNS troubleshooting
- SSL certificate provisioning with Certbot
- HTTPS termination using Nginx
- Python package structure and import resolution
- Git-based deployment workflows
- Service monitoring with systemd
- Log analysis using journalctl
- Nginx access and error log troubleshooting
- Production debugging in a Linux environment

One of the most valuable lessons from this project was learning that successful deployments depend not only on application code, but also on understanding how infrastructure components communicate and interact with one another.

---

## Author

**Oluwaseun Filani**

GitHub: https://github.com/davefilani-dev

Email: your-ooluwaseunfilani@gmail.com
