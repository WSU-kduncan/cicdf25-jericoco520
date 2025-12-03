# cicdf25-jericoco520

## Part 1 Dockerfile and Building Images

The website I have set up is the same coffee history/process website I used for project 3.
[This is where the web-content is on GitHub](https://github.com/WSU-kduncan/cicdf25-jericoco520/tree/main/web-content)

The [DockerFile](https://github.com/WSU-kduncan/cicdf25-jericoco520/blob/main/web-content/Dockerfile) will build from the official Apache HTTP server image. Afterwards, it will copy the contents of our newly created web-content/ directory to the container's filesystem. Specifically into the default web content directory for httpd.

### Build Command

This command will:

1) Build for the `linux/amd64` platform
2) Tag the image as p4-coffee-website:1.0
3) Push to DockerHub

*Note*: Pushing to DockerHub requires one to be authenticated

```bash
docker buildx build --platform linux/amd64 \
-t jericoco520/p4-coffee-website:1.0 \
--push .
```

### Running the Container to Serve Web App

Prequisites:

1) Image exists
2) Docker Daemon running

If you currently don't have the image, pull it from DockerHub:

```bash
docker pull jericoco/p4-coffee-website
```

The Run command will:

1) Run in detached mode
2) Port maps the host port to 80 and the container port to 80 (E.G. `HostPort:ContainerPort` or `80:80`)
3) Names the container p4-coffee-website
4) Set the auto-restart policy to auto-restart unless manually stopped
5) Runs the image p4-coffee-website

```bash
docker run -d -p 80:80 --name p4-coffee-website --restart unless-stopped jericoco520/p4-coffee-website
```

Access the web app from a browser from the URL: `http://localhost:80`

## Part 2 GitHub Actions and DockerHub

**Task 1**: Configure Github Actions access to DockerHub repositories

1) Generate personal access token (PAT) in DockerHub
2) Configure the token with:
   1) Description
   2) Access permissions -> Read & Write (allow Github Actions to build and push images)
3) Copy the token and store as Github Actions secret

**Task 2**: Configure Github Action secret

1) Go to Github -> Settings -> Secrets and... -> Actions
2) Create `New Repository Secret`
3) Add the DOCKER_USERNAME=username and DOCKER_TOKEN=PAT secrets, respectively

**Task 3**: Setup Github Actions workflow

We want to be able to build and push container images to my DockerHub repo
