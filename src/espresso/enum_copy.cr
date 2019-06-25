module Espresso
  # Mix-in module providing macros for copying enums.
  module EnumCopy
    # Copies an enum defined in LibGLFW and exposes through Espresso.
    private macro copy_enum(name, source_name)
      \{% begin %}
        enum {{name.id}}
        \{% for e in LibGLFW::{{source_name.id}}.constants %}
          \{{e.id}} = LibGLFW::{{source_name.id}}::\{{e.id}}
        \{% end %}
        end
      \{% end %}
    end

    # Copies an enum defined in LibGLFW and exposes through Espresso.
    private macro copy_enum(name)
      copy_enum({{name}}, {{name}})
    end
  end
end
