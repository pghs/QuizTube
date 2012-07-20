class AddImageurlToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :imageurl, :string
  end
end
