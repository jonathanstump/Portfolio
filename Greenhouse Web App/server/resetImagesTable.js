const sqlite3 = require('sqlite3').verbose()

// Open your database (adjust path if needed)
const db = new sqlite3.Database('./auth.db')

db.serialize(() => {
  console.log('Dropping and recreating groups table...')

  db.run('DROP TABLE IF EXISTS images')

  db.run(
    `
    CREATE TABLE IF NOT EXISTS images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      expName TEXT NOT NULL,
      schoolId INTEGER NOT NULL,
      week TEXT NOT NULL,
      filename TEXT NOT NULL,
      status TEXT NOT NULL CHECK (status IN ('pending','approved','rejected')),
      FOREIGN KEY (schoolId) REFERENCES schools(id)
    )
    `,
    (err) => {
      if (err) {
        console.error('Failed to create table:', err)
      } else {
        console.log('Successfully reset images table.')
      }
    },
  )
})

db.close()
