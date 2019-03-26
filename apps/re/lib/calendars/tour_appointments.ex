defmodule Re.Calendars.TourAppointments do
  @moduledoc """
  Context module for tour appointments
  """

  alias Re.Calendars.{
    Projections.TourAppointment,
    Commands.ScheduleTourAppointment
  }

  alias Re.{
    Repo,
    Router
  }

  alias Ecto.Changeset

  def schedule_tour(params, listing, user) do
    lead_id = UUID.uuid4()

    params
    |> schedule_tour_changeset(%{lead_id: lead_id, listing_id: listing.uuid, user_id: user.uuid})
    |> ScheduleTourAppointment.new()
    |> Router.dispatch(consistency: :strong)
    |> case do
      :ok -> get_uuid(TourAppointment, lead_id)
      error -> error
    end
  end

  defp schedule_tour_changeset(params, more_params) do
    {
      Map.merge(params, more_params),
      %{
        lead_id: :string,
        wants_pictures: :boolean,
        wants_tour: :boolean,
        options: {:array, :naive_datetime},
        user_id: Ecto.UUID,
        listing_id: Ecto.UUID
      }
    }
    |> Changeset.cast(params, ~w(lead_id wants_tour wants_pictures options user_id listing_id)a)
    |> Changeset.validate_required(
      ~w(lead_id wants_tour wants_pictures options user_id listing_id)a
    )
  end

  defp get_uuid(schema, uuid) do
    case Repo.get_by(schema, uuid: uuid) do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end
end
