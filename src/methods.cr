class Object
  def methods
    {% begin %}
    [
      {% for m in @type.methods %}
        {
          visibility: {{m.visibility.stringify}},
          receiver: {{m.receiver.stringify}},
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
          ]
        },
      {% end %}
    ] of NamedTuple(visibility: String, receiver: String, name: String, double_splat: String, splat_index: Int32?, return_type: String, arguments: Array(NamedTuple(name: String, internal_name: String, restriction: String, default_value: String)))
    {% end %}
  end
end
