# lazydocker-web

Run [`lazydocker`](https://github.com/jesseduffield/lazydocker) inside a container and access it from your browser via [`ttyd`](https://github.com/tsl0922/ttyd) (a web terminal).

This image is meant for people who want LazyDocker available anywhere without installing it on the host, while still managing the host Docker daemon by mounting the Docker socket.

## What You Get

- LazyDocker UI in your browser (served by ttyd)
- Works with the host Docker daemon via `/var/run/docker.sock`
- A default `config.yml` baked into the image (you can override it at runtime)

## Quick Start (Docker)

Pull the image:

```bash
docker pull YOUR_DOCKERHUB_USER/lazydocker-web:latest
```

Run it:

```bash
docker run -d \
  --name lazydocker \
  --restart unless-stopped \
  -p 7681:7681 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  YOUR_DOCKERHUB_USER/lazydocker-web:latest
```

Then open:

- `http://localhost:7681`

Replace `YOUR_DOCKERHUB_USER/lazydocker-web:latest` with your image name (and tag) if you published it under a different repo/tag.

### Change the Port

```bash
docker run -d \
  --name lazydocker \
  --restart unless-stopped \
  -p 8080:7681 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  YOUR_DOCKERHUB_USER/lazydocker-web:latest
```

## Using Your Own LazyDocker Config

The image includes a default config at:

- `/root/.config/lazydocker/config.yml`

To override it, bind-mount your own file to that path:

```bash
docker run -d \
  --name lazydocker \
  --restart unless-stopped \
  -p 7681:7681 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ./config.yml:/root/.config/lazydocker/config.yml \
  YOUR_DOCKERHUB_USER/lazydocker-web:latest
```

Tip: if your host supports it, mount it read-only by adding `:ro` at the end of the config volume.

## Docker Compose

If you're using this repo, you can run:

```bash
docker compose up -d
```

The included `docker-compose.yaml` mounts the Docker socket. The `config.yml` mount is optional (uncomment it only if you want to override the baked-in default config).

## Security Notes (Important)

- Mounting `/var/run/docker.sock` gives this container effectively full control over the host (equivalent to root on many setups). Only run this image on machines you trust.
- Consider restricting access to the published port (for example, bind to `127.0.0.1` or put it behind auth/reverse-proxy) if you are on a shared network.

## Troubleshooting

- If the UI loads but shows no containers, the Docker socket mount is missing or Docker is not running on the host.
- If you use rootless Docker, you may need to mount your rootless socket path instead of `/var/run/docker.sock` (path varies by distro/user).
