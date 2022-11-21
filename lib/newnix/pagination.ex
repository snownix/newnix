defmodule Newnix.Pagination do
  import Ecto.Query
  alias Newnix.Repo

  @default_page 1
  @default_limit 50

  def query(query, opts \\ []) do
    page = secure_allowed_page(Keyword.get(opts, :page, 1))
    limit = secure_allowed_limit(Keyword.get(opts, :limit, 10))

    query
    |> limit(^(limit + 1))
    |> offset(^(limit * (page - 1)))
    |> Repo.all()
  end

  def all(query) do
    query
    |> Repo.all()
  end

  def all(query, opts) do
    page = secure_allowed_page(Keyword.get(opts, :page, 1))
    limit = secure_allowed_limit(Keyword.get(opts, :limit, 10))

    results = query(query, opts)
    has_next = length(results) > limit
    has_prev = page > 1
    count = Repo.one(from(t in subquery(query), select: count("*")))

    %{
      metadata: %{
        count: count,
        has_prev: has_prev,
        prev_page: page - 1,
        page: page,
        has_next: has_next,
        next_page: page + 1,
        pages: Float.ceil(count / limit, 0) |> trunc,
        first: (page - 1) * limit + 1,
        last: Enum.min([page * limit, count])
      },
      entries: Enum.slice(results, 0, limit)
    }
  end

  def secure_allowed_limit(limit) when limit > 0 and limit < 100, do: limit
  def secure_allowed_limit(_limit), do: @default_limit

  def secure_allowed_page(page) when page > 0, do: page
  def secure_allowed_page(_page), do: @default_page
end
