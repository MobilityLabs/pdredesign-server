class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && value < Time.now
      record.errors.add(attribute, options[:message] || 'cannot be in the past')
    end
  end
end