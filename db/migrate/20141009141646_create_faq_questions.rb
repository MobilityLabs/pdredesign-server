class CreateFaqQuestions < ActiveRecord::Migration
  def change
    create_table :faq_questions do |t|
      t.integer :tool_id
      t.string  :role
      t.string  :status
      t.string  :content
      t.string  :answer

      t.timestamps
    end
  end
end
