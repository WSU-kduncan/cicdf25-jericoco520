# Project 5 - CEG3120 - Jerico Corneja

## Continuous Delivery Project Overview

### Diagram

### Goal **TODO**

---

## Part 1 - Script & Refresh

### EC2 Instance Details

#### AMI Information

| Property | Value |
|----------|-------|
| AMI ID | `ami-0f9de6e2d2f067fca` |
| OS | Ubuntu Server 24.04 LTS |
| Architecture | x86_64 (HVM) |
| Region | us-east-1 |
| Default Username | `ubuntu` |

#### Instance Type

| Property | Value |
|----------|-------|
| Instance Type | `t2.medium` |
| vCPUs | 2 |
| Memory | 4 GB RAM |

The `t2.medium` instance type provides sufficient CPU and memory resources for running Docker containers and the webhook listener service.

#### Recommended Volume Size

| Property | Value |
|----------|-------|
| Volume Size | 30 GB |
| Volume Type | gp3 |
| Delete on Termination | true |

Per the Project 5 instructions recommendations, 30 GB provides adequate storage for the Ubuntu OS, Docker images, container layers, and application logs.

#### Security Group Configuration

| Rule | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| SSH | TCP | 22 | `74.129.134.252/32` | SSH access from home IP |
| SSH | TCP | 22 | `130.108.0.0/16` | SSH access from WSU campus |
| HTTP | TCP | 80 | `0.0.0.0/0` | Web application access |
| Webhook | TCP | 9000 | `0.0.0.0/0` | Webhook listener for CD pipeline |

#### Security Group Justification

- **SSH (Port 22)**: Restricted to my home IP and WSU campus CIDR range. This prevents unauthorized SSH access from the public internet while allowing me to connect from trusted locations.

- **HTTP (Port 80)**: Open to everyone (`0.0.0.0/0`) because the web application running in the Docker container needs to be publicly accessible for testing and demonstration.

- **Webhook (Port 9000)**: Open to everyone because GitHub/DockerHub needs to send HTTP POST requests to trigger the container refresh script. The `adnanh/webhook` service listens on this port by default.

#### User Data

- **Docker Installation**: Installs Docker
- **Set Hostname**: Sets hostname to `CORNEJA-P5-Ubuntu`

### Docker Setup

Docker installation is handled by the UserData script in `CORNEJA-ec2-cf-yml`

```bash
curl -fsSL https://get.docker.com -o get-docker.sh && \
          sh get-docker.sh && \
          usermod -aG docker ubuntu && \
          systemctl enable docker && \
          systemctl start docker && \
```

Confirm Docker installation and hostname changes were successful with:
(I would run them separately as is more than a couple of lines of output)

```bash
sudo systemctl status docker --no-pager && \
docker --version && \
hostname && \
sudo tail -30 /var/log/cloud-init-output.log
```

### Pulling and Running Containers

```bash
# To pull a container image from DockerHub repo
docker pull {username}/{imageName}:{version}

# To create and run a new container from an image
docker run {imageName}

# To create and run a new container from an image in the background
docker run -d \                               # -d flag runs in the background
    --name "${CONTAINER_NAME}" \              # Name the container 
    --restart unless-stopped \                # Set restart policy
    -p "${HOST_PORT}:${CONTAINER_PORT}" \     # Port map host port to container port
    "${IMAGE}"                                # The image to run
```

### Deploy Script

**Script:** [deployment/deploy.sh](https://github.com/WSU-kduncan/ceg3120f25-jericoco520/blob/main/Projects/Project5/deployment/deploy.sh)

#### Description

The `deploy.sh` script automates the container refresh process for the CD pipeline. It performs the following steps in order:

| Step | Action | Description |
|------|--------|-------------|
| 1 | Stop Container | Stops the running container if it exists |
| 2 | Remove Container | Removes the old container to free the name |
| 3 | Pull Image | Pulls the `latest` tagged image from DockerHub |
| 4 | Run Container | Starts a new container with `-d` (detached) and `--restart unless-stopped` flags |

I added to the script configurable variables at the top for easy customization: (I keep forgetting Host and Container ports...)

- `DOCKERHUB_USER` - DockerHub username
- `IMAGE_NAME` - Name of the image
- `CONTAINER_NAME` - Name for the running container
- `HOST_PORT` / `CONTAINER_PORT` - Port mapping

#### Testing & Verification

To test the script works correctly:

1. **Run the script:**
   ```bash
   ./deploy.sh
   ```

2. **Verify container is running:**
   ```bash
   docker ps
   ```
   Expected: Container `p4-coffee-website` should be listed with status "Up ..."

3. **Verify the web application is accessible:**
   ```bash
   curl http://localhost:80
   ```
   You can also visit `http://localhost:80` or `http://<EC2_PUBLIC_IP>` in a browser

4. **Check container logs:**
   ```bash
   docker logs p4-coffee-website
   ```

### Resources

- [AWS CloudFormation EC2 Configuration](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-ec2-instance-config.html#scenario-ec2-bdm) - Used heavily for configuring EC2 Instance in a Cloudformation template
- [Sample EC2 CF Template](https://github.com/aws-cloudformation/aws-cloudformation-templates/blob/main/EC2/EC2InstanceWithSecurityGroupSample.yaml) - This was a great starting point provided by the AWS CloudFormation Team repo
- [My Project 2 Cloud Formation Template](https://github.com/WSU-kduncan/ceg3120f25-jericoco520/blob/main/Projects/Project2/Corneja-CF.yml) - Borrowed from my previous UserData scripts and general sanity checks when configuring new EC2 cf template
- Based on what I setup in `CORNEJA-ec2-cf.yml` I asked Claude to format tables for the EC2 overview (I like the tables for clarity but they are time consuming to hand make :/)
- [How to Evaluate Exit Codes In Bash](https://linuxsimply.com/bash-scripting-tutorial/process-and-signal-handling/exit-codes/check-exit-code/)
- [Best Practice Deploying EC2 Instances with CloudFormation](https://aws.amazon.com/blogs/infrastructure-and-automation/best-practices-for-deploying-ec2-instances-with-aws-cloudformation/)

---

## Part 2 - Listen

### Installing Webhook

```bash
sudo apt-get install webhook
```

Install adnanh's webhook to the EC2 instance using the command above

### Creating a Webhook Configuration File

You may create the configuration file using `JSON` or `YML`

```json
// Sample JSON webhook configuration file
[
  {
    "id": "redeploy-webhook",
    "execute-command": "/var/scripts/redeploy.sh",
    "command-working-directory": "/var/webhook"
  }
]
```

```yml
# Sample of YML webhook configuration file
- id: redeploy-webhook
  execute-command: "/var/scripts/redeploy.sh"
  command-working-directory: "/var/webhook"
```

I chose to go with validating using the DockerHub payload in the configuration file:

```yml
# Deploy hook for project 5 coffee website
- id: "deploy-coffee-website"
  execute-command: "/home/ubuntu/deploy.sh"
  command-working-directory: "/home/ubuntu"
  response-message: "Deployment triggered successfully"
  trigger-rule:
    # Validate DockerHub payload matches the repository name
    match:
      type: "value"
      value: "jericoco520/p4-coffee-website"    
      parameter:
        source: "payload"
        name: "repository.repo_name"
    # Validate DockerHub payload matches the tag
    match:
      type: "value"
      parameter:
        source: "payload"
        name: "push_data.tag"
```


### Resources

- [adnanh's webhook github page](https://github.com/adnanh/webhook)
- [Hook Definitions](https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md)

---

## Part 3 - Send a Payload

---


