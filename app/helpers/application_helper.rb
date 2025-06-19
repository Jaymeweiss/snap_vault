module ApplicationHelper
  def react_component(component_name, props = {}, html_options = {})
    html_options = html_options.dup
    html_options[:data] ||= {}
    html_options[:data][:react_component] = component_name
    html_options[:data][:react_props] = props.to_json unless props.empty?

    content_tag(:div, "", html_options)
  end
end
