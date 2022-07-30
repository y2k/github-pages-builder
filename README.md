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
  "callback_url": "https://registry.hub.docker.com/u/y2khub/tag_game/hook/2141b5bi5i5b02bec211i4eeih0242eg11000a/",
  "push_data": {
    "pushed_at": 1417566161,
    "pusher": "trustedbuilder",
    "tag": "latest"
  },
  "repository": {
    "comment_count": 0,
    "date_created": 1417494799,
    "description": "",
    "dockerfile": "#\n# BUILD\u0009\u0009docker build -t y2khub/apt-cacher .\n# RUN\u0009\u0009docker run -d -p 3142:3142 -name apt-cacher-run apt-cacher\n#\n# and then you can run containers with:\n# \u0009\u0009docker run -t -i -rm -e http_proxy http://192.168.1.2:3142/ debian bash\n#\nFROM\u0009\u0009ubuntu\n\n\nVOLUME\u0009\u0009[/var/cache/apt-cacher-ng]\nRUN\u0009\u0009apt-get update ; apt-get install -yq apt-cacher-ng\n\nEXPOSE \u0009\u00093142\nCMD\u0009\u0009chmod 777 /var/cache/apt-cacher-ng ; /etc/init.d/apt-cacher-ng start ; tail -f /var/log/apt-cacher-ng/*\n",
    "full_description": "Docker Hub based automated build from a GitHub repo",
    "is_official": false,
    "is_private": true,
    "is_trusted": true,
    "name": "tag_game",
    "namespace": "y2khub",
    "owner": "y2khub",
    "repo_name": "y2khub/tag_game",
    "repo_url": "https://registry.hub.docker.com/u/y2khub/tag_game/",
    "star_count": 0,
    "status": "Active"
  }
}
```
