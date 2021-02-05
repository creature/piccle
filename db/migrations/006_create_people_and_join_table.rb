Sequel.migration do
  change do
    create_table(:people) do
      primary_key :id
      String :name, null: false, unique: true
    end

    create_table(:people_photos) do
      Integer :person_id, null: false
      Integer :photo_id, null: false
      primary_key [:person_id, :photo_id], name: :people_photos_pk
    end
  end
end
