class AddFaqQuestions < ActiveRecord::Migration
  def create_ra_questions
    questions = [{content: "What is the Readiness Assessment?",
answer: "The Readiness Assessment is a collaborative diagnostic tool to support school districts to understand the current state of their professional development system and build consensus around priorities for growth. This formative assessment consists of an individual online survey followed by a facilitated, in-person consensus meeting of district staff across roles and departments. The Readiness Assessment is designed to be used at the beginning of a redesign process, but can be used at any stage of an initiative to support continuous improvement."},

{content: "Can I view the Readiness Assessment questions without starting an assessment?",
answer: "Yes, the questions and rubric may be found in the Facilitation Guide (http://pdredesign.org/assets/PDRedesign%20RA%20Facilitation%20Guide.pdf)."},

{content: "Who should take on the facilitator role for my district?",
answer: "The person in this role guides the district cross-team through the assessment process by building the team, leading and documenting the consensus meeting, and supporting the team to take next steps. To ensure a rich, open dialogue, the facilitator should be an objective colleague or a trusted partner who is committed to improving professional development in the district. The role may be shared between two or more people. If you would like an existing member of your district to share the facilitator role, email support@mail.pdredesign.org to have us upgrade their account."},

{content: "Can our district have more than one facilitator?",
answer: "Yes, more than one person can share the facilitator role for a district. If you would like an existing member of your district to share the facilitator role, email support@mail.pdredesign.org to have us upgrade their account."},

{content: "Can an external partner help facilitate the Readiness Assessment?",

answer: "Yes, partners from outside of a district may be invited to help organize the Readiness Assessment or to see the summary report once the assessment is complete. These network partners may include any state or regional agencies, associations, funders, or technical assistance providers that support a district."},

{content: "How can I learn more about best practices as the facilitator? ",
answer: "We recommend reviewing the Facilitation Guide to learn more about preparing for the consensus meeting, guiding the discussion to come to a common understanding of the current system, and moving toward next steps to drive continuous improvement."},

{content: "Whom should I invite to the Readiness Assessment cross-team?",
answer: "We recommend inviting 1-2 representatives from different roles and functions involved with PD, including: Teaching & Learning, Human Resources, Curriculum & Instruction, Data & Accountability, Finance, IT, teachers, and principals."},

{content: "Our IT department says we cannot receive emails from support@mail.pdredesign.org. What can we do?",
answer: "Ask your IT department to contact support@mail.pdredesign.org. We will work with them to find a solution for your district."},

{content: "My cross-team members say they completed the assessment. Why does their status still say in progress?",
answer: "Assessments are shown as in progress until the submit button is pressed, even if all the questions have been answered and saved. Ask your team member to go back and press the submit button within the assessment."},

{content: "As a facilitator, can I look at the assessments my team members have filled out?",
answer: "Once you choose to create the consensus response, you are able to see your team members' answers within a single view. This will close the individual assessments for editing. Before this step, you will be able to view the status of individual assessments but not the content."},

{content: "Who can see the strengths and limitations in the Readiness Assessment report for my district?",
answer: "Once your team has had the consensus meeting, the entire team will be able to access your Readiness Assessment Report that will show your strengths and limitations. If your facilitator has opted to invite an external partner, that partner will see the same completed report."},

{content: "Why is the consensus meeting important?",
 answer: "We highly recommend the consensus meeting to engage the team in planning and implementation of redesigned professional development. Following the individual assessment, the consensus discussion provides an opportunity to share insights, build alignment across departments, and develop a strong plan based on common priorities. "},

{content: "Does every member of the cross-team need to join the consensus meeting?",
answer: "We recommend ensuring representation from a variety of roles and departments for a rich discussion. One person may present at the consensus meeting on behalf of participants with a similar perspective (e.g., if five principals participate in the assessment, you may only want to invite one or two to the consensus meeting). "},

{content: "Does the consensus meeting need to cover every question in the Readiness Assessment?",
answer: "The consensus discussion should be guided by the goals, challenges, and priorities of the district. In the consensus view, you may sort the responses by the category, the number of people who responded, or the degree of variance between responses to support a targeted discussion. "},
]
    create_questions('The Readiness Assessment', questions)
  end

  def create_adding_tools
    questions = [
  {content:"What types of tools can I add to the toolkit?", answer:"You may add tools that support a district to collaborate across departments and roles to strategically implement redesigned PD systems. Tools may support current state analysis, change management planning, procurement processes, or implementation."},
  {content:"Who sees the tools I add to the toolkit?", answer:"Any districts that you have added to your profile may see the tools you add."}
]
    create_questions('Adding Tools', questions)
  end

  def create_getting_started
questions = [
  {content: "I'm a partner organization working with multiple districts. How many districts can I add?", answer: "You may add any districts in your network. There is no limit to the number of districts you may add to your profile."},
  {content: "I work with a Charter Management Organization or independent school. Can I use the PDredesign toolkit with my colleagues?", answer: "Yes, you may use the PDredesign toolkit to support teacher professional development in your charter or independent school. "},
  {content: "How do I remove an assessment?", answer: "To remove an assessment, please contact support@mail.pdredesign.org. "},
  {content: "Why doesn't PDredesign work with my browser?", answer: "PDRedesign relies on technology that requires updated browsers. If you are using an older version of Internet Explorer, Firefox, Chrome, or Safari, please update. For information on how to update your browser please go here: http://browser-update.org/update.html"}
]

    create_questions('Getting Started', questions)
  end

  def create_questions(category_heading, questions)
    category = Faq::Category.create!(heading: category_heading)
    questions.each do |question|
      Faq::Question.create!(content: question[:content], 
        answer: question[:answer],
        category: category)
      puts "created #{question[:content]}"
    end
  end

  def up
    create_ra_questions
    create_adding_tools
    create_getting_started
  end

  def down
    Faq::Question.destroy_all
    Faq::Category.destroy_all
  end
end
