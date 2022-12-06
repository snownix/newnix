defmodule Newnix.Pagination do
  import Ecto.Query
  alias Newnix.Repo

  @default_page 1
  @default_limit 50

  def query(query, opts \\ []) do
    page = secure_allowed_page(Keyword.get(opts, :page, 1))
    limit = secure_allowed_limit(Keyword.get(opts, :limit, 10))
    sort = secure_allowed_sort(Keyword.get(opts, :sort, :desc))
    allowed_orders = Keyword.get(opts, :allowed_orders, [:inserted_at])
    order = secure_allowed_order(allowed_orders, Keyword.get(opts, :order, :inserted_at))

    order_sort = dynamic_order(sort, order)

    query
    |> limit(^(limit + 1))
    |> offset(^(limit * (page - 1)))
    |> order_by(^order_sort)
    |> Repo.all()
  end

  defp dynamic_order(:asc, field), do: [asc: field]
  defp dynamic_order(:desc, field), do: [desc: field]

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

  def secure_allowed_limit(limit) when limit > 0 and limit <= 200, do: limit
  def secure_allowed_limit(_limit), do: @default_limit

  def secure_allowed_page(page) when page > 0, do: page
  def secure_allowed_page(_page), do: @default_page

  def secure_allowed_sort(:asc), do: :asc
  def secure_allowed_sort(_), do: :desc

  def secure_allowed_order(allowed_orders, order) do
    if order in allowed_orders do
      order
    else
      List.first(allowed_orders)
    end
  end
end
