class CreateLearningQuestions < ActiveRecord::Migration
  def change
    create_table :learning_questions do |t|
      t.references :assessment
      t.references :user
      t.text :body, limit: 255
      t.timestamps null: false
    end

    add_index :learning_questions, :assessment_id
    add_index :learning_questions, :created_at
  end
end
