defmodule TicTacToeWeb.BoardView do
  use Phoenix.LiveView

  @topic "game"

  def render(assigns) do
    ~L"""
    <style>
    td {
      height: 100px;
      vertical-align: middle;
      text-align: center;
    }
    </style>

    <div><%= @msg %></div>

    <table border="1">
    <tr>
    <td width="33%" phx-click="click_cell" phx-value="0,0"><%= square(@game, "0,0") %></td>
    <td width="33%" phx-click="click_cell" phx-value="0,1"><%= square(@game, "0,1") %></td>
    <td width="33%" phx-click="click_cell" phx-value="0,2"><%= square(@game, "0,2") %></td>
    </tr>
    <tr>
    <td width="33%" phx-click="click_cell" phx-value="1,0"><%= square(@game, "1,0") %></td>
    <td width="33%" phx-click="click_cell" phx-value="1,1"><%= square(@game, "1,1") %></td>
    <td width="33%" phx-click="click_cell" phx-value="1,2"><%= square(@game, "1,2") %></td>
    </tr>
    <tr>
    <td width="33%" phx-click="click_cell" phx-value="2,0"><%= square(@game, "2,0") %></td>
    <td width="33%" phx-click="click_cell" phx-value="2,1"><%= square(@game, "2,1") %></td>
    <td width="33%" phx-click="click_cell" phx-value="2,2"><%= square(@game, "2,2") %></td>
    </tr>
    </table>

    <input type="button" phx-click="new_game" value="New game"/>
    """
  end

  def mount(_session, socket) do
    TicTacToeWeb.Endpoint.subscribe(@topic, [])
    TicTacToeWeb.Endpoint.broadcast_from(self(), @topic, "get_state", %{})
    # Phoenix.PubSub.subscribe(@topic)
    {:ok, assign(socket, msg: "Start!", game: TicTacToe.Game.new)}
  end

  def handle_event("new_game",  _value, socket) do
    new_game = TicTacToe.Game.new
    TicTacToeWeb.Endpoint.broadcast_from(self(), @topic, "move", %{game: new_game, msg: "New game!"})
    {:noreply, assign(socket, msg: "Start!", game: new_game)}
  end

  def handle_event("click_cell",  coord_str, socket) do
    coords = parse_coords(coord_str)
    result = TicTacToe.Game.move(socket.assigns[:game], coords)
    case result do
      {:ok, updated_game, msg} -> TicTacToeWeb.Endpoint.broadcast_from(self(), @topic, "move", %{game: updated_game, msg: msg})
        {:noreply, assign(socket, game: updated_game, msg: msg)}
      {:error, msg} -> {:noreply, assign(socket, :msg, msg) }
    end
  end

  def handle_info(%{topic: @topic, event: "get_state"},  socket) do
    IO.puts "get_state #{inspect( self())}"
    TicTacToeWeb.Endpoint.broadcast_from(self(), @topic, "init_state", %{game: socket.assigns[:game], msg: socket.assigns[:msg]})
    {:noreply, socket}
  end

  def handle_info(%{topic: @topic, event: "init_state", payload: %{game: game, msg: msg}},  socket) do
    IO.puts "init_state:  #{inspect(self())}"

    {:noreply, assign(socket, game: game, msg: msg)}
  end

  def handle_info(%{topic: @topic, payload: %{game: game, msg: msg}},  socket) do
    {:noreply, assign(socket, game: game, msg: msg)}
  end
  def handle_info(msg,   socket) do
    IO.puts("default handle_info: #{inspect(msg)}")
    {:noreply, socket}
  end

  def square(game, coord_str ) do
    coords = parse_coords(coord_str)
    TicTacToe.Game.at_coords(game, coords, "X", "O")
  end

  defp parse_coords(coord_str) do
    String.split(coord_str,",")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&elem(&1, 0))
    |> List.to_tuple
  end
end
