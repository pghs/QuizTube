class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name
      t.text :media_url
      t.integer :user_id

      t.timestamps
    end
  end
end
