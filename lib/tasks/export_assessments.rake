namespace :db do
  desc "Export assessments from user to a JSON file, suitable for importing"

  task :export_assessments, [:email] => :environment do |t,args|

    email = args[:email]
    migrate_filename = "#{email}/assessments.json"

    # Getting User
    user = User.find_by(email: email)

    assessments = Assessment.assessments_for_user(user)

    export_data = Assessments::ExportData.new(user, assessments).in_json!

    S3Wrapper.store(
      filename: migrate_filename,
      content: export_data,
      content_type: "application/json"
    )
  end
end
