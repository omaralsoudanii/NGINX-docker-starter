# NGINX-docker-starter

This is a boilerplate NGINX configs using Docker, you can include it in your repo and add your server(s) config.

Dockerfile based on https://github.com/fholzer/docker-nginx-brotli 


## Usage

The docker image build is automatically triggered on new releases or tuning I make and published to **Docker Registry** and **GitHub Registry**  — this so you can run it fast instead of doing the whole build and compiling nginx from source, below is the links to both.

**GitHub Registry**: https://github.com/omaralsoudanii/NGINX-docker-starter/pkgs/container/nginx-docker-starter

**Docker Registry**: https://hub.docker.com/r/omaralsoudani/nginx-brotli

## Examples

- I added a working demo here, make sure port 80 is not used and run the following:
  ```bash
  docker-compose up -d
  ```
  Then navigate to http://localhost — the files served from the public folder in the repository.

- Add the image to a Dockerfile in your build process:
    
  ```docker
  # Start from the base image
  FROM omaralsoudani/nginx-brotli
  
  # copy my configs
  COPY ./nginx.conf /etc/nginx/nginx.conf
  COPY ./conf /etc/nginx/extras
  COPY ./conf.d /etc/nginx/conf.d
  
  # Run NGINX
  CMD ["nginx", "-g", "daemon off;"]
    ```

- Add it in a docker compose file:
  ```yaml
  version: "3.6"
  services:
    mk-nginx:
        image: omaralsoudani/nginx-brotli
        container_name: mk-nginx
        restart: unless-stopped
        volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf
        - ./conf:/etc/nginx/extras
        - ./conf.d:/etc/nginx/conf.d
        - ./public:/usr/share/nginx/html
        ports:
        - 80:80
        networks:
        - mk_nginx

  networks:
    mk_nginx:
  ```
- You could ignore the published images and build it by your self using the [`Dockerfile`](https://github.com/omaralsoudanii/NGINX-docker-starter/blob/main/Dockerfile) (do it within the repo, since I am using NGINX signing key to verify the image), then read the [Integration](#how-to-integrate-in-my-project)

**Note**: Check the configration and read them, I documented most of the directives — some of them are only suitable for production, some are for proxy configration and the demo is static so I didn't use the caching or the proxy in the demo.

Remove comments from those when it suits you (production, or you have a server that you want nginx to be a proxy). Also some are kinda needs a bit of research before enabling them (I added a warning for those), also watch out for the main `nginx.conf`, it is not in the `conf` directory it's outside in the root dir which is the main entry point for NGINX — this is because docker volume mapping overrides `/etc/nginx` if you just mount that to `conf`.

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
