defmodule Re.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Re.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Re.Factory
      import Re.DataCase
    end
  end

  setup do
    Re.Storage.reset!()

    :ok
  end
end
