defmodule SlackGameEx.Slack.Auth do
  alias HTTPoison.Response

  def authorize(token) do
    headers = [
      Authorization: "Bearer #{token}",
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    endpoint = "https://slack.com/api/rtm.connect"

    case HTTPoison.post(endpoint, "grant_type=client_credentials", headers) do
      {:ok, %Response{status_code: 200, body: body}} -> {:ok, Jason.decode!(body)}
      {:ok, %Response{body: body}} -> {:error, Jason.decode!(body)}
      other -> other
    end
  end
end
