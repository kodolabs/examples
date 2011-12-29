class ReferenceNumberValidator < ActiveModel::EachValidator
  VALIDATORS = [/^(\d+)-(\d+)$/, /^(\d+)-(\d+)-(\d+)$/]

  def validate_each(record, attribute, value)
    organisation = nil

    # validates format of the reference  number
    # and correctness of it's data - presence of organisation name, user ID and PGD ID
    #
    if VALIDATORS.collect{|e| value =~ e}.select{|e| e != nil}.count > 0
      if (match = value.match(VALIDATORS[0]))
        # organisation - credits
        organisation = Organisation.find_by_number(match[1].to_i)
        credits = match[2].to_i

        record.errors[attribute] << 'Invalid credits value' unless credits > 0
      elsif (match = value.match(VALIDATORS[1]))
        # organisation - pharmacist - PGD
        organisation  = Organisation.find_by_number(match[1].to_i)
        user          = User.find_by_id(match[2].to_i)
        pgd           = Pgd.find_by_id(match[3].to_i)

        record.errors[attribute] << 'contains invalid user ID' if user.blank?
        record.errors[attribute] << 'contains invalid PGD ID' if pgd.blank?
      end

      record.errors[attribute] << "contains invalid organisation number: #{value}" if organisation.blank?
    else
      record.errors[attribute] << "has invalid format"
    end
  end
end