class User < Sequel::Model
  
  one_to_many :videos

  def auth(attempted_password)
    self.pass == attempted_password
  end

end
