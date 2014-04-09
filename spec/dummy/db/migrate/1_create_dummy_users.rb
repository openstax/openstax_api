class CreateDummyUsers < ActiveRecord::Migration
  def change
    create_table :dummy_users do |t|
      t.string :username
      t.string :password_hash

      t.timestamps
    end
  end
end
