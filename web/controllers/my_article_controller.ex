defmodule Cazoc.MyArticleController do
  use Cazoc.Web, :controller

  plug :scrub_params, "article" when action in [:create, :update]

  def index(conn, _params) do
    articles = Repo.all from article in Article,
           join: author in assoc(article, :author),
           where: author.id == ^Session.current_author(conn).id,
           preload: [author: author]
    render(conn, "index.html", articles: articles)
  end

  def new(conn, _params) do
    changeset = Article.changeset(%Article{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"article" => article_params}) do
    now = Timex.now
    author = Session.current_author(conn)
    dir_name = now |> Timex.format!("%Y%m%d%H%M%S", :strftime)
    path = author |> Author.path |> Path.join(dir_name)
    article = %Article{author_id: author.id, published_at: now}
    changeset = Article.changeset(article, article_params)
    result = with {:ok, article} <- Repo.insert(changeset),
      {:ok, repo} <- init_and_commit(path, article),
      do: {:ok, repo}

    case result do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Article created successfully.")
        |> redirect(to: my_article_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to post article.")
        |> redirect(to: my_article_path(conn, :index))
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    article =
      Repo.get_by(Article, uuid: uuid)
      |> Repo.preload(:author)
    result = Article.html_body article
    case result do
      {:ok, body} ->
        conn
        |> render("show.html", article: article, body: body)
      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to load article.")
        |> redirect(to: my_article_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    article = Repo.get!(Article, id)
    changeset = Article.changeset(article)
    render(conn, "edit.html", article: article, changeset: changeset)
  end

  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Repo.get!(Article, id) |> Repo.preload(:repository)
    changeset = Article.changeset(article, article_params)

    case Repo.update(changeset) do
      {:ok, article} ->
        %Git.Repository{path: article.repository.path} |> update_repository(article)
        conn
        |> put_flash(:info, "Article updated successfully.")
        |> redirect(to: my_article_path(conn, :show, article))
      {:error, changeset} ->
        render(conn, "edit.html", article: article, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Repo.get!(Article, id) |> Repo.preload(:family)
    Repo.delete!(article)

    author = Session.current_author(conn)
    conn
    |> put_flash(:info, "Article deleted successfully.")
    |> redirect(to: my_family_path(conn, :show, author.name, article.family.name))
  end

  defp init_and_commit(path, article) do
    {:ok, repo} = Git.init path
    update_repository(repo, article |> Repo.preload(:repository))
  end

  defp update_repository(repo, article) do
    file_name = "index.md"
    Path.join(article.repository.path, file_name) |> File.write(article.body)
    Git.add repo, "--all"
    Git.commit repo, "-m 'Update'"
  end
end
