# emby-unlocker
In this repository including some unlocker tools for emby media server.

## How to use?

- First of all you must be use a script with compatible for your os.
- Follow the instruction on terminal.
- Configure `docker-compose.yml`. You can configurate only commented lines as you wish. Please don't touch the other lines.


## Run on Docker

Clone the repository

```bash
  git clone https://github.com/arg0WAK/emby-unlocker.git
```

Run any script with compatible your os.

```bash
  sudo sh emby_unlock_linux.sh
```

Run docker-compose.yml

```bash
  docker compose up -d
```

## Unlock Premiere for Devices with Some Restricted Certificate Path

Visit license verification at

```GET
 http://mb3admin.com/
 ```

Bypass the handshake error with `Proceed to mb3admin.com (unsafe)`

A JSON response like the following should be returned from the `GET` request

```JSON
 { "PROXY": "OK"}
```

You must be check specified outside port after docker build. If you see Emby Media Server wizard page complete the configuration also check Emby Premiere tab below Settings page.

If you sure everything is ok, you must see premiere information like below that:

![App Screenshot](https://arg0wak.github.io/gist/images/emby-unlocker/FII5MGK96G5C.png)

## Roadmap

-   ⌛ *OpenWRT* implementation for devices with some restricted certificate path.

_Enjoy it._
