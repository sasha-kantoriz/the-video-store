Sequel.migration do
  change do
    create_table(:videos) do
      primary_key     :id
      String          :title, :null=>false, :required=>true
      Integer         :likes
      Integer         :watch_count
      String          :created_at
      Text            :video_data
      foreign_key     :user_id, :users
    end
  end
end