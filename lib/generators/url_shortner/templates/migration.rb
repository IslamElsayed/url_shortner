class CreateShortenedUrls < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :url_shortner_shortened_urls do |t|
      t.text   :url,        null: false
      # SHA-256 of the url. Indexed in place of the url itself, which no
      # adapter can index at unbounded length: PostgreSQL rejects a btree
      # entry over ~2704 bytes, and the previous `length: 2083` option was
      # silently ignored everywhere except MySQL.
      t.string :url_digest, null: false, limit: 64
      t.string :short_url,  null: false, limit: 32

      t.timestamps
    end

    add_index :url_shortner_shortened_urls, :short_url,  unique: true
    add_index :url_shortner_shortened_urls, :url_digest, unique: true
  end
end
