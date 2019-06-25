require "./enum_copy"

module Espresso
  include EnumCopy

  @[Flags]
  copy_enum ModifierKey
end
