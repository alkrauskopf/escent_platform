class AddActiveGenres < ActiveRecord::Migration
  def up
    add_column :act_genres, :is_active, :boolean, :default => false

    execute "UPDATE act_genres SET is_active = 1"
  end

  def down
    remove_column :act_genres, :is_active
  end
end
