output.icecast(
  %vorbis,
  host="localhost",
  port=8000,
  password="hackme",
  mount="podcast",
  mksafe(
    single("/path/to/podcast.ogg")
  )
)
