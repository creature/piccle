Sequel.migration do
  change do
    create_table(:locations) do
      primary_key :id
      Float :latitude, null: false
      Float :longitude, null: false
      String :city, text: true
      String :state, text: true
      String :country, text: true
      DateTime :created_at
    end

    alter_table(:photos) do
      add_column :city, String, text: true
      add_column :state, String, text: true
      add_column :country, String, text: true
    end
  end
end
