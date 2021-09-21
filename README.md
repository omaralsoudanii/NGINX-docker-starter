# NGINX-docker-starter

This is a boilerplate NGINX configs using Docker, you can include it in your repo and add your server(s) config.

Dockerfile based on https://github.com/fholzer/docker-nginx-brotli 

## Why it's not synced with the original repo?

- The original repo main goal is setting up NGINX with brotli, my goal is to have a centralized repo where I can keep up with changes & tweaks I make for my own.

- In addition to adding new 3rd party modules ‑ at the time of writing I think I added `headers-more-nginx-module` and upgraded base Alpine image. Currently the final image size is **13.22MB**

- So I made this as a standalone repo rather than forcing the original author to add stuff that meets my needs.
## How to integrate in my project?

1. Assuming your project is containerized
2. You read the files and tweaked them based on your needs and server(s) hardware
3. Add the Dockerfile with the rest of your infrastructure configs
4. You don't need a volume for the configs, check the last lines of the `Dockerfile`, I am copying them directly into the container. Doesn't work with you? remove it and mount/bind the configs just like you do for your other services
5. While this thing is building and you get an error, open a ticket
6. While you can use it, you need to dive in the licensing stuff (this is why I am not adding one)
7. Here is some rambling about NGINX https://mkreg.dev/writing/nginx-treats



## Introduction

This is a boilerplate NGINX configs using Docker, you can include it in your repo and add your server(s) config.

Dockerfile based on https://github.com/fholzer/docker-nginx-brotli 

## Why it's not synced with the original repo?

- The original repo main goal is setting up NGINX with brotli, my goal is to have a centralized repo where I can keep up with changes & tweaks I make for my own.

- In addition to adding new 3rd party modules ‑ at the time of writing I think I added `headers-more-nginx-module` and upgraded base Alpine image. Currently the final image size is **13.22MB**

- So I made this as a standalone repo rather than forcing the original author to add stuff that meets my needs.

## How to integrate in my project?

1. Assuming your project is containerized
2. You read the files and tweaked them based on your needs and server(s) hardware
3. Add the Dockerfile with the rest of your infrastructure configs
4. You don't need a volume for the configs, check the last lines of the `Dockerfile`, I am copying them directly into the container. Doesn't work with you? remove it and mount/bind the configs just like you do for your other services
5. While this thing is building and you get an error, open a ticket
6. Here is some rambling about NGINX https://mkreg.dev/writing/nginx-treats