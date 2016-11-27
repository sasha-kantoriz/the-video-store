class VideoUploader < Shrine

  plugin :processing
  plugin :versions
  plugin :delete_raw


  process(:store) do |io, context|
    mov        = io.download
    video      = Tempfile.new(["video", ".mp4"], binmode: true)

    movie = FFMPEG::Movie.new(mov.path)
    movie.transcode(video.path)

    mov.delete

    {video: video}
  end

end