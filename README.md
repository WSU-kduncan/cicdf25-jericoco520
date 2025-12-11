# CI/CD Pipeline Project - CEG3120 - Jerico Corneja

This repository demonstrates a complete CI/CD pipeline for deploying a containerized web application using GitHub Actions, DockerHub, and an EC2 instance with webhook-based automated deployments.

## Project Documentation

| Document | Description |
|----------|-------------|
| [README-CI.md](README-CI.md) | Continuous Integration - Automated Docker image builds with GitHub Actions |
| [README-CD.md](README-CD.md) | Continuous Delivery - Webhook-triggered container deployments on EC2 |

## Pipeline Overview

1. **CI**: Push code to GitHub → GitHub Actions builds and pushes Docker image to DockerHub
2. **CD**: DockerHub sends webhook → EC2 listener triggers deploy script → Container refreshes automatically
