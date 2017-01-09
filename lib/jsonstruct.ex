defmodule Mix.Tasks.Jsst do
  require Logger
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
  require Logger
  def load_schema(file \\"schema/user.json") do
    File.read!(file)
      |> Poison.decode!
      |> ExJsonSchema.Schema.resolve
  end
  def do_dir(dir \\"./schema") do
    case File.exists?(dir) do
      true ->
        Enum.each(File.ls!(dir), fn file ->
          gen(dir <> "/" <> file) 
        end)
      false -> raise "./schema not found"
    end
  end
  def gen_mod_name(schema) do
    name = schema.schema["title"] |> String.split(" ") |> Enum.join() |> Inflex.camelize
    case Regex.match?(~r/^[A-Z]/,name) do
      true -> 
        name
      false -> raise "illegal module name #{name}"
    end
  end
  def gen(file,module_name \\nil) do
    Logger.debug "loading file: #{file} #{module_name}"
    schema = load_schema(file)
    module_name = if (module_name == nil) do
      gen_mod_name(schema)
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
            "#{key}: %#{gen_mod_name(ref_map)}{}"
          _ ->
            case props[key]["type"] do
              "string" ->
                #"#{key}: \"#{props[key]["default"]}\""
                handle_str(key,props[key]["default"])
              "array" ->
                "#{key}: []"
              "object" ->
                props = props[key]["properties"]
                inner = walk(props) |> Enum.join(",")
                "#{key}: %{#{inner}}"
              "integer" ->
                handle_int(key,props[key]["default"])
              "boolean" ->
                "#{key}: #{props[key]["default"]}"
              horror -> raise "unknown prop type: #{}" <> inspect horror, pretty: true
            end
        end
      end) 
  end
  def handle_int(key,nil) do
    "#{key}: nil"
  end
  def handle_int(key,i) do
    "#{key}: #{i}"
  end
  def handle_str(key,nil) do
    "#{key}: nil"
  end
  def handle_str(key,i) do
    "#{key}: \"#{i}\""
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
