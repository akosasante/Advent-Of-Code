defmodule AdventOfCodeHelper.GetInputs do
  alias AdventOfCodeHelper.FileCache
  @moduledoc """
  Contains all the logic for actually grabbing data from the website
  """

  @doc """
  Checks to see if we already have this input, else will go and get it
  ## Parameters
    - Year: Int for year of puzzle
    - Day: Int for day of puzzle
    - Session: Session variable for authenticating against AoC
  """
  def get_value(year, day, session) do
    case FileCache.in_cache?(year,day) do
      true -> FileCache.get_file(year,day)
      false -> save_and_return(year,day,session)
    end
  end

  defp save_and_return(year,day,session) do
    case generate_url(year,day) |> get_from_url(session) do
      {:ok, contents} -> FileCache.save_file(year,day,contents)
                         {:ok, contents}
      {:fail, message} -> {:fail, message}
    end
  end

  defp get_from_url(url, session) do
    Finch.start_link(name: MyFinch)

    Finch.build(:get, url, generate_headers(session))
    |> Finch.request(MyFinch)
    |> case do
         {:ok, %Finch.Response{body: body, status: 200}} -> {:ok, body}
         {:ok, %Finch.Response{body: body}} -> {:fail, body}
         {:error, %{reason: error}} -> {:fail, error}
         error -> {:fail, "Unexpected error: #{inspect error}"}
    end
  end

  defp generate_url(year,day) do
    "https://adventofcode.com/#{year}/day/#{day}/input"
  end

  defp generate_headers(session) do
    [{"cookie", "session=#{session}"}]
  end
end
