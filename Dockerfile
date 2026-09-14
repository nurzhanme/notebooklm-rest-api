# Образ Playwright: Chromium и системные библиотеки уже внутри.
# На python:3.12-slim браузер пришлось бы доустанавливать отдельно.
FROM mcr.microsoft.com/playwright/python:v1.49.0-jammy

WORKDIR /app

# Отдельный слой — пересборка после правок кода будет быстрой
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Профиль notebooklm-py целиком лежит в volume, а не в образе
ENV NOTEBOOKLM_HOME=/data/.notebooklm \
    NOTEBOOKLM_STORAGE_PATH=/data/.notebooklm/storage_state.json \
    PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
