defmodule JsonstructTest do
  use ExUnit.Case
  doctest Jsonstruct
  alias Jsonstruct, as: J

  test "depth 1" do
    structed = File.read!("test/test.json") 
      |> Poison.decode!
      |> JsstBar.new
   
    #IO.puts inspect structed, pretty: true 
    assert structed.name == "joe"
  end
  test "depth 2" do
    structed = File.read!("test/test2.json")
      |> Poison.decode!
      |> JsstBaz.new

    #IO.puts inspect structed, pretty: true
    assert structed.name == "sam"
  end
  test "struct with ref works" do
    structed = File.read!("test/ref.json")
      #|> Poison.decode!(as: %Ref{test: %Bar{}})
      |> Poison.decode!
      |> JsstRef.new

    #IO.puts inspect structed, pretty: true
    assert structed.test.name == "joe"
  end
  test "ref expands" do
    ref_schema = J.load_schema("test/schema/ref.json")
    #IO.puts inspect ref_schema, pretty: true 

    test_map = File.read!("test/ref.json")
      |> Poison.decode!

    IO.puts inspect test_map, pretty: true
    valid? = ExJsonSchema.Validator.validate(ref_schema, test_map)
  
    IO.inspect ExJsonSchema.Validator.validate(ref_schema, test_map)
    assert valid? == :ok
    assert ExJsonSchema.Validator.valid?(ref_schema, test_map)
  end
  test "nested objects have correct format.  commas missing" do
    structed = File.read!("test/inner.json")
      |> Poison.decode!
      |> Inner.new

    assert structed.outer1.innerK1== "v2"
  end
  test "should raise on lack of defaults in schema" do
    assert false, "not done yet"
  end
  test "fails on bad module name" do
    assert_raise RuntimeError, fn -> 
      J.gen("test/bad_schema/bad_mod_name.json")
    end
  end
  test "works on directory" do
    J.do_dir("./test/schema")
    #assert false, "not done yet"
  end
  test "config works for stuff you want to change" do
    assert false, "not done yet"
  end
  test "works with remote resolver" do
    assert false, "not done yet"
  end
  test "interactive overwrite confirmation if modified outside" do
    assert false, "perhaps a .lock file to track when a file is changed by hand"
  end
  test "ensure all types are tested and warn/error correctly" do
    assert false, "not done yet"
  end
  test "circular ref?" do
    assert false, "TODO: seems bad if there is a circular ref\n not done yet"
  end
end
