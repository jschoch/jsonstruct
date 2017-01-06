defmodule Mix.Tasks.Jsst do
  use Mix.Task
  alias Jsonstruct, as: J
  def run(args) do
    case Mix.env do
      :test -> 
        raise "what was i going to do with this?>>>..."
      _ ->
        J.do_dir(List.first args) 
    end
  end
end

defmodule Jsonstruct do
  def load_schema(file \\"schema/user.json") do
    File.read!(file)
      |> Poison.decode!
      |> ExJsonSchema.Schema.resolve
  end
  def do_dir(dir \\"./schema") do
    case File.exists?(dir) do
      true ->
        Enum.each(File.ls!(dir), fn file ->
          gen(dir <> "/" <> file,"Foo") 
        end)
      false -> raise "./schema not found"
    end
  end
  def gen(file,module_name \\nil) do
    schema = load_schema(file)
    module_name = if (module_name != nil) do
      schema.schema["title"]
    end
    #IO.puts inspect schema, pretty: true
    templ = templ()
    props = schema.schema["properties"] 
    #keys = Map.keys props
    fields = walk(props)
      |> Enum.join(",")
    t = templ
    s = EEx.eval_string( t,fields: fields,module: module_name)
    File.write!("lib/#{module_name}_jsst_struct.ex",s)
  end

  def walk(props) do
    keys = Map.keys props
    Enum.map(keys,fn(key) ->
        #IO.puts "KEY: " <> inspect props[key], pretty: true
        case Map.has_key?(props[key], "$ref") do
          true -> 
            ref_map = load_schema props[key]["$ref"]
            #IO.puts inspect ref_map, pretty: true
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
              "integer" ->
                "#{key}: #{props[key]["default"]}"
              "boolean" ->
                "#{key}: #{props[key]["default"]}"
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
