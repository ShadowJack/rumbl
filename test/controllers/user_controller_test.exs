defmodule Rumbl.UserControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.{Repo, User}

  setup do
    { :ok, user } = Repo.insert(%User{name: "Kostya", username: "ShadowJack", password_hash: "123"})
    Repo.insert(%User{name: "Olya", username: "Sheeffer", password_hash: "password"})
    { :ok, user_id: user.id }
  end

  test "GET /users", %{conn: conn} do
    conn = get(conn, "/users")
    
    assert html_response(conn, 200) =~ "Kostya"
    assert html_response(conn, 200) =~ "Olya"
  end

  test "GET /users/:id", %{conn: conn, user_id: user_id} do
    conn = get(conn, "/users/#{user_id}")

    assert html_response(conn, 200) =~ "Kostya"
    assert html_response(conn, 200) =~ "ShadowJack"
  end

  test "GET /users/new", %{conn: conn} do
    conn = get(conn, "/users/new")

    assert html_response(conn, 200) =~ "Create User"
    assert html_response(conn, 200) =~ "User"
    assert html_response(conn, 200) =~ "Username"
    assert html_response(conn, 200) =~ "Password"
  end

  test "POST /users", %{conn: conn} do
    "Not implemented"
  end
end
