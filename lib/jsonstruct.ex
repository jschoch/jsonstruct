defmodule Mix.Tasks.Jsst do
  require Logger
  use Mix.Task
  alias Jsonstruct, as: J
  def run(args) do
    case Mix.env do
      :test -> 
        raise "what was i going to do with this?>>>..."
      _ ->
        arg = List.first args
        options = do_options()
        J.do_dir(arg,options) 
    end
  end
  def do_options do
    case Application.get_env(:jsonstruct,:template) do
      nil -> [template: J.templ()]
      x when is_binary(x) -> [template: File.read!(x)]
      horror -> raise "no template specified, config error"
    end
  end
end

defmodule Jsonstruct do
  require Logger
  def load_schema(uri) do
    parse_file(uri)
      |> ExJsonSchema.Schema.resolve
  end

  @doc "this looks for example.com and uses it as a signal to grab a file since i'm too lazy to figure out why most libs dont' use file uri correctly...."
  def parse_file_name(<< "http://example.com" :: binary, stuff :: binary >>) do
    "./" <> stuff 
  end
  def parse_file_name(file) do
    Logger.debug "missed: " <> inspect file
    file
  end

  def parse_file(uri) do
    Logger.debug "parse_file: " <> inspect uri
    file_name = parse_file_name(uri)
    File.read!(file_name) 
      |> Poison.decode!
  end

  def do_dir(dir \\"./schema",options) do
    case File.exists?(dir) do
      true ->
        Enum.each(File.ls!(dir), fn file ->
          gen(dir <> "/" <> file, options) 
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
  def gen(file,module_name \\nil,options) do
    Logger.debug "gen loading file: #{file} #{module_name}"
    schema = load_schema(file)
    module_name = if (module_name == nil) do
      gen_mod_name(schema)
    end
    #IO.puts inspect schema, pretty: true
    templ = options[:template]
    props = schema.schema["properties"] 
    #keys = Map.keys props
    fields = walk(props)
      |> Enum.join(",")
    t = templ
    s = EEx.eval_string( t,fields: fields,module: module_name)
    File.write!("lib/#{module_name}_jsst_struct.ex",s)
  end
  def walk_key(props = %{"$ref" => list},key) when is_list(list) do
    [ref] = list
    ref_map = load_schema ref
    "#{key}: %#{gen_mod_name(ref_map)}{}"
  end
  def walk_key(props = %{"$ref" => ref},key) do
    ref_map = load_schema ref
    "#{key}: %#{gen_mod_name(ref_map)}{}"
  end
  def walk_key(props = %{"anyOf" => list},key) do
    #"#{key}: %#{gen_mod_name(ref_map)}{}"
    "#{key}: nil"
  end
  def walk_key(props ,key) do
    #Logger.debug inspect {props,key}
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
      nil ->
        walk_key(props[key],key)
      horror -> raise "unknown prop type: #{key} " <> inspect horror, pretty: true
    end
  end
  def walk(props) do
    keys = Map.keys props
    Enum.map(keys,fn(key) ->
        #IO.puts "KEY: " <> inspect props[key], pretty: true
        walk_key(props,key)
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
