class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_hash, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :users, :username
    add_index :users, :name
    add_index :users, :email
  end
end
