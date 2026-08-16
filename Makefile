define HELP_TEXT
Использование: make [цель]

Цели:
	help          - показать все команды
	install       - установить зависимости
	lint          - проверить качество кода (flake8/ruff для Python, shellcheck для Bash)
	test          - запустить тесты
	run           - запустить приложение
	server-info   - запустить Bash-скрипт диагностики сервера
	docker-build  - собрать Docker образ
	docker-run    - запустить контейнер
	compose-up    - запустить Docker Compose
	compose-down  - остановить Docker Compose
	compose-logs  - просмотреть логи
	ansible-check - проверить Ansible playbook
	ansible-dry   - dry-run Ansible
	ansible-run   - запустить Ansible playbook

Примеры:
	make install
	make server-info
endef

export HELP_TEXT

.PHONY: help install lint test run server-info docker-build docker-run compose-up compose-down compose-logs ansible-check ansible-dry ansible-run

help:
	@echo "$$HELP_TEXT"
install:
	pip install -r ./app/requirements.txt
	pip install -r ./ansible/requirements.txt
lint:
	flake8 -v ./app
test:
	pytest ./app/tests/test_app.py -v
run:
	uvicorn app.main:app --port 5000
server-info:
	./scripts/server-info.sh 
docker-build:
	docker build . -t simple-app-image:latest
docker-run:
	docker run -d -p 5000:5000 simple-app-image:latest
compose-up:
	docker compose up -d
compose-down:
	docker compose down
compose-logs:
	docker compose logs -f app 
ansible-check:
	ansible-playbook --syntax-check -i ansible/hosts.yaml ansible/playbook.yaml
ansible-dry:
	ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml -CD
ansible-run:
	ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml
