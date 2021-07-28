class AddJuniorEnterpriseIdToActualMonth < ActiveRecord::Migration[6.0]
  def change
    add_reference :actual_months, :junior_enterprise, null: false, foreign_key: true
  end
end
