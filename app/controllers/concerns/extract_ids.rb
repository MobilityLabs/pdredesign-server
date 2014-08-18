module ExtractIds 
  extend ActiveSupport::Concern

  def extract_ids_from_params(key)
    return '' unless params[key]
    return fixnum_to_ids(params[key]) if params[key].is_a?(Numeric)
    params[key].split(",")
  end

  private
  def fixnum_to_ids(num)
    [num] 
  end
end
