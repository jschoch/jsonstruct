# Jsonstruct

Use this to derive structs from json schema.  The idea is to limit the number of places data structures are defined.  The initial use case for this is for elixir-lang elm-lang interop where client and server can derive structures from a single set of json schemas.

This currently works with dragonwasrobot/json-schema-to-elm which compiles your schemas to elm types.  When also paired with ex_json_schema you get a single type definition between elixir and elm

You can also create custom templates for the generator.

### Warnings

No idea how to implement pattern properties!

arrays default to []

no circular ref checking, don't do that!


## This is an expiriment, contributors, comments, ideas welcome....

### Getting Started

## tests

run `mix jsst test/schema` to ensure the test structs are created, a bit of chicken or egg.  you can also just run the tests twice after the initial clone/fork

## plain old usage

1. install in your mix.exs 
2. create a dir `./schema`
3. add some json schema and ensure there are no pattern properties
4. ensure the root title matches the module name you expect for your structs
5. run `mix jsst` and this will create struct definitions in `./lib/#{module_name}_jsst_struct`
6. if you don't like using `./schema` pass the schema dir as an arg to the mix task
`mix jsst my_fancy_schema_dir`


## Example

Here is an example schema with a file ref

```js
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "title": "JsstRef",
  "description": "test ref schema for jsonstruct.",
  "properties": {
    "test": {
      "$ref": "test/schema/test.json"
    },
    "type": {
      "type": "string",
      "title": "Type schema.",
      "description": "type",
      "default": "person"
    },
    "bool":{
          "type": "boolean",
          "title": ".",
          "description": ".",
          "default": true
     },
     "int":{
          "type": "integer",
          "title": ".",
          "description": ".",
          "default": 0
     }
  },
  "required": [
    "test",
    "type",
    "bool",
    "int"
  ]
}

```

and this is the reference schema

```js
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "title": "JsstBar",
  "description": "test schema for jsonstruct.",
  "properties": {
    "name": {
      "type": "string",
      "title": "Name schema.",
      "description": "string.",
      "default": "bob"
    },
    "type": {
      "type": "string",
      "title": "Type schema.",
      "description": "type",
      "default": "person"
    },
    "props": {
      "type": "array",
      "title": "Props schema.",
      "description": ".",
      "items": {
        "type": "integer",
        "title": "2 schema.",
        "description": ".",
        "default": 3
      }
    }
  },
  "required": [
    "name",
    "type",
    "props"
  ]
}

```


this should produce the following in `./lib/JsstRef_jsst_struct.ex`

```elixir
defmodule JsstRef do
  defstruct bool: true,int: 0,test: %JsstBar{},type: "person"
  use ExConstructor
end
```

and `./lib/JsstBar_jsst_struct.ex`

```elixir
defmodule JsstBar do
  defstruct name: "bob",props: [],type: "person"
  use ExConstructor
end
```

### Custom Templates

Add a template param to your :jsonschema config to change the default template

```elixir
defmodule <%= module %> do
  # add to all templates
  @derive ExAws.Dynamo.Encodable  

  defstruct <%= fields %>
  use ExConstructor
end

```


### TODO
 
* configurable ignore of . files like vim swap files
* better configure how defaults or lack of defaults in a schema behave
* config option for remote resolver of $ref
* create .jsstlock file to track out of band changes
* some param to govern if a out of band edit should be overwriten
* interactive y/n propt to overrwite out of band edited file based on config
* circular ref checks
* ensure all json schema types are handled
* publish to hex

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

