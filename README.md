# Newnix

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

# Mail providers

- [ ] sendgrid: api_key
- [ ] sendinblue: api_key
- [ ] mandrill: api_key
- [ ] postmark: api_key
- [ ] dyn: api_key
- [ ] maipeace: api_key
- [ ] smtp2go: api_key
- [ ] gmail: api_key(access_token)
- [ ] mailjet: api_key, api_secret
- [ ] mailgun: api_key, domain
- [ ] sparkpost: api_key, endpoint
- [ ] socketlabs: api_key, server_id

`mix phx.gen.schema Project.Integration project_integrations name:string type:enum:mailjet:mailgun:sendgrid:sendinblue:mandrill:postmark:dyn:mailpace:smtp2go:gmail:sparkpost:socketlabs status:enum:active:inactive:error:limited project_id:references:projects user_id:references:users`


![Alt](https://repobeats.axiom.co/api/embed/6f2cadfc80aafc821c1221ce1a9335e93213feb8.svg "Repobeats analytics image")
