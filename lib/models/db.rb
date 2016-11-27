DB = Sequel.sqlite("db/jokestime.db")

class User < Sequel::Model
  
  one_to_many :videos

  def auth(attempted_password)
    self.pass == attempted_password
  end

end


class Video < Sequel::Model
  include VideoUploader[:video]

  many_to_one :user

end
