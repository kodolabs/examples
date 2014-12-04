class Helper
  object_to_string: (obj)->
    collection = _.map obj, (k, v)->
        v + ' ' + k if v? && k?
    collection.join(', ')

window.Helper = Helper
