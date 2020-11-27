class Object
  def self.instance_methods
    {% begin %}
    [
      {% for m in @type.methods %}
        {
          visibility: {{m.visibility.stringify}},
          name: {{m.name.stringify}},
          double_splat: {{m.double_splat.stringify}},
          splat_index: {{m.splat_index.id}},
          return_type: {{m.return_type.stringify}},
          arguments: [
            {% for a in m.args %}
              {
                name: {{a.name.stringify}},
                internal_name: {{a.internal_name.stringify}},
                restriction: {{a.restriction.stringify}},
                default_value: {{a.default_value.stringify}}
              },
            {% end %}
          ] of NamedTuple(name: String, internal_name: String, restriction: String, default_value: String),
          {% if m.block_arg.stringify != "" %} 
            block_arguments: [
              {% for a in m.block_arg.restriction.inputs %}
                {{a.stringify}},
              {% end %}
            ],
            block_returns: {{m.block_arg.restriction.output.stringify}},
          {% else %}
            block_argument: [] of String,
            block_returns: "",
          {% end %}
          body: {{m.body.stringify}}
        },
      {% end %}
    ] of NamedTuple(visibility: String, name: String, double_splat: String, splat_index: Nil, return_type: String, arguments: Array(NamedTuple(name: String, internal_name: String, restriction: String, default_value: String)), block_arguments: Array(String), block_returns: String, body: String)

    {% end %}
  end
end
