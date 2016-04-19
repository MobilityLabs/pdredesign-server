module InviteToolMessageHelper
  def default_assessment_message
    'The goal of this assessment is to discuss professional development and determine areas of strength or limitations within your district. To participate along with your colleagues, you must first register with the PD Readiness Assessment Tool. Once registered, you’ll be able to answer the questions and have on-going access to the assessment discussions.'
  end

  def default_inventory_message
    "The goal of this inventory is to get the big picture of data and technology systems that support professional learning in your district. The inventory will be followed by an in-person discussion of how well current data systems, technology infrastructure, and product purchases are aligned to professional development goals.

    To participate along with your colleagues, you must first register with the PDredesign. Once registered, you'll be able to fill out the inventory and have ongoing access to the inventory, assessment and results. Please contact #{current_user.name} with any questions at #{current_user.email}."
  end
end
