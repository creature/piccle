Sequel.migration do
  change do
    alter_table(:photos) do
      add_column :focal_length, Float
    end
  end
end
