defmodule SlackGameEx.Slack.Bot do
  use WebSockex

  alias SlackGameEx.Slack.Auth

  defmacro __using__(_opts) do
    quote do
      use WebSockex
      import unquote(__MODULE__)

      require Logger

      def start_link(token) do
        {:ok, %{"url" => url} = response} = Auth.authorize(token)

        Logger.info("#{inspect __MODULE__} connecting to websocket #{url}")

        WebSockex.start_link(url, __MODULE__, %{id: 1})
      end

      def handle_frame({:text, incoming}, state) do
        incoming = Jason.decode!(incoming)

        case incoming["type"] do
          "hello" ->
            init(state)

          "message" ->
            case handle_event({:message, incoming["text"], incoming}, state) do
              {:ok, state} ->
                {:ok, state}

              {:reply, message_text, state} ->
                message = %{
                  id: state.id,
                  type: :message,
                  channel: incoming["channel"],
                  text: message_text
                }

                {:reply, {:text, Jason.encode!(message)}, next_state(state)}

              {:reply, message_text, channel, state} ->
                message = %{
                  id: state.id,
                  type: :message,
                  channel: channel,
                  text: message_text
                }

                {:reply, {:text, Jason.encode!(message)}, next_state(state)}

              other ->
                other
            end

          _type ->
            {:ok, state}
        end
      end

      def init(state), do: {:ok, state}

      def handle_frame(_message, state), do: {:ok, state}

      def handle_event(_message, state), do: {:ok, state}

      defoverridable handle_event: 2, init: 1
    end
  end

  def send_message(channel, message_text, state) do
    message = %{
      id: state.id,
      type: :message,
      channel: channel,
      text: message_text
    }


    {:reply, {:text, Jason.encode!(message)}, next_state(state)}
  end

  def next_state(%{id: id} = state) do
    %{state | id: id + 1}
  end
end
