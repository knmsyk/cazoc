defmodule Cazoc.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Cazoc.Web, :controller
      use Cazoc.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps

      alias Cazoc.Repo
      alias Cazoc.{Article, Auth, Author, Collaborator, Comment, Family, Repository, Service, Session}
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Cazoc.Repo
      alias Cazoc.{Article, Auth, Author, Collaborator, Comment, Family, Repository, Service, Session}
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import Cazoc.Router.Helpers
      import Cazoc.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Cazoc.Router.Helpers
      import Cazoc.ErrorHelpers
      import Cazoc.Gettext

      import Cazoc.Session, only: [current_author: 1, logged_in?: 1, owner?: 2]
      import Cazoc.Article, only: [formated_publised_at: 1]
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Cazoc.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
      import Cazoc.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
