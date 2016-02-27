class ArrayEnumValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless options[:enum]
      record.errors.add(:base, 'Precondition failed: enum option required')
      return
    end
    if value.nil?
      record.errors.add(:base, 'Precondition failed: value is nil')
      return
    end

    if options[:flat]
      unless options[:enum].values.include?(value)
        record.errors.add(attribute, "#{value} is not permissible")
      end
    else
      value.each do |type|
        unless options[:enum].values.include?(type)
          record.errors.add(attribute, "#{type} is not permissible")
        end
      end
    end
  end
end
