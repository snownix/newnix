install:
	@mix deps.get

migrate:
	@mix ecto.migrate
	
reset:
	@mix ecto.drop
	@mix ecto.setup

serve:
	@iex -S mix phx.server

docker:
	@docker-compose up -d

prod:
	$(MAKE) build-prod
	$(MAKE) push-prod

build-prod:
	@docker build -t registry.gitlab.com/newnixio/newnix .

push-prod:
	@docker push registry.gitlab.com/newnixio/newnix