Sequel.migration do
  change do
    alter_table(:photos) do
      add_index :md5, unique: true
      add_index :file_name
      add_index :path
      add_index [:path, :file_name], unique: true
    end

    # Keywords and people are case-insensitive, enforce that in the DB
    alter_table(:keywords) { add_index Sequel.function(:lower, :name), unique: true }
    alter_table(:people) { add_index Sequel.function(:lower, :name), unique: true }
  end
end
