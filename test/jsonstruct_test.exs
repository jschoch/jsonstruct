defmodule JsonstructTest do
  use ExUnit.Case
  doctest Jsonstruct
  alias Jsonstruct, as: J

  test "depth 1" do
    structed = File.read!("./test/test.json") 
      |> Poison.decode!
      |> JsstBar.new
   
    #IO.puts inspect structed, pretty: true 
    assert structed.name == "joe"
  end
  test "depth 2" do
    structed = File.read!("./test/test2.json")
      |> Poison.decode!
      |> JsstBaz.new

    #IO.puts inspect structed, pretty: true
    assert structed.name == "sam"
  end
  test "struct with ref works" do
    structed = File.read!("./test/ref.json")
      #|> Poison.decode!(as: %Ref{test: %Bar{}})
      |> Poison.decode!
      |> JsstRef.new

    #IO.puts inspect structed, pretty: true
    assert structed.test.name == "joe"
  end
  test "ref expands" do
    ref_schema = J.load_schema("./test/schema/ref.json")
    #IO.puts inspect ref_schema, pretty: true 

    test_map = File.read!("./test/ref.json")
      |> Poison.decode!

    IO.puts inspect test_map, pretty: true
    valid? = ExJsonSchema.Validator.validate(ref_schema, test_map)
  
    IO.inspect ExJsonSchema.Validator.validate(ref_schema, test_map)
    assert valid? == :ok
    assert ExJsonSchema.Validator.valid?(ref_schema, test_map)
  end

  test "ref with example.com expands" do
    ref_schema = J.load_schema("./test/schema/ref2.json")
    #IO.puts inspect ref_schema, pretty: true

    test_map = File.read!("./test/ref2.json")
      |> Poison.decode!

    IO.puts inspect test_map, pretty: true
    valid? = ExJsonSchema.Validator.validate(ref_schema, test_map)

    IO.inspect ExJsonSchema.Validator.validate(ref_schema, test_map)
    assert valid? == :ok
    assert ExJsonSchema.Validator.valid?(ref_schema, test_map)
  end
  test "nested objects have correct format.  commas missing" do
    structed = File.read!("./test/inner.json")
      |> Poison.decode!
      |> Inner.new

    assert structed.outer1.innerK1== "v2"
  end

  test "adds nil if no defaults in schema" do
    structed = %JsstND{}
    assert structed.outer1.innerK1 ==  nil
  end
  test "fails on bad module name" do
    options = [template: J.templ()]
    assert_raise RuntimeError, fn -> 
      J.gen("test/bad_schema/bad_mod_name.json",options)
    end
  end
  test "works on directory" do
    options = [template: J.templ()]
    J.do_dir("./test/schema",options)
  end

  @tag :todo
  test "config works for stuff you want to change" do
    assert false, "handle changing how no defaults are handled, nil or type based like \"\" for empty string"
    assert false, "should have option to raise on no defaults"
    assert false, "TODO: ignores '.' files like vim temp files"
  end

  @tag :todo
  test "works with remote resolver" do
    assert false, "not done yet"
  end

  @tag :todo
  test "interactive overwrite confirmation if modified outside" do
    assert false, "perhaps a .lock file to track when a file is changed by hand"
  end

  @tag :todo
  test "ensure all types are tested and warn/error correctly" do
    assert false, "not done yet"
  end

  @tag :todo
  test "circular ref?" do
    assert false, "TODO: seems bad if there is a circular ref\n not done yet"
  end
end
