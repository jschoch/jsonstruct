ExUnit.start()

defmodule JsstND do
  defstruct outer1: %{innerK1: nil,innerK2: nil},outer2: nil
  use ExConstructor
end
