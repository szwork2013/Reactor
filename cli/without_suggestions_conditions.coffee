models = require '../models'
_      = require 'underscore'

models 'test.healskare.com', (error, models, settings) ->
  {Record, SuggestionGroup, Department} = models
  Department.findOne({'name': '放射科'})
  .exec (error, department) ->
    return console.log error.stack if error
    items = department.items
    department_conditions = []
    for item in items
      for condition in item.conditions
        department_conditions.push condition.name
    SuggestionGroup.findOne({name: '放射科'})
    .exec (error, suggestiongroup) ->
      return console.log error.stack if error
      suggestiongroup_conditions = []
      for suggestion in suggestiongroup.suggestions
        for condition in suggestion.conditions
          suggestiongroup_conditions.push condition
      conditions = _.difference(department_conditions, suggestiongroup_conditions)
      console.log conditions
      process.exit()
