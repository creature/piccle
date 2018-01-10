Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      String :file_name, null: false, text: true
      String :path, null: false, text: true
      String :md5, null: false
      Integer :width, null: false
      Integer :height, null: false
      String :camera_name, null: false, text: true
      DateTime :taken_at
      DateTime :created_at
    end
  end
end
