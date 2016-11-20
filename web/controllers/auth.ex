defmodule Rumbl.Auth do
  @moduledoc """
  Helper module with some functions useful
  for managing authentication of users
  """

  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  alias Rumbl.Router.Helpers

  @doc """
  Saves logged in user in session
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @doc """
  Attempts to log in user by `username` and `password`
  """
  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) -> {:ok, login(conn, user)}
      user -> {:error, :unauthorized, conn}
      true -> 
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  @doc """
  Attempts to log out user
  """
  def logout(conn) do
    configure_session(conn, drop: true)
  end
  
  @doc """
  Checks if user is logged in and
  if not it forbids access to the resource
  """
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

end
