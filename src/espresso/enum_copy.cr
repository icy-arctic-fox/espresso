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

          protected def native
            LibGLFW::{{source_name.id}}.new(to_i)
          end
        end
      \{% end %}
    end

    # Copies an enum defined in LibGLFW and exposes through Espresso.
    private macro copy_enum(name)
      copy_enum({{name}}, {{name}})
    end

    # Copies a flags enum defined in LibGLFW and exposes through Espresso.
    private macro copy_enum_flags(name, source_name)
      \{% begin %}
        @[Flags]
        enum {{name.id}}
        \{% for e in LibGLFW::{{source_name.id}}.constants %}
          \{% if e != "All".id && e != "None".id %}
            \{{e.id}} = LibGLFW::{{source_name.id}}::\{{e.id}}
          \{% end %}
        \{% end %}

          protected def native
            LibGLFW::{{source_name.id}}.new(to_i)
          end
        end
      \{% end %}
    end

    # Copies a flags enum defined in LibGLFW and exposes through Espresso.
    private macro copy_enum_flags(name)
      copy_enum_flags({{name}}, {{name}})
    end
  end
end
