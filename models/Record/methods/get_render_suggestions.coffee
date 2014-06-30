_ = require 'underscore'

module.exports = (record_schema) ->
        
  record_schema.methods.get_render_suggestions = () ->
    suggestions = @suggestions.map (s) -> s.toJSON()
    for suggestion in suggestions
      conditions = ''
      count = suggestion.conditions.length
      for condition in suggestion.conditions
        name = condition.detail or condition.name
        name = name.replace /[\w\.\×\-\s]+/g, ($0) -> "<span class = 'more'>"+ $0 + "</span>"
        name = '<span>• ' + name + '</span>' if count > 1
        conditions += name
        delete suggestion.conditions
        suggestion.conditions = conditions
    suggestions
