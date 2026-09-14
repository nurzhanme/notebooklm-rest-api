# Свой форк notebooklm-rest-api с Docker

## 1. Форк и клон

Нажмите **Fork** на https://github.com/gnh1201/notebooklm-rest-api, затем:

```bash
git clone git@github.com:ВАШ_ЛОГИН/notebooklm-rest-api.git
cd notebooklm-rest-api
git remote add upstream https://github.com/gnh1201/notebooklm-rest-api.git
```

`upstream` нужен, чтобы позже подтягивать обновления автора:

```bash
git fetch upstream && git merge upstream/main
```

## 2. Добавить файлы

Положите в корень репозитория: `Dockerfile`, `compose.yaml`,
`.dockerignore`, `.gitignore`, `.env.example`.

```bash
git add Dockerfile compose.yaml .dockerignore .gitignore .env.example
git commit -m "docker: add containerized deployment"
git push
```

## 3. Логин на своей машине (разово)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium
notebooklm login
```

Появится профиль `~/.notebooklm/`.

## 4. Развернуть на VPS

```bash
git clone git@github.com:ВАШ_ЛОГИН/notebooklm-rest-api.git
cd notebooklm-rest-api

cp .env.example .env
sed -i "s/замените-на-длинный-случайный-ключ/$(openssl rand -hex 32)/" .env

mkdir -p data
```

Перенос профиля с личной машины (папка целиком, не один файл —
notebooklm-py 0.8.x хранит там больше, чем куки):

```bash
rsync -av ~/.notebooklm/ user@vps:/path/to/notebooklm-rest-api/data/.notebooklm/
```

Запуск:

```bash
chmod 600 .env
chmod -R go-rwx data/
docker compose up -d --build
```

## 5. Проверка

```bash
source .env
curl -H "X-API-Key: $NOTEBOOKLM_REST_API_KEY" http://127.0.0.1:8000/v1/notebooks
```

Список ноутбуков в ответе — всё работает.

## Обслуживание

| Задача | Команда |
| --- | --- |
| Логи | `docker compose logs -f` |
| Перезапуск | `docker compose restart` |
| Обновление кода | `git pull && docker compose up -d --build` |
| Остановка | `docker compose down` |

Swagger — через SSH-туннель, порт наружу закрыт:

```bash
ssh -L 8000:127.0.0.1:8000 user@vps
# затем http://localhost:8000/docs в браузере
```

## Когда сессия протухнет

Ошибки авторизации — это истёкшие куки, а не поломка:
повторите `notebooklm login` у себя, снова `rsync` профиля,
затем `docker compose restart`.

## Безопасность

- `data/.notebooklm/` — фактически ключи от вашего Google-аккаунта.
  Утечка = утечка доступа к аккаунту.
- `.gitignore` уже исключает `data/` и `.env`. Проверьте перед первым пушем:
  `git status --ignored`.
- Порт привязан к `127.0.0.1`, ключ обязателен (`:?` в compose).

## Если образ не соберётся

Тег `v1.49.0-jammy` привязан к версии Playwright. Если `notebooklm-py`
потребует другую, в логах будет несовпадение версий — поменяйте тег
базового образа на `v<нужная версия>-jammy`.

## Лицензия

Оригинал под MIT: форкать, менять и публиковать можно,
достаточно сохранить `LICENSE` и копирайт автора.
