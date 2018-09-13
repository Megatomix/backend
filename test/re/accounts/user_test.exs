defmodule Re.UserTest do
  use Re.ModelCase

  alias Re.{
    Repo,
    User
  }

  import Re.Factory

  @valid_attrs %{
    name: "mahname",
    email: "validemail@emcasa.com",
    phone: "317894719384",
    password: "validpassword",
    role: "user",
    confirmation_token: "97971cce-eb6e-418a-8529-e717ca1dcf62",
    confirmed: true,
    notification_preferences: %{email: false, app: false}
  }
  @invalid_attrs %{
    name: nil,
    email: "invalidemail",
    password: "",
    role: "inexisting role"
  }

  test "changeset with valid attributes" do
    changeset = User.create_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.create_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :name) == {"can't be blank", [validation: :required]}
    assert Keyword.get(changeset.errors, :email) == {"has invalid format", [validation: :format]}
    assert Keyword.get(changeset.errors, :password) == {"can't be blank", [validation: :required]}

    assert Keyword.get(changeset.errors, :role) ==
             {"should be one of: [admin user]", [validation: :inclusion]}
  end

  test "duplicated email should be valid" do
    insert(:user, @valid_attrs)

    {:ok, user} =
      %User{}
      |> User.create_changeset(@valid_attrs)
      |> Repo.insert()
  end
end
