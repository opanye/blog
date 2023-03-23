defmodule BlogWeb.CommentControllerTest do
  use BlogWeb.ConnCase

  import Blog.CommentsFixtures
  import Blog.PostsFixtures

  @create_attrs %{content: "some content"}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  describe "index" do
    test "lists all comments", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Comments"
    end
  end

  describe "new comment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :new))
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "create comment" do
    test "fails without associated post", %{conn: conn} do
      conn = post(conn, Routes.comment_path(conn, :create), comment: @create_attrs)

      # assert %{id: id} = redirected_params(conn)
      # assert redirected_to(conn) == Routes.posts_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Oops"

      # conn = get(conn, Routes.comment_path(conn, :show, id))
      # assert get_flash(conn, :info) == "Oops, something went wrong! Please check the errors below."
    end

    test "create comment with associated post", %{conn: conn} do
      post =
        post_fixture()
        |> Blog.Repo.preload([:comments])
        |> IO.inspect(label: "Post")

      conn =
        post(conn, Routes.comment_path(conn, :create),
          comment: %{"post_id" => post.id, content: "A top comment"}
        )

      assert %{id: post_id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.comment_path(conn, :show, post_id)

      conn = get(conn, Routes.comment_path(conn, :show, post_id))
      assert html_response(conn, 200) =~ "List Comments"
      assert html_response(conn, 200) =~ "A top comment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.comment_path(conn, :create), comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "edit comment" do
    setup [:create_comment]

    test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
      conn = get(conn, Routes.comment_path(conn, :edit, comment))
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = put(conn, Routes.comment_path(conn, :update, comment), comment: @update_attrs)
      assert redirected_to(conn) == Routes.comment_path(conn, :show, comment)

      conn = get(conn, Routes.comment_path(conn, :show, comment))
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put(conn, Routes.comment_path(conn, :update, comment), comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :delete, comment))
      assert redirected_to(conn) == Routes.comment_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.comment_path(conn, :show, comment))
      end
    end
  end

  defp create_comment(_) do
    post = post_fixture()
    comment = comment_fixture(post_id: post.id)
    %{comment: comment}
  end
end