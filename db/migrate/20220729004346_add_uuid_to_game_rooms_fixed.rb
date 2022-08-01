class AddUuidToGameRoomsFixed < ActiveRecord::Migration[6.1]
  def change
    add_column :game_rooms, :uuid, :uuid, default: "gen_random_uuid()", null: false
    rename_column :game_rooms, :id, :integer_id
    rename_column :game_rooms, :uuid, :id
    execute "ALTER TABLE game_rooms drop constraint game_rooms_pkey;"
    execute "ALTER TABLE game_rooms ADD PRIMARY KEY (id);"

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute "ALTER TABLE ONLY game_rooms ALTER COLUMN integer_id DROP DEFAULT;"
    change_column_null :game_rooms, :integer_id, true
    execute "DROP SEQUENCE IF EXISTS game_rooms_id_seq"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
