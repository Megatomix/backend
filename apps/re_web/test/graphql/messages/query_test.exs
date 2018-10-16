defmodule ReWeb.GraphQL.Messages.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "listingUserMessages" do
    test "admin should list messages per listing", %{admin_conn: conn, admin_user: admin_user} do
      user = insert(:user)
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: admin_user.id, receiver_id: user.id, listing_id: listing.id)

      %{id: id2} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      %{id: id3} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      insert(:message, sender_id: user.id, receiver_id: admin_user.id)

      variables = %{"id" => listing.id}

      query = """
        query ListingUserMessages ($id: ID) {
          listingUserMessages (listingId: $id) {
            messages {
              id
              inserted_at
              message
              listing {
                id
              }
            }
            user {
              id
            }
          }
        }
      """

      id1 = to_string(id1)
      id2 = to_string(id2)
      id3 = to_string(id3)
      listing_id = to_string(listing.id)
      user_id = to_string(user.id)

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listingUserMessages" => %{
                 "messages" => [
                   %{"id" => ^id1, "listing" => %{"id" => ^listing_id}, "inserted_at" => _},
                   %{"id" => ^id2, "listing" => %{"id" => ^listing_id}, "inserted_at" => _},
                   %{"id" => ^id3, "listing" => %{"id" => ^listing_id}, "inserted_at" => _}
                 ],
                 "user" => %{"id" => ^user_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should list messages per listing", %{user_conn: conn, user_user: user} do
      admin_user = insert(:user, role: "admin")
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: admin_user.id, receiver_id: user.id, listing_id: listing.id)

      %{id: id2} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      %{id: id3} =
        insert(:message, sender_id: user.id, receiver_id: admin_user.id, listing_id: listing.id)

      insert(:message, sender_id: user.id, receiver_id: admin_user.id)

      variables = %{"id" => listing.id}

      query = """
        query ListingUserMessages ($id: ID) {
          listingUserMessages (listingId: $id) {
            messages {
              id
              message
              listing {
                id
              }
            }
            user {
              id
            }
          }
        }
      """

      id1 = to_string(id1)
      id2 = to_string(id2)
      id3 = to_string(id3)
      listing_id = to_string(listing.id)
      admin_user_id = to_string(admin_user.id)

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listingUserMessages" => %{
                 "messages" => [
                   %{"id" => ^id1, "listing" => %{"id" => ^listing_id}},
                   %{"id" => ^id2, "listing" => %{"id" => ^listing_id}},
                   %{"id" => ^id3, "listing" => %{"id" => ^listing_id}}
                 ],
                 "user" => %{"id" => ^admin_user_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "admin should filter messages by sender", %{admin_conn: conn, admin_user: admin} do
      user1 = insert(:user, role: "user")
      user2 = insert(:user, role: "user")
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: user1.id, receiver_id: admin.id, listing_id: listing.id)

      %{id: id2} = insert(:message, sender_id: user1.id, receiver_id: admin.id)

      insert(:message, sender_id: user2.id, receiver_id: admin.id, listing_id: listing.id)

      insert(:message, sender_id: user2.id, receiver_id: admin.id)

      variables = %{"senderId" => user1.id}

      query = """
        query ListingUserMessages ($senderId: ID) {
          listingUserMessages (senderId: $senderId) {
            messages {
              id
              message
              sender {
                id
              }
              listing {
                id
              }
            }
            user {
              id
            }
          }
        }
      """

      id1 = to_string(id1)
      id2 = to_string(id2)
      user1_id = to_string(user1.id)
      listing_id = to_string(listing.id)

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "messages" => [
                 %{
                   "id" => ^id1,
                   "listing" => %{"id" => ^listing_id},
                   "sender" => %{"id" => ^user1_id}
                 },
                 %{"id" => ^id2, "sender" => %{"id" => ^user1_id}}
               ],
               "user" => %{"id" => ^user1_id}
             } = json_response(conn, 200)["data"]["listingUserMessages"]
    end

    test "admin should filter messages by sender and listing", %{
      admin_conn: conn,
      admin_user: admin
    } do
      user1 = insert(:user, role: "user")
      user2 = insert(:user, role: "user")
      listing = insert(:listing)

      %{id: id1} =
        insert(:message, sender_id: user1.id, receiver_id: admin.id, listing_id: listing.id)

      insert(:message, sender_id: user1.id, receiver_id: admin.id)

      insert(:message, sender_id: user2.id, receiver_id: admin.id, listing_id: listing.id)

      insert(:message, sender_id: user2.id, receiver_id: admin.id)

      variables = %{"listingId" => listing.id, "senderId" => user1.id}

      query = """
        query ListingUserMessages ($listingId: ID, $senderId: ID) {
          listingUserMessages (listingId: $listingId, senderId: $senderId) {
            messages {
              id
              message
              sender {
                id
              }
              listing {
                id
              }
            }
            user {
              id
            }
          }
        }
      """

      id1 = to_string(id1)
      listing_id = to_string(listing.id)
      user1_id = to_string(user1.id)

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

      assert %{
               "listingUserMessages" => %{
                 "messages" => [
                   %{
                     "id" => ^id1,
                     "listing" => %{"id" => ^listing_id},
                     "sender" => %{"id" => ^user1_id}
                   }
                 ],
                 "user" => %{"id" => ^user1_id}
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not list messages per listing", %{unauthenticated_conn: conn} do
      query = """
        query ListingUserMessages {
          listingUserMessages {
            messages {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      assert %{"errors" => [%{"message" => "Unauthorized", "code" => 401}]} =
               json_response(conn, 200)
    end
  end
end
