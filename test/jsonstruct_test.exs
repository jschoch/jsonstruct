defmodule JsonstructTest do
  use ExUnit.Case
  doctest Jsonstruct
  alias Jsonstruct, as: J

  test "depth 1" do
    IO.puts inspect  %Foo{}
    IO.puts inspect %Bar{}

    structed = File.read!("test/test.json") 
      |> Poison.decode!
      |> Bar.new
   
    IO.puts inspect structed, pretty: true 
    assert structed.name == "joe"
  end
  test "depth 2" do
    structed = File.read!("test/test2.json")
      |> Poison.decode!
      |> Baz.new

    IO.puts inspect structed, pretty: true
    assert structed.name == "sam"
  end
  test "ref" do
    assert false, "not done yet"
  end
end
