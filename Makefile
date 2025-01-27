# Variables
COMPOSE = docker-compose
COMPOSE_FILE = ./srcs/docker-compose.yml

# Règles
all: build up

build:
	$(COMPOSE) -f $(COMPOSE_FILE) build

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

clean: down
	$(COMPOSE) -f $(COMPOSE_FILE) rm -f
	$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans

re: clean all
