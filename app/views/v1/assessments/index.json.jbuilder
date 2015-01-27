json.array! @assessments do |assessment|
  json.cache! ['v1', current_user.id, assessment] do
    json.partial! 'v1/assessments/assessment', 
                  assessment: assessment

    json.links           Link::Assessment.new(assessment, current_user).execute
    json.response_link   Link::Response.new(assessment, current_user).execute

    json.subheading do
      subheading = Assessments::Subheading.new(assessment, current_user)
      json.text         subheading.message
      json.participants subheading.users do |member|
        json.partial! 'v1/shared/user', user: member
      end
    end
  end
end
