#= require_self
#= require ./helper
#= require_tree ./templates

#= require ./models/outcome
#= require ./models/outcomes
#= require ./models/teacher
#= require ./models/teachers
#= require ./models/post
#= require ./models/parent
#= require ./models/parents
#= require ./models/student
#= require ./models/students
#= require ./models/upload
#= require ./models/klass
#= require ./models/klasses


#= require ./views/sidebar
#= require ./views/post_empty
#= require ./views/parents_empty
#= require ./views/klasses_empty
#= require ./views/timeline_empty
#= require ./views/teachers_empty
#= require ./views/gallery_item
#= require ./views/parent
#= require ./views/nostudents
#= require ./views/timeline_item
#= require ./views/student
#= require ./views/teacher
#= require ./views/klass_teachers_row
#= require ./views/klass_teachers

#= require_tree ./services
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Wondr =
  Models: {}
  Collections: {}
  Services: {}
  Routers: {}
  Views: {}
