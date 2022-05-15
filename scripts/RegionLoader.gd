extends Node

var SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var region_db_path = "user://region0.db"
var db
var results_lock = Mutex.new()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if db:
			db.close_db()

func initialize_tables():
	var create_chunks_table = "CREATE TABLE IF NOT EXISTS chunks(" \
	+ "name TEXT PRIMARY KEY, x INT NOT NULL, y INT NOT NULL, z INT NOT NULL," \
	+ "blocks BLOB NOT NULL, UNIQUE(x, y, z));"
	db.query(create_chunks_table)

func save_chunk(name, x, y, z, block_bytes):
	var upsert_chunk = "INSERT INTO chunks(name, x, y, z, blocks) " \
	+ "VALUES(?, ?, ?, ?, ?) ON CONFLICT(name) " \
	+ "DO UPDATE SET blocks=excluded.blocks;"
	
	db.query_with_bindings(upsert_chunk, [name, x, y, z, block_bytes])

func load_chunk(x, y, z):
	var select_chunk = "SELECT blocks FROM chunks WHERE x = ? AND y = ? AND z = ?;"
	# The godot sqlite plugin has braindead interface and needs to be locked to guarantee
	# that the query result is actually the previous query
	results_lock.lock()
	var success = db.query_with_bindings(select_chunk, [x, y, z])
	var results = db.query_result.duplicate()
	results_lock.unlock()
	if success && results.size() > 0:
		return results[0]["blocks"]
	return null

func delete_db():
	var dir = Directory.new()
	dir.remove(region_db_path)

func open_region():
	db = SQLite.new()
	db.path = region_db_path
	db.open_db()
	initialize_tables()
