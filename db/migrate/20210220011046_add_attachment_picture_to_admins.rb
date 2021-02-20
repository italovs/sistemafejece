class AddAttachmentPictureToAdmins < ActiveRecord::Migration[5.0]
  def self.up
    change_table :admins do |t|
      t.attachment :picture
    end
  end

  def self.down
    remove_attachment :admins, :picture
  end
end
