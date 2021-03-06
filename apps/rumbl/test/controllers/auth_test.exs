defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase

  alias Rumbl.{Auth, AuthPlug}

  setup %{conn: conn} do
    conn = conn |> bypass_through(Rumbl.Router, :browser) |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate user halts when no current_user exists", %{conn: conn} do
    conn = 
      conn
      |> Auth.authenticate_user([])
    assert conn.halted
  end

  test "authenticate_user continues when current_user exists", %{conn: conn} do
    conn = 
      conn 
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn = 
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout removes the user from the session", %{conn: conn} do
    logout_conn = 
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn = 
      conn
      |> put_session(:user_id, user.id)
      |> AuthPlug.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session adds nil current_user into assigns", %{conn: conn} do
    conn = 
      conn
      |> AuthPlug.call(Repo)

    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and pass", %{conn: conn} do
    user = insert_user(username: "me", password: "secret")
    {:ok, conn} = Auth.login_by_username_and_pass(conn, "me", "secret", repo: Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user fails", %{conn: conn} do
    assert {:error, :not_found, _conn} = Auth.login_by_username_and_pass(conn, "not_me", "secret", repo: Repo)
  end

  test "login with wrong password fails", %{conn: conn} do
    _ = insert_user(username: "me", password: "secret")
    assert {:error, :unauthorized, _conn} = Auth.login_by_username_and_pass(conn, "me", "wrong_password", repo: Repo)
  end
end
