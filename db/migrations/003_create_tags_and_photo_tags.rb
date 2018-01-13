Sequel.migration do
  change do
    create_table(:keywords) do
      primary_key :id
      String :name, null: false, unique: true
    end

    create_table(:photo_keywords) do
      Integer :photo_id, null: false
      Integer :keyword_id, null: false
      primary_key [:photo_id, :keyword_id], name: :photo_keywords_pk
    end
  end
end
