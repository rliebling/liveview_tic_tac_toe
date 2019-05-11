defmodule TicTacToe do
  @moduledoc """
  TicTacToe keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Integer #for is_even

  defmodule Game do
    @doc """
      iex> TicTacToe.Game.new
      %{
        board: {{nil, nil, nil}, {nil, nil, nil}, {nil, nil, nil}},
        id: nil,
        moves: 0
      }
    """
    def new do
      %{ moves: 0, id: nil, board: {
          {nil, nil, nil},
          {nil, nil, nil},
          {nil, nil, nil}
        }
      }
    end

    @doc """
      iex> game = %{board: { {:x, :x, :x}, {nil, nil, nil}, {nil, nil, nil}}}
      %{board: { {:x, :x, :x}, {nil, nil, nil}, {nil, nil, nil}}}
      iex> TicTacToe.Game.game_over?(game)
      {true, "X wins"}
    """
    def game_over?(game) do
      cond do
        {:x, :x, :x} == Game.row(game, 0) -> {true, "X wins"}
        {:x, :x, :x} == Game.row(game, 1) -> {true, "X wins"}
        {:x, :x, :x} == Game.row(game, 2) -> {true, "X wins"}
        {:x, :x, :x} == Game.col(game, 0) -> {true, "X wins"}
        {:x, :x, :x} == Game.col(game, 1) -> {true, "X wins"}
        {:x, :x, :x} == Game.col(game, 2) -> {true, "X wins"}
        {:x, :x, :x} == Game.diag(game, 0) -> {true, "X wins"}
        {:x, :x, :x} == Game.diag(game, 1) -> {true, "X wins"}
        {:o, :o, :o} == Game.row(game, 0) -> {true, "O wins"}
        {:o, :o, :o} == Game.row(game, 1) -> {true, "O wins"}
        {:o, :o, :o} == Game.row(game, 2) -> {true, "O wins"}
        {:o, :o, :o} == Game.col(game, 0) -> {true, "O wins"}
        {:o, :o, :o} == Game.col(game, 1) -> {true, "O wins"}
        {:o, :o, :o} == Game.col(game, 2) -> {true, "O wins"}
        {:o, :o, :o} == Game.diag(game, 0) -> {true, "O wins"}
        {:o, :o, :o} == Game.diag(game, 1) -> {true, "O wins"}
        game[:moves] == 9 -> {true, "Draw!"}
        true -> {false}
      end
    end

    def row(g, i), do: g[:board] |> elem(i)

    def col(g, i) do
      Enum.map([0,1,2], fn r -> (Game.row(g, r) |> elem(i)) end)
      |> List.to_tuple
    end

    @doc """
    iex> game = %{ board: {{:x, nil, nil}, {nil, :x, nil}, {nil, nil, :x} }}
    %{board: {{:x, nil, nil}, {nil, :x, nil}, {nil, nil, :x}}}
    iex> TicTacToe.Game.diag(game, 0)
    {:x, :x, :x}
    """
    def diag(g, 0) do
      Enum.map([0,1,2], fn r -> (Game.row(g, r) |> elem(r)) end)
      |> List.to_tuple
    end
    def diag(g, 1) do
      Enum.map([0,1,2], fn r -> (Game.row(g, r) |> elem(2-r)) end)
      |> List.to_tuple
    end

    def at_coords(g, coords, x_value \\ :x, o_value \\ :o, nil_value \\ nil) do
      x_or_o = g[:board]
               |> elem( elem(coords,0) )
               |> elem( elem(coords,1) )
      case x_or_o do
        :x -> x_value
        :o -> o_value
        _ -> nil_value
      end
    end

    def move(g, coords) do
      x_or_o = case Integer.is_even(g[:moves]) do
        true -> :x
        _ -> :o
      end
      case at_coords(g, coords) do
        nil -> game = %{g | moves: g[:moves]+1, board: replace(g, coords, x_or_o)}
          case game_over?(game) do
            {true, msg} -> {:ok, game, msg}
            _ -> {:ok, game, ""}
          end
          _ -> {:error, "#{x_or_o} cannot move to space currently occupied by #{at_coords(g, coords)}"}
      end
    end

    defp replace(g, coords, x_or_o) do
      r = elem(coords, 0)
      c = elem(coords, 1)
      g[:board]
      |> Tuple.to_list
      |> Enum.with_index |> Enum.map(fn {row, i} -> 
        case i==r do
          true -> put_elem(row, c, x_or_o)
          _ -> row
        end
      end)
      |> List.to_tuple
    end
  end

end
