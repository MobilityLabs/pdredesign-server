class CreateFaqQuestions < ActiveRecord::Migration
  def up
    create_table :faq_categories do |t|
      t.string  :heading
      t.timestamps
    end

    create_table :faq_questions do |t|
      t.string  :role
      t.string  :topic
      t.integer :category_id
      t.text    :content
      t.text    :answer

      t.timestamps
    end
  end

  def down
    drop_table :faq_questions
    drop_table :faq_categories
  end
end
