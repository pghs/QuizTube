class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :question
      t.integer :lesson_id
      t.integer :clip_start_time
      t.integer :clip_end_time

      t.timestamps
    end
  end
end
