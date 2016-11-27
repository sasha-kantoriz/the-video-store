Sequel.migration do
  change do
    create_table(:users) do
      primary_key     :id
      String          :login, :null=>false, :required=>true
      String          :email, :null=>false, :required=>true
      Text            :pass
    end
  end
end