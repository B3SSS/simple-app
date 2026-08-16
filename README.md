# Тестовое задание для DevOps junior

## 1. Описание
Готовое решение для быстрого развертывания простого приложения на FastAPI в Docker-контейнере с возможность автоматического обновления и масштабирования через Ansible.

## 2. Требования
- Ubuntu 22.04
- Python 3.12+
- Docker
- Ansible

## 3. Быстрый старт
3.1. Клонирование репозитория проекта
```
git clone https://github.com/B3SSS/simple-app.git
cd simple-app
```
3.2. Локальный запуск
```
# Создание venv и установка зависимостей
python3 -m venv .venv
source ./.venv/bin/activate
python3 -m pip install --upgrade pip
pip3 install -r ./app/requirements.txt

# Запуск приложения
uvicorn app.main:app --port 5000
```
3.3. Запуск через Docker Compose (предварительная установка [Docker](https://docs.docker.com/engine/install/ubuntu/) на Ubuntu)
```
# Создание Docker-образа
docker build -t simple-app:latest .

# Запуск сервиса приложения
docker compose up -d
```

## 4. API Endpoints
Описание работы приложения:
- GET `/` - домашняя страница приложения
    ```
    curl -X 'GET' http://127.0.0.1:5000/ \
        -H 'accept: application/json'
    ```
- GET `/health` - проверка работоспособности приложения
    ```
    curl -X 'GET' http://127.0.0.1:5000/health \
        -H 'accept: application/json'
    ```
- GET `/api/users` - получение списка всех созданных пользователей
    ```
    curl -X 'GET' http://127.0.0.1:5000/api/users \
        -H 'accept: application/json'
    ```
- POST `/api/users` - создание нового пользователя
    ```
    curl -X 'POST' http://127.0.0.1:5000/api/users \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{"name": "Misha"}'
    ```
- GET `/api/users/<id>` - получение пользователя по id
    ```
    curl -X 'GET' \
        http://127.0.0.1:5000/api/users/573fb819-aeab-463d-9271-9f912a6f157a \
        -H 'accept: application/json'
    ```
- DELETE `/api/users/<id>` - удаление пользователя по id из базы
    ```
    curl -X 'DELETE' \
        http://127.0.0.1:5000/api/users/573fb819-aeab-463d-9271-9f912a6f157a \
        -H 'accept: application/json'
    ```

## 5. Bash-скрипт
Все Bash скрипты находятся в директории `./scripts`:
  - `server-info.sh` - скрипт парсинга актуальной информации о системе (CPU, RAM, disk, Docker containers, services status). Примеры использования:
    ```
    # Описание работы скрипта
    ./scripts/server-info.sh --help

    # Только информация о системе (без URL)
    ./scripts/server-info.sh

    # Информация о системе и статусе сервисов
    ./scripts/server-info.sh http://localhost:5000/health
    ./scripts/server-info.sh http://localhost:5000/health http://localhost:8000/health
    ```
## 6. Тестирование
- Прогон тестов API с использованием Pytest
```
pytest -v ./tests
```
- Линтинг Python кода
```
flake8 ./app
```

## 7. Ansible развертывание
```
# Установка зависимостей
cd ./ansible
pip3 install -r requirements.txt

# Установка коллекции для взаимодействия с Docker через Ansible
ansible-galacy collection install community.docker

# Запуск плейбука
ansible-playbook -i ./ansible/hosts.yaml ansible/playbook.yaml

# Запуск в debug режиме
ansible-playbook -i ./ansible/hosts.yaml ansible/playbook.yaml -CD

# Линтинг
ansible-playbook --syntax-check -i ./ansible/hosts.yaml ansible/playbook.yaml
```
## 8. Структура проекта
```
.
├── .github
│   └── workflows                       --- Директория с GitHub Actions пайплайнами ---
│       └── build.yaml                  # Файл build пайплайна
├── ansible                             --- Директория Ansible автоконфигурации ---
│   ├── ansible.cfg                     # Конфигурация Ansible
│   ├── hosts.yaml                      # Список хостов
│   ├── playbook.yaml                   # Главный плейбук
│   └── roles                           # Список ролей, доступных для вызова в playbook.yaml
│       ├── app                         # Роль app
│       │   ├── defaults                # Директория с изменяемыми переменными по умолчанию
│       │   │   └── main.yaml           #
│       │   ├── handlers                # Директория с обработчиками событий
│       │   │   └── main.yaml           #
│       │   ├── meta                    # Директория с мета инфомацией роли
│       │   │   └── main.yaml           #
│       │   ├── tasks                   # Директория с задачами роли
│       │   │   └── main.yaml           #
│       │   └── vars                    # Директория с неизменяемыми переменными по умолчанию
│       │       └── main.yaml           #
│       └── docker                      # Роль docker
│           ├── handlers                # Директория с обработчиками событий
│           │   └── main.yaml           # 
│           ├── meta                    # Директория с мета инфомацией роли
│           │   └── main.yaml           #
│           ├── tasks                   # Директория с задачами роли
│           │   └── main.yaml           #
│           ├── templates               # Директория с Jinja-шаблонами
│           │   └── docker.sources.j2   #
│           └── vars                    # Директория с неизменяемыми переменными по умолчанию
│               └── main.yaml           #
├── app                                 --- Директория приложения FastAPI ---
│   ├── main.py                         # Главный файл приложения
│   ├── pytest.ini                      # Конфигурация Pytest
│   ├── requirements.txt                # Список зависимостей приложения
│   └── tests                           # Директория с тестами приложения
│       └── test_app.py                 #
├── scripts                             --- Директория с bash-скриптами ---
│   └── server-info.sh                  # Скрипт для получения информации о сервере
├── .dockerignore                       # Файл, игнорирующий файлы и директории, не входящие в Docker-образ
├── .gitignore                          # Файл, игнорирующий файлы и директории, не входящие в проект
├── docker-compose.yaml                 # Файл Docker Compose для развертывания готового сервиса
├── Dockerfile                          # Файл Dockerfile для сборки образа
├── Makefile                            # Файл с набором команд для оптимизации времени разработки
├── README.md                           # Файл с подробным ревью проекта
```

## 9. Makefile
- Показать все команды
```
make help
```
- Примеры использования Makefile
```
### Клонирование репозитория
git clone https://github.com/B3SSS/simple-app.git
cd simple-app

# Установить зависимости и запустить приложение
make install
make run

# Запустить тесты (в другом терминале)
make test

# Линтинг
make lint

# Диагностика сервера
make server-info

### Docker Compose
make docker-build
make compose-up
make compose-logs

curl http://localhost:5000/api/users

make compose-down

### Ansible развертывание
# Проверить конфиг
make ansible-check

# Dry-run
make ansible-dry

# Запустить
make ansible-run
```

## 10. Troubleshooting