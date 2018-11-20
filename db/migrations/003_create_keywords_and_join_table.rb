Sequel.migration do
  change do
    create_table(:keywords) do
      primary_key :id
      String :name, null: false, unique: true
    end

    create_table(:keywords_photos) do
      Integer :photo_id, null: false
      Integer :keyword_id, null: false
      primary_key [:photo_id, :keyword_id], name: :keywords_photos_pk
    end
  end
end
