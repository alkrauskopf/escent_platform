class AddItlOrgOptionTeacherFinalize < ActiveRecord::Migration
  def self.up

    add_column  :itl_org_options, :is_teacher_finalize, :boolean
    execute "UPDATE itl_org_options SET is_teacher_finalize = 0"
  end

  def self.down
    remove_column  :itl_org_options, :is_teacher_finalize
  end
end
