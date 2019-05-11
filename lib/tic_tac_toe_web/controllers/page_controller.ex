defmodule TicTacToeWeb.PageController do
  use TicTacToeWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _) do
    LiveView.Controller.live_render(conn, TicTacToeWeb.BoardView, session: %{})
  end

end
