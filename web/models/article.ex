defmodule Cazoc.Article do
  use Cazoc.Web, :model

  schema "articles" do
    field :title, :string
    field :body, :string
    field :cover, :string
    field :published_at, Timex.Ecto.DateTime
    belongs_to :author, Cazoc.Author
    belongs_to :repository, Cazoc.Repository

    timestamps usec: true
  end

  @required_fields ~w(title published_at)
  @optional_fields ~w(body cover)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def formated_publised_at(model) do
    model.published_at |> Timex.DateFormat.format!("%Y/%m/%d %H:%M", :strftime)
  end
end
