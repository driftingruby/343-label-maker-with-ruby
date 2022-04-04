class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.integer :tweet_id
      t.datetime :tweeted_at
      t.string :username
      t.text :content
      t.boolean :printed, default: false

      t.timestamps
    end
    add_index :tweets, :tweet_id
  end
end
