
module.exports = (record_schema) ->
  record_schema.statics.getRoute = (profile, routes) ->
    {age, sex} = profile
    guest_routes = routes?.filter (route) ->
      route.sex is sex and (route.age_lt < age*1 or not route.age_lt? or age is '#') and (route.age_ut > age*1 or not route.age_ut? or age is '#')
    guest_routes = guest_routes.map (item) -> item._id
    n= Math.floor(Math.random()*guest_routes.length+1)-1
    guest_routes?[n]
