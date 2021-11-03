# NGINX-docker-starter

![nginx - Omar Alsoudani](https://user-images.githubusercontent.com/7079173/134287388-9eba7276-c2e0-4ace-95b3-56486aa6dcd4.jpg)

[![Image published](https://github.com/omaralsoudanii/NGINX-docker-starter/actions/workflows/release.yaml/badge.svg)](https://github.com/omaralsoudanii/NGINX-docker-starter/actions/workflows/release.yaml)

This is a boilerplate NGINX configs using Docker, you can include it in your repo and add your server(s) config.

Dockerfile based on https://github.com/fholzer/docker-nginx-brotli 



## Usage

The docker image build is automatically triggered on new releases or tuning I make and published to **Docker Registry** and **GitHub Registry**  — this so you can run it fast instead of doing the whole build and compiling nginx from source, below is the links to both.

**GitHub Registry**: https://github.com/omaralsoudanii/NGINX-docker-starter/pkgs/container/nginx-docker-starter

**Docker Registry**: https://hub.docker.com/r/omaralsoudani/nginx-brotli

## Examples

- I added a working demo here, **make sure port 80**, or change it by removing `network_mode` in `docker-compose.yml` is not used and run the following:

  ```bash
  docker-compose up -d
  ```
  Then navigate to http://localhost — the files (just one file...) served from the public folder in the repository.

- Add the image to a Dockerfile in your build process — check `Dockerfile.demo` for reference.

- Add it in a docker compose file:

```yaml
  version: "3.6"
  services:
    mk-nginx:
        image: omaralsoudani/nginx-brotli
        container_name: mk-nginx
        restart: unless-stopped
        volumes:
          - /etc/ssl/mk/ecc.pem:/etc/nginx/ssl/ecc.pem:ro
          - /etc/ssl/mk/priv.key:/etc/nginx/ssl/priv.key:ro
          - /etc/ssl/mk/ca_root.pem:/etc/nginx/ssl/ca_root.pem:ro
          - /etc/ssl/mk/dh/dhparam.pem:/etc/nginx/ssl/dhparam.pem:ro
          # The below disables docker logging to stdout and uses file system (I like it with logrotate)
          - /var/log/nginx:/var/log/nginx 
        ports:
          - 80:80
          - 443:443
        networks:
          - mk_nginx

networks:
  mk_nginx:
```

- You could also check the configs and the docker setup that I use on my personal site [mkreg.dev](https://github.com/omaralsoudanii/mkreg.dev/tree/main/docker)

- You could ignore the published images and build it by your self using the [`Dockerfile`](https://github.com/omaralsoudanii/NGINX-docker-starter/blob/main/Dockerfile) (do it within the repo, since I am using NGINX signing key to verify the image), then read the [Integration](#how-to-integrate-in-my-project)

**Note**: Check the configration and read them, I documented most of the directives — some of them are only suitable for production, some are for proxy configration and the demo is static so I didn't use the caching or the proxy in the demo.

Remove comments from those when it suits you (production, or you have a server that you want nginx to be a proxy) — Also some needs a bit of research before enabling them (I added a warning for those).

## Why it's not synced with the original repo?

- The original repo main goal is setting up NGINX with brotli, my goal is to have a centralized repo where I can keep up with changes & tweaks I make for my own.

- In addition to adding new 3rd party modules ‑ at the time of writing I think I added `headers-more-nginx-module` and upgraded base Alpine image. Currently the final image size is **13.22MB**

- So I made this as a standalone repo rather than forcing the original author to add stuff that meets my needs.
## How to integrate in my project?

1. Assuming your project is containerized
2. You read the files and tweaked them based on your needs and server(s) hardware
3. Read the [Usage](#usage) and [Examples](#examples) section, understood how to utilize the already built image
4. At this point you pretty much only need to add it to your infrastructure
5. Here is some rambling about NGINX https://mkreg.dev/writing/nginx-treats
