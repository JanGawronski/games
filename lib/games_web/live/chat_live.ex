defmodule GamesWeb.ChatLive do
  use GamesWeb, :live_view

  alias Games.Chat.MessageStore
  alias Phoenix.PubSub

  @topic "chat_messages"

  def mount(_params, _session, socket) do
    PubSub.subscribe(Games.PubSub, @topic)
    {:ok, assign(socket, messages: MessageStore.all, nick: "")}
  end

  def render(assigns) do
    ~H"""
    <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;">
      <div style="max-width:640px;width:100%;padding:1rem;">
        <ul>
          <%= for %{:message => message, :author => author} <- @messages do %>
            <li><%= author %>: <%= message %></li>
          <% end %>
        </ul>
        <%= if @nick == "" do %>
        <form phx-submit="set_nick" style="display:flex;gap:.5rem;">
          <input type="text" name="nick" placeholder="Your nick..." style="flex:1;" /><br>
          <button type="submit">Set nick</button>
        </form><br>
        <% else %>
        <form phx-submit="send" style="display:flex;gap:.5rem;">
          <input type="text" name="message" placeholder="Message..." style="flex:1;" /><br>
          <button type="submit">Send</button>
        </form><br>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("send", %{"message" => text}, socket) do
    MessageStore.add(text, socket.assigns.nick)
    PubSub.broadcast(Games.PubSub, @topic, :new_message)
    {:noreply, assign(socket, messages: MessageStore.all)}
  end

  def handle_event("set_nick", %{"nick" => nick}, socket) do
    {:noreply, assign(socket, nick: nick)}
  end

  def handle_info(:new_message, socket) do
    {:noreply, assign(socket, messages: MessageStore.all)}
  end

end
