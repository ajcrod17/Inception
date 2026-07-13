NAME = inception
DATA_PATH = ${HOME}/data
COMPOSE_FILE = srcs/docker-compose.yml

all: $(NAME)

$(NAME):
	$(MAKE) up

up:
	@echo "Building and starting Inception services..."
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	docker compose -f $(COMPOSE_FILE) up --build -d

clean: down

down:
	@echo "Stopping and removing Inception services..."
	docker compose -f $(COMPOSE_FILE) down

start:
	@echo "Resuming container execution..."
	docker compose -f $(COMPOSE_FILE) start

stop:
	@echo "Stopping container execution..."
	docker compose -f $(COMPOSE_FILE) stop

restart:
	@echo "Restarting Inception services..."
	docker compose -f $(COMPOSE_FILE) restart

fclean: clean
	@echo "Deep cleaning: Removing all volumes and cache..."
	@sudo rm -rf $(DATA_PATH)/mariadb/* 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)/wordpress/* 2>/dev/null || true
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af

re: fclean all

.PHONY: all up down start stop restart clean fclean re $(NAME)
