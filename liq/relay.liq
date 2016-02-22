output.icecast(
  %vorbis,
  host="localhost",
  port=8000,
  password="hackme",
  mount="podcast",
  input.http("http://example.com:8000/mount")
)
