defmodule Rumbl.AuthPlug do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    cond do
      user = conn.assigns[:current_user] -> Rumbl.Auth.put_current_user(conn, user)
      user = user_id && repo.get(Rumbl.User, user_id) -> Rumbl.Auth.put_current_user(conn, user)
      true -> assign(conn, :current_user, nil)
    end
  end
end
