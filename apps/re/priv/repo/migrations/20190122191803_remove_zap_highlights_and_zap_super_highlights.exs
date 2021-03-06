defmodule Re.Repo.Migrations.RemoveZapHighlightsAndZapSuperHighlights do
  use Ecto.Migration

  alias Ecto.Adapters.SQL
  alias Re.Repo

  def change do
    drop_if_exists unique_index(:zap_highlights, [:listing_id])
    drop_if_exists table(:zap_highlights)

    drop_if_exists unique_index(:zap_super_highlights, [:listing_id])
    drop_if_exists table(:zap_super_highlights)

    remove_column_if_exists(:listings, :zap_highlight)
    remove_column_if_exists(:listings, :zap_super_highlight)
  end

  defp remove_column_if_exists(table, column) do
    case column_exists?(table, column) do
      true ->
        alter table(table) do
          remove column
        end

      _ ->
        nil
    end
  end

  defp column_exists?(table, column) do
    table = Atom.to_string(table)
    column = Atom.to_string(column)

    {:ok, result} =
      SQL.query(
        Repo,
        "SELECT column_name " <>
          "FROM information_schema.columns " <>
          "WHERE table_name=$1 and column_name=$2",
        [table, column]
      )

    Map.get(result, :num_rows) == 1
  end
end
