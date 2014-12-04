Wondr.Services.Comparator = class
  name_comparator: (a, b, direction, association = null) ->
    direction = if direction == 'asc' then -1 else 1
    a = @base_comparing_value(a, association, 'first_name', 'last_name')
    b = @base_comparing_value(b, association, 'first_name', 'last_name')
    direction * if a > b then 1 else if a < b then -1 else 0

  # (object, association, attr_name1[, attr_name2[, ...]]) => object.association.joined_attrs_values
  base_comparing_value: (object, association = null)->
    attrs = _.toArray(arguments)[2..-1]
    if association
      if object.get(association)[0]
        (object.get(association)[0][attr] for attr in attrs).join(' ')
      else
        ''
    else
      (object.get(attr) for attr in attrs).join(' ')
