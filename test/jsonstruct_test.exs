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
  test "struct with ref works" do
    structed = File.read!("test/ref.json")
      #|> Poison.decode!(as: %Ref{test: %Bar{}})
      |> Poison.decode!
      |> Ref.new

    IO.puts inspect structed, pretty: true
    assert structed.test.name == "joe"
  end
  test "ref expands" do
    ref_schema = J.load_schema("test/schema/ref.json")
    IO.puts inspect ref_schema, pretty: true 

    test_map = File.read!("test/ref.json")
      |> Poison.decode!

    IO.puts inspect test_map, pretty: true
    valid? = ExJsonSchema.Validator.validate(ref_schema, test_map)
  
    IO.inspect ExJsonSchema.Validator.validate(ref_schema, test_map)
    assert valid? == :ok
    assert ExJsonSchema.Validator.valid?(ref_schema, test_map)
  end
  test "works on default directory" do
    assert false, "not done yet"
  end
  test "works on config directory" do
    assert false, "not done yet"
  end
  test "works with remote resolver" do
    assert false, "not done yet"
  end
  test "circular ref?" do
    assert false, "TODO: seems bad if there is a circular ref\n not done yet"
  end
  test "ref struct not expanded but using existing struct def" do
    assert false, "not done yet"
  end
end
