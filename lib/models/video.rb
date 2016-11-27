class Video < Sequel::Model
  include VideoUploader[:video]

  many_to_one :user

end
