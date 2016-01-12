defmodule Cazoc.FamilyView do
  use Cazoc.Web, :view

  def render("index.json", %{families: families}) do
    %{data: render_many(families, Cazoc.FamilyView, "family.json")}
  end

  def render("show.json", %{family: family}) do
    %{data: render_one(family, Cazoc.FamilyView, "family.json")}
  end

  def render("family.json", %{family: family}) do
    %{id: family.id,
      name: family.name,
      display_name: family.display_name,
      description: family.description,
      author: render_one(family.author, Cazoc.AuthorView, "author.json"),
      collaborator: render_many(family.collaborators, Cazoc.CollaboratorView, "collaborator.json"),
      articles: render_many(family.articles, Cazoc.ArticleView, "article.json")}
  end
end
