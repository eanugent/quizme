class AddUuidToGames < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :uuid, :uuid, default: "gen_random_uuid()", null: false
    rename_column :games, :id, :integer_id
    rename_column :games, :uuid, :id
    execute "ALTER TABLE games drop constraint games_pkey;"
    execute "ALTER TABLE games ADD PRIMARY KEY (id);"

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute "ALTER TABLE ONLY games ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :games, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS games_id_seq"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
