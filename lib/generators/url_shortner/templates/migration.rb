class CreateShortenedUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :url_shortner_shortened_urls do |t|
      t.text :url, null: false, length: 2083
      t.string :short_url, limit: 10, null: false

      t.timestamps
    end

    # we will lookup the links in the db by key, urls and owners.
    # also make sure the unique keys are actually unique
    add_index :shortened_urls, :short_url, unique: true
    add_index :shortened_urls, :url, length: 2083
  end
end
