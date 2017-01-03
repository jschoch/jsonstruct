defmodule Mix.Tasks.Jsst do
  use Mix.Task
  alias Jsonstruct, as: J
  def run(args) do
    IO.puts "cleaning up"
    
    IO.puts "creating structs"
    t = J.templ
    s = EEx.eval_string( t, fields: ["a: :a"], module: "Foo")
    File.write!("lib/foo_struct.ex",s) 
    s = J.gen("test/schema/test.json","Bar")
    File.write!("lib/bar_struct.ex",s)
    s = J.gen("test/schema/test2.json","Baz")
    File.write!("lib/baz_struct.ex",s)
    s = J.gen("test/schema/ref.json","Ref")
    File.write!("lib/ref_struct.ex",s)
  end
end

defmodule Jsonstruct do
  def load_schema(file \\"schema/user.json") do
    File.read!(file)
      |> Poison.decode!
      |> ExJsonSchema.Schema.resolve
  end
  def gen(file,module_name) do
    schema = load_schema(file)
    IO.puts inspect schema, pretty: true
    templ = templ()
    props = schema.schema["properties"] 
    keys = Map.keys props
    fields = walk(props)
      |> Enum.join(",")
    module = module_name
    t = templ
    EEx.eval_string( t,fields: fields,module: module)
    
  end

  def walk(props) do
    keys = Map.keys props
    Enum.map(keys,fn(key) ->
        IO.puts "KEY: " <> inspect props[key], pretty: true
        case Map.has_key?(props[key], "$ref") do
          true -> 
            ref_map = load_schema props[key]["$ref"]
            IO.puts inspect ref_map, pretty: true
            "#{key}: %#{ref_map.schema["title"]}{}"
          _ ->
            case props[key]["type"] do
              "string" ->
                "#{key}: \"#{props[key]["default"]}\""
              "array" ->
                "#{key}: []"
              "object" ->
                props = props[key]["properties"]
                "#{key}: %{#{walk(props)}}"
              horror -> raise "unknown prop type: #{}" <> inspect horror, pretty: true
            end
        end
      end) 
  end
  def templ do
    """
    defmodule <%= module %> do
      defstruct <%= fields %>
      use ExConstructor
    end
    """
  end
end
defmodule U do
  defstruct name: "John"
end
