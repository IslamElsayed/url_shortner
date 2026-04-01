class CreateShortenedUrls < ActiveRecord::Migration[6.1]
  def change
    create_table :url_shortner_shortened_urls do |t|
      t.text :url, null: false
      t.string :short_url, limit: 10, null: false

      t.timestamps
    end

    add_index :url_shortner_shortened_urls, :short_url, unique: true
    add_index :url_shortner_shortened_urls, :url, length: 2083
  end
end
