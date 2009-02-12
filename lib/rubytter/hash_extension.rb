class Hash
  def to_struct
    struct_values = []
    struct_attrs = []

    each do |k, v|
      case k
      when String, Symbol
        struct_values <<  case v
                          when Hash
                            v.to_struct
                          when Array
                            v.map{|i| i.to_struct}
                          else
                            v
                          end
        (v.is_a?(Hash) ? v.to_struct : v)
        struct_attrs << k.to_sym
      end
    end

    unless struct_attrs.empty?
      Struct.new(*struct_attrs).new(*struct_values)
    else
      nil
    end
  end
end
