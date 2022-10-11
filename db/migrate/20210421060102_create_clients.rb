class CreateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :platform
      t.string :public_key
      t.string :secret_key
      t.decimal :amount
      t.string :account
      t.string :password
      t.string :str1
      t.integer :int1
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
    add_index :clients, :name
    add_index :clients, :platform
    add_index :clients, :public_key,   unique: true
    add_index :clients, :secret_key,         unique: true
    add_index :clients, :account,                unique: true
  end
end
