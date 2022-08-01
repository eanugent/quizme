class AddUuidToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :uuid, :uuid, default: "gen_random_uuid()", null: false
    rename_column :players, :id, :integer_id
    rename_column :players, :uuid, :id
    execute "ALTER TABLE players drop constraint players_pkey;"
    execute "ALTER TABLE players ADD PRIMARY KEY (id);"

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute "ALTER TABLE ONLY players ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :players, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS players_id_seq"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
