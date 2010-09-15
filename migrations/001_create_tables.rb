class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :games, :force => true do |t|
      t.string :name
      t.string :token
      t.text :words
      t.text :messages, :default => ''
      t.string :winner
      t.datetime :won_at
      t.timestamps
    end
    
    create_table :cards, :force => true do |t|
      t.integer :game_id
      t.string :name
      t.text :words
      t.text :found
      t.timestamps
    end
    
    add_index :games, :token
  end

  def self.down
    drop_table :cards
    drop_table :games
  end
end