# Информация для разработки

## Входные данные

- github page **y2k.github.io**
- пушить в **github.com/y2k/y2k.github.io**
- пример сайта для сборки **github.com/y2k/tag-game**
  - docker image **y2khub/tag-game**

### Технологии

- ocaml
- git
- docker
- suave

## Поток событий

- docker webhook
  - repository
- git clone / git pull
- docker run
- move `<result-build>` to `<site dir>`
- git commit / git push

## Команда докера на билд

`docker run --rm -v $PWD/build_result:/build_result y2khub/tag_game`

## Пример Dockerfile

```Dockerfile
FROM node:20-bullseye AS build

WORKDIR /app

COPY --from=y2khub/clj2js /app/clj2js .

COPY src/ src
# COPY test/ test
COPY .github/ .github

RUN export PATH=$PATH:/app && cd .github && make

RUN ls -la .github/bin

FROM scratch

COPY --from=build /app/.github/bin /build_result

CMD [ "" ]
```

## Пример конфига

```edn
{"tag-game"
 {:repo "y2k/tag-game"
  :docker "Dockerfile"}
 "sync"
 {:repo "y2k/sync-server"
  :docker "Web.Dockerfile"}}
```

## Docker хуки

https://docs.docker.com/docker-hub/webhooks/

```json
{
    "callback_url": "https://registry.hub.docker.com/u/y2khub/tag_game/hook/qwerty/",
    "push_data": {
        "images": [],
        "media_type": "application/vnd.docker.distribution.manifest.v2+json",
        "pushed_at": 1659284202,
        "pusher": "y2khub",
        "tag": "latest"
    },
    "repository": {
        "comment_count": 0,
        "date_created": 1659179366,
        "description": "",
        "full_description": null,
        "is_official": false,
        "is_private": false,
        "is_trusted": false,
        "name": "tag_game",
        "namespace": "y2khub",
        "owner": "y2khub",
        "repo_name": "y2khub/tag_game",
        "repo_url": "https://hub.docker.com/r/y2khub/tag_game",
        "star_count": 0,
        "status": "Active"
    }
}
```
