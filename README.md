# Jsonstruct

**description

## this is barely working, contributors welcome....

install in your mix.exs and do the old mix deps.get
create a dir `./schema`
add some json schema and ensure there are no pattern properties
ensure the root title matches the module name you expect for your structs
run `mix jsst` and this will create struct definitions in `./lib/#{module_name}_jsst_struct`
if you don't like usine `./schema` pass the schema dir as an arg to the mix task
`mix jsst my_fancy_schema_dir`

### TODO
 
  test with hex and or archive install

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `jsonstruct` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:jsonstruct, "~> 0.1.0"}]
    end
    ```

  2. Ensure `jsonstruct` is started before your application:

    ```elixir
    def application do
      [applications: [:jsonstruct]]
    end
    ```

