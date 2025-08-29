const bcrypt = require('bcrypt')
const sqlite3 = require('sqlite3')
const db = new sqlite3.Database('./auth.db')

const username = 'testuser'
const plainPassword = 'testpass'

bcrypt.hash(plainPassword, 10, (err, hash) => {
  if (err) throw err

  db.run(
    `INSERT INTO admin (username, password) VALUES (?, ?)`,
    [username, hash],
    (err) => {
      if (err) {
        console.error('Error inserting test user:', err)
      } else {
        console.log('Test user created successfully')
      }
      db.close()
    },
  )
})
