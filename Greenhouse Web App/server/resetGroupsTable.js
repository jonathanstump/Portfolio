const sqlite3 = require('sqlite3').verbose()

// Open your database (adjust path if needed)
const db = new sqlite3.Database('./auth.db')

db.serialize(() => {
  console.log('Dropping and recreating groups table...')

  db.run('DROP TABLE IF EXISTS groups')

  db.run(
    `
    CREATE TABLE IF NOT EXISTS groups (
      experiment_name TEXT,
      school TEXT,
      variables TEXT,
      number INT,
      submission INT,
      UNIQUE (experiment_name, school, number, submission)
    )
  `,
    (err) => {
      if (err) {
        console.error('Failed to create table:', err)
      } else {
        console.log('Successfully reset groups table.')
      }
    },
  )
})

db.close()
