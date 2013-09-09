module AuthoritiesHelper
  def attribute_value(value)
    if value.kind_of?(Array)
      value.map{|v| attribute_value(v)}.join.html_safe
    elsif value.class.respond_to?(:attribute_names)
      attribute_table(value)
    else
      h(value)
    end
  end

  def attribute_table(model)
    content_tag(:table, :class => "scraper_fields") do
      model.class.attribute_names.map do |name|
        content_tag(:tr) do
          content_tag(:td, h(name), :class => "field") + content_tag(:td, attribute_value(model.attributes[name]))
        end
      end.join.html_safe
    end
  end

  def attribute_error_value(value)
    if value.kind_of?(Array)
      first_errored = value.find{|v| !v.valid?}
      if first_errored
        attribute_error_value(first_errored)
      else
        content_tag(:p, "&hellip;".html_safe)
      end
    elsif value.class.respond_to?(:attribute_names)
      attribute_error_table(value)
    else
      h(value)
    end
  end

  def attribute_error_table(model)
    content_tag(:table) do
      content_tag(:tr) do
        content_tag(:th, "Field") + content_tag(:th, "Value") + content_tag(:th, "Errors")
      end + 
      model.class.attribute_names.map do |name|
        content_tag(:tr) do
          content_tag(:td, h(name)) + content_tag(:td, attribute_error_value(model.attributes[name])) +
            content_tag(:td, content_tag(:span, model.errors[name].join(", "), :class => "highlight"))
        end
      end.join.html_safe
    end
  end
end
