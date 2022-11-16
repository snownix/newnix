# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Newnix.Repo.insert!(%Newnix.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Newnix.Seeds do
  @doc false

  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [change: 2]

  alias Newnix.Repo
  alias Newnix.Accounts.User
  alias Newnix.Projects.Project
  alias Newnix.Builder
  alias Newnix.Builder.Form

  def insert_demo() do
    IO.inspect("Insert users....")
    insert_demo_users()
    IO.inspect("Insert projects....")
    insert_demo_projects()
  end

  def insert_demo_projects() do
    projects = many_rands(&generate_rand_project/0, 2, 1)

    projects
    |> Enum.each(fn p ->
      IO.inspect("new project #{p["name"]}")

      p =
        Project.changeset(%Project{}, p)
        |> Project.owner_changeset(select_random_user())
        |> Repo.insert!(timeout: :infinity)

      camp = update_campaigns_subscribers(p)

      p |> insert_rand_forms(camp)
    end)
  end

  def insert_demo_users() do
    Repo.insert_all(User, [
      %{
        firstname: "Jone",
        lastname: "Doe",
        phone: "+212612345678",
        email: "jone@newnix.io",
        hashed_password: Bcrypt.hash_pwd_salt("jone@newnix.io"),
        confirmed_at: datetime_patch(Faker.DateTime.backward(2)),
        inserted_at: datetime_patch(Faker.DateTime.backward(4)),
        updated_at: datetime_patch(Faker.DateTime.forward(1))
      }
    ])
  end

  def insert_rand_forms(project, campaigns) do
    many_rands(&generate_rand_form/0, 5, 2)
    |> Enum.each(fn form ->
      Builder.change_form(form, %{})
      |> Form.campaign_assoc(Enum.random(campaigns))
      |> Form.project_assoc(project)
      |> Repo.insert!()
    end)
  end

  def generate_rand_project() do
    IO.inspect("rand project")

    %{
      "name" => Faker.Company.En.name(),
      "description" => Faker.Lorem.Shakespeare.En.hamlet(),
      "website" => Faker.Internet.En.free_email_service(),
      "campaigns" => many_rands(&generate_rand_campaign/0, 5, 2)
    }
  end

  def generate_rand_campaign() do
    IO.inspect("rand campaign")

    %{
      "name" => Faker.Company.En.buzzword_prefix(),
      "description" => Faker.Lorem.Shakespeare.En.hamlet(),
      "start_at" => datetime_patch(Faker.DateTime.backward(4)),
      "expire_at" => datetime_patch(Faker.DateTime.forward(4)),
      "subscribers" => many_rands(&generate_rand_subscriber/0, 1_000, 500)
    }
  end

  def generate_rand_form() do
    IO.inspect("rand form")

    %Form{
      name: Faker.Company.En.buzzword_prefix(),
      description: Faker.Lorem.Shakespeare.En.hamlet(),
      email_text:
        Enum.random(["Email", "Your Email", "Email"]) <>
          " " <>
          Enum.random(["Here", "Address", "Address Here"]),
      thanks_text:
        Enum.random(["Thanks you", "Thanks", "We appreciate"]) <>
          " " <>
          Enum.random(["For the interest", "About signin up", "Your sign up"]),
      button_text: Enum.random(["Notify Me", "Send Email", "Send", "Join", "Notify", "Alert Me"]),
      firstname: Enum.random([true, false]),
      lastname: Enum.random([true, false])
    }
  end

  def generate_rand_subscriber() do
    %{
      firstname: Faker.Person.first_name(),
      lastname: Faker.Person.last_name(),
      email:
        Faker.Internet.free_email()
        |> String.replace("@", String.slice("#{System.os_time()}", -5..-1) <> "@")
    }
  end

  def update_campaigns_subscribers(project) do
    campaigns =
      project
      |> Repo.preload(:campaigns)
      |> then(& &1.campaigns)
      |> Repo.preload(:campaign_subscriber)

    campaigns
    |> Enum.each(fn c ->
      Enum.each(c.campaign_subscriber, fn cs ->
        Repo.update(
          change(cs,
            unsubscribed_at:
              if(Enum.random(1..10) > 3,
                do: nil,
                else: datetime_patch(Faker.DateTime.backward(Enum.random(1..100)))
              ),
            subscribed_at: datetime_patch(Faker.DateTime.backward(Enum.random(1..100)))
          )
        )

        cs = cs |> Repo.preload(:subscriber)
        Repo.update(change(cs.subscriber, project_id: project.id))
      end)
    end)

    campaigns
  end

  defp select_random_user() do
    from(t in User,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.all()
    |> List.first()
  end

  defp many_rands(call, max, min) do
    take = min + :rand.uniform(max - min)
    IO.inspect("-> Random between #{min} - #{max - min} -> #{take}")
    for _i <- 0..take, do: call.()
  end

  defp datetime_patch(datetime), do: datetime
end

# dev/test branch
if Application.get_env(:newnix, :environment) != :prod do
  Newnix.Seeds.insert_demo()
end
