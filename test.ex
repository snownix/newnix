# Simple Text to unique color #hash

defmodule Color do
  def string_to_color_hash(text, hash \\ 0) do
    hash =
      String.to_charlist(text)
      |> Enum.reduce(hash, fn char, hash ->
        hash = char + (Bitwise.<<<(hash, 5) - hash)
        Bitwise.&&&(hash, hash)
      end)

    {color, _hash} =
      Enum.reduce(1..3, {"#", hash}, fn i, {color, hash} ->
        val = Bitwise.&&&(Bitwise.>>>(hash, i * 8), 255)

        {
          color <> String.slice("00" <> Integer.to_string(val, 16), -2..-1),
          hash
        }
      end)

    color
  end
end

colorHash = Color.string_to_color_hash("hello world")
IO.inspect(colorHash)

if colorHash !== "#E2EF6A" do
  throw("Hash #{colorHash} not correct")
end
