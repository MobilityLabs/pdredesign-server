module ExtractIds 
  extend ActiveSupport::Concern

  def extract_ids_from_params(key)
    return '' unless params[key]
    params[key].split(",")
  end
end
