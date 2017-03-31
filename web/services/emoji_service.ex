defmodule UcxChat.EmojiService do
  use UcxChat.Web, :service
  use UcxChat.ChannelApi

  alias UcxChat.{Emoji, Account, EmojiView}

  require Logger

  def handle_in(ev = "click:open_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev = "click:close_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev = "tone_list", params, socket) do
    debug ev, params
    set_emoji_tone socket.assigns.user_id, params["tone"]
    {:reply, {:ok, %{tone_list: Emoji.tone_list()}}, socket}
  end
  def handle_in(ev = "filter-item", params, socket) do
    debug ev, params
    set_emoji_category socket.assigns.user_id, params["name"]
    {:noreply, socket}
  end
  def handle_in(ev = "search", params, socket) do
    debug ev, params
    emojis = Emoji.search(params["pattern"], params["category"])
    html =
      "emoji_category.html"
      |> EmojiView.render(emojis: emojis)
      |> safe_to_string

    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in(ev, params, socket) do
    Logger.warn "Unknown event #{ev}, params: #{inspect params}"
    {:noreply, socket}
  end

  defp set_emoji_category(user_id, name) do
    user_id
    |> get_account
    |> Account.changeset(%{emoji_category: name})
    |> Repo.update
  end

  defp set_emoji_tone(user_id, tone) do
    user_id
    |> get_account
    |> Account.changeset(%{emoji_tone: tone})
    |> Repo.update
  end

  def get_account(user_id) do
    user_id
    |> Account.get
    |> Repo.one
  end
end
