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
