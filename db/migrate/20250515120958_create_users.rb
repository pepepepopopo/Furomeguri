class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.text :email
      t.text :crypted_password
      t.integer :salt

      t.timestamps
    end
  end
end
