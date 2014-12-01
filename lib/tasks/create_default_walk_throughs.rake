require 'rake'

module DefaultWalkThrough
  def self.final_slide
<<-END
  <div class="info">
    <p>
      Learn more about leading the Readiness Assessment.
    </p>
    <a href="slide-5.html" class="btn btn-primary" role="button">Facilitator walkthrough</a>
  </div>

    <div class="info">
    <p>
      Lead the Readiness Assessment in your district.
    </p>
    <a ui-sref="assessments" ng-click="close()" class="btn btn-primary" role="button">Start an Assessment</a>
  </div>

    <div class="info">
    <p>
      Tell a colleague about the Readiness Assessment.
    </p>
    <a href="mailto:support@mail.pdredesign.org" class="btn btn-primary" role="button">Open Email</a>
  </div>

  <div class="info">
    <p>
      Have more questions?
    </p>
    <a ui-sref="faqs" ng-click="close()" class="btn btn-primary" role="button">FAQ</a>
  </div>
END

  end

  def self.slides
    [
      {
        title: "What is the Readiness Assessment?",
        image: "slide-0.gif",
        sidebar_content: "<p>The Readiness Assessment is a tool to support school districts to gather feedback from leaders and teachers about the current state of a professional development system and build consensus to redesign systems to meet the needs of educators and students.</p><p>This collaborative survey was co-designed with school districts to understand strengths and limitations across key areas of a professional development system.</p>"
      },
      {
        title: "It starts with a survey",
        image: "slide-1.gif",
        sidebar_content: "<p>A team of individuals from different roles and departments rate the teacher professional development program in their district and provide evidence.</p>"
      },
      {
        title: "Consensus is reached",
        image: "slide-2.gif",
        sidebar_content: "<p>After individuals have provided feedback, the team meets in person and discusses the responses to understand current strengths, limitations, and opportunities to deepen connections between departments to better support teachers.</p>"
      },
      {
        title: "Results are reported",
        image: "slide-3.gif",
        sidebar_content: "<p>The Readiness Assessment tool will generate a shareable report summarizing the consensus discussion and suggesting next steps to improve PD programs in the district.</p>"
      },
      {
        title: "Next Steps",
        content: self.final_slide,
        sidebar_content: "<p>You've completed the basic overview! For more detailed information view the content on the left.</p>"
      }
    ]
  end

  def self.open_image_file(path)
    File.open(Rails.root.join("lib", "tasks", "walk_throughs", path))
  end

  def self.create_image_slide(slide)
    new_slide = WalkThrough::ImageSlide.create(
      title: slide[:title],
      sidebar_content: slide[:sidebar_content])

    new_slide.tap do
      new_slide.image = open_image_file(slide[:image])
      new_slide.save!
    end
  end

  def self.create_html_slide(slide)
    WalkThrough::HtmlSlide.create(
      title: slide[:title],
      sidebar_content: slide[:sidebar_content],
      content: slide[:content])
  end

  def self.create
    container = WalkThrough::Container.create(title: "What is the Readiness Assessment?")
    slides.each do |slide|

      if slide[:image]
        new_slide = create_image_slide(slide)
      else
        new_slide = create_html_slide(slide)
      end

      container.slides << new_slide
      puts "Created #{slide[:title]} id: #{new_slide[:id]} container id: #{container[:id]}"
    end

  end
end

namespace :db do
  desc "Create all default WalkThrough records"
  task :create_default_walk_throughs => :environment do
    ActiveRecord::Base.transaction do
      WalkThrough::Container.destroy_all
      DefaultWalkThrough::create()
    end
  end
end
