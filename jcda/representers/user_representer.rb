require 'roar/decorator'
require 'roar/json'
require 'representable/hash'

class UserRepresenter < Roar::Decorator
  include Roar::JSON

  property :id
  property :email
  property :login
  property :first_name
  property :last_name
  property :role, exec_context: :decorator

  def role
    return if represented.role.nil?
    represented.role.name.downcase.gsub(/ /, '_')
  end

end
