class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.text :answer
      t.boolean :correct

      t.timestamps
    end
  end
end
