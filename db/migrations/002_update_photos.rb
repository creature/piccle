Sequel.migration do
  change do
    alter_table(:photos) do
     add_column :title, String, text: true
     add_column :description, String, text: true
     add_column :aperture, Float
     add_column :shutter_speed_numerator, Integer
     add_column :shutter_speed_denominator, Integer
     add_column :iso, Integer
     add_column :latitude, Float
     add_column :longitude, Float
    end
  end
end
