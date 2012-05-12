# Config::Data

Classes in this directory implement the "data" concerns. Config
maintains the `./.data` directory relative to your project for this
data.

Node data is persisted through a "database" abstraction. Each node
updates or removes its data from the database as appropriate. Today,
that database is implemented as a git repository.
