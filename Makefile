NAME = inception
DATA_PATH = ${HOME}/data
COMPOSE_FILE = srcs/docker-compose.yml

all: $(NAME)

$(NAME):
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	docker compose -f $(COMPOSE_FILE) up --build -d

clean:
	docker compose -f $(COMPOSE_FILE) down

fclean: clean
	@sudo rm -rf $(DATA_PATH)/mariadb/* 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)/wordpress/* 2>/dev/null || true
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af

re: fclean all

.PHONY: all clean fclean re
