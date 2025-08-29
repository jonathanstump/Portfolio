const express = require('express')
const app = express()
const PORT = process.env.PORT || 5000
const path = require('path')
const session = require('express-session')
const bodyParser = require('body-parser')
const sqlite3 = require('sqlite3')
const db = new sqlite3.Database('./auth.db')
const bcrypt = require('bcrypt')

const cors = require('cors')
app.use(
  cors({
    origin: 'http://localhost:3000',
    credentials: true,
  }),
)

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS admin (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
  `)

  db.run(`
    CREATE TABLE IF NOT EXISTS schools (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE,
      password TEXT
    )
  `)

  db.all('SELECT COUNT(*) AS count FROM schools', (err, rows) => {
    if (!err && rows[0].count === 0) {
      const stmt = db.prepare('INSERT INTO schools (name) VALUES (?)')
      const mockSchools = [
        'Greenwood High',
        'Oakridge Academy',
        'Riverdale Prep',
      ]
      mockSchools.forEach((school) => stmt.run(school))
      stmt.finalize()
      console.log('Inserted mock schools')
    }
  })

  // db.run('ALTER TABLE schools ADD COLUMN password TEXT', (err) => {
  //   if (err && !err.message.includes('duplicate column')) {
  //     console.error('Failed to add password column:', err)
  //   } else {
  //     console.log('Password column ready.')
  //   }
  // })

  const bcrypt = require('bcrypt')
  const saltRounds = 10
  const plainPassword = '1234'

  bcrypt.hash(plainPassword, saltRounds, (err, hash) => {
    if (err) {
      console.error('Error hashing password:', err)
      return
    }

    db.run('UPDATE schools SET password = ?', [hash], (err) => {
      if (err) {
        console.error('Error updating passwords:', err)
      } else {
        console.log('Set hashed default password for all schools.')
      }
    })
  })

  db.run(`
    CREATE TABLE IF NOT EXISTS experiments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE,
      schools JSON,
      elements JSON
    )
  `)

  db.run(`
    CREATE TABLE IF NOT EXISTS expData (
    name TEXT UNIQUE,
    abstract TEXT,
    hypothesis TEXT,
    method TEXT,
    results TEXT,
    conclusion TEXT
    )
  `)

  db.run(`
    CREATE TABLE IF NOT EXISTS groups (
      experiment_name TEXT,
      school TEXT,
      variables JSON,
      number INT,
      submission INT,
      UNIQUE (experiment_name, school, number, submission)
    )
  `)

  db.run(`
    CREATE TABLE IF NOT EXISTS images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      expName TEXT NOT NULL,
      schoolId INTEGER NOT NULL,
      week TEXT NOT NULL,
      filename TEXT NOT NULL,
      status TEXT NOT NULL CHECK (status IN ('pending','approved','rejected')),
      FOREIGN KEY (schoolId) REFERENCES schools(id)
    )
  `)

  // Insert some mock rows (schoolId corresponds to inserted schools: 1, 2, 3)
  // db.run(`
  //   INSERT INTO images (schoolId, expName, week, filename, status) VALUES
  //    (1, 'Test Experiment Vars', 'week1', '1723954872000-classroom1.jpg', 'pending'),
  //    (1, 'Test Experiment Vars', 'week1', '1723954875000-classroom2.jpg', 'pending'),
  //    (2, 'Test Experiment Vars', 'week2', '1723954880000-lab1.jpg', 'pending')
  // `)
})

app.use('/uploads', express.static(path.join(__dirname, 'uploads')))
app.use(bodyParser.json())
app.use(
  session({
    secret: 'yourSecretKey',
    resave: false,
    saveUninitialized: false,
  }),
)

const multer = require('multer')
const fs = require('fs')

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const { schoolId, week } = req.body
    const dir = path.join(__dirname, 'uploads', schoolId, week)
    fs.mkdirSync(dir, { recursive: true })
    cb(null, dir)
  },
  filename: function (req, file, cb) {
    const filename = Date.now() + '-' + file.originalname
    cb(null, filename)
  },
})

const upload = multer({ storage })

app.post('/api/images/upload', upload.single('image'), (req, res) => {
  const { schoolId, week } = req.body
  const filename = req.file.filename

  db.run(
    `INSERT INTO images (school_id, week, filename, status) VALUES (?, ?, ?, 'pending')`,
    [schoolId, week, filename],
    function (err) {
      if (err) {
        console.error(err)
        return res.status(500).json({ error: 'DB insert failed' })
      }
      res.json({ success: true, imageId: this.lastID })
    },
  )
})

app.post('/api/images/pending', (req, res) => {
  const { schoolId, expName } = req.body

  if (!schoolId || !expName) {
    return res.status(400).json({ error: 'Missing schoolId or expName' })
  }

  const sql = `
    SELECT *
    FROM images
    WHERE status = 'pending'
      AND schoolId = ?
      AND expName = ?
  `
  const params = [schoolId, expName]

  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error(err)
      return res.status(500).json({ error: 'DB query failed' })
    }
    res.json(rows)
  })
})

// Approve or reject an image
app.post('/api/images/:id/status', (req, res) => {
  const { id } = req.params
  const { status } = req.body // 'approved' or 'rejected'

  if (!['approved', 'rejected', 'pending'].includes(status)) {
    return res.status(400).json({ error: 'Invalid status' })
  }

  db.run(
    `UPDATE images SET status = ? WHERE id = ?`,
    [status, id],
    function (err) {
      if (err) {
        console.error(err)
        return res.status(500).json({ error: 'DB update failed' })
      }
      res.json({ success: true, updated: this.changes })
    },
  )
})

app.post('/api/images/approved', (req, res) => {
  const { schoolId, name, week } = req.body

  let sql = `SELECT * FROM images WHERE status = 'approved'`
  const params = []

  if (schoolId) {
    sql += ` AND schoolId = ?`
    params.push(schoolId)
  }
  if (name) {
    sql += ` AND expName = ?`
    params.push(name)
  }
  if (week) {
    sql += ` AND week = ?`
    params.push(week)
  }

  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error(err)
      return res.status(500).json({ error: 'DB query failed' })
    }
    res.json(rows)
  })
})

app.post('/api/login', async (req, res) => {
  if (req.body.role == 'admin') {
    db.get(
      'SELECT * FROM admin WHERE username = ?',
      [req.body.username],
      async (err, user) => {
        if (!user) return res.status(401).send('Admin user not found')

        const valid = await bcrypt.compare(req.body.password, user.password)
        if (valid) {
          req.session.user = user // Save user in session
          res.send('Logged in!')
        } else {
          res.status(401).send('Invalid password')
        }
      },
    )
  } else {
    db.get(
      'SELECT * FROM schools WHERE name = ?',
      [req.body.selectedSchoolName],
      async (err, user) => {
        if (!user) return res.status(401).send('School user not found')

        const valid = await bcrypt.compare(req.body.password, user.password)
        if (valid) {
          req.session.user = user
          res.send('Logged in!')
        } else {
          res.status(401).send('Invalid password')
        }
      },
    )
  }
})

app.get('/api/schools', async (req, res) => {
  db.all('SELECT id, name FROM schools', (err, rows) => {
    if (err) {
      console.error('DB error:', err)
      return res.status(500).send('Internal server error')
    }

    if (!rows || rows.length === 0) {
      return res.status(404).send('No schools found')
    }

    res.json(rows)
  })
})

app.get('/api/experiments', async (req, res) => {
  db.all('SELECT id, name, schools, elements FROM experiments', (err, rows) => {
    if (err) {
      console.error('DB error:', err)
      return res.status(500).send('Internal server error')
    }

    // Always return an array
    res.json(rows || [])
  })
})

app.post('/api/addExperiment', async (req, res) => {
  console.log(req.body)
  try {
    const { name, variables, schools } = req.body

    if (!name || !Array.isArray(schools) || !Array.isArray(variables)) {
      return res.status(400).send('Invalid request data')
    }

    const sql = `INSERT INTO experiments (name, schools, elements) VALUES (?, ?, ?)`
    const values = [name, JSON.stringify(schools), JSON.stringify(variables)]

    db.run(sql, values, function (err) {
      if (err) {
        console.error('Insert error:', err.message)
        return res.status(500).send('Failed to insert experiment')
      }

      res.status(200).send('Experiment added successfully')
    })
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/updateExperiment', async (req, res) => {
  try {
    const { name, variables, schools, id } = req.body

    if (!name || !Array.isArray(schools) || !Array.isArray(variables) || !id) {
      return res.status(400).send('Invalid request data')
    }

    const sql = `
      UPDATE experiments
      SET name = ?, schools = ?, elements = ?
      WHERE id = ?
    `
    const values = [
      name,
      JSON.stringify(schools),
      JSON.stringify(variables),
      id,
    ]

    db.run(sql, values, function (err) {
      if (err) {
        console.error('Update error:', err.message)
        return res.status(500).send('Failed to update experiment')
      }

      // Check if any row was actually updated
      if (this.changes === 0) {
        return res.status(404).send('Experiment not found')
      }

      res.status(200).send('Experiment updated successfully')
    })
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/single-exp', async (req, res) => {
  try {
    const { name } = req.body

    if (!name) {
      return res.status(400).send('Invalid request data')
    }

    db.get(`SELECT * FROM experiments WHERE name = ?`, [name], (err, row) => {
      if (err) {
        console.error(err)
        return res.status(500).send('Database error')
      }
      if (!row) {
        return res.status(404).send('Experiment not found')
      }
      res.json(row)
    })
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/schoolExp', async (req, res) => {
  try {
    const { name } = req.body

    if (!name) {
      return res.status(400).send('Invalid request data')
    }

    db.all(
      `
      SELECT * FROM experiments
      WHERE id IN (
        SELECT experiments.id
        FROM experiments, json_each(experiments.schools)
        WHERE LOWER(TRIM(json_each.value->>'name')) = LOWER(TRIM(?))
      )
    `,
      [name],
      (err, rows) => {
        if (err) {
          console.error(err)
        } else {
          res.json(rows || [])
        }
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/expSchools', async (req, res) => {
  try {
    const { name } = req.body

    if (!name) {
      return res.status(400).send('Invalid request data')
    }

    db.get(
      `
      SELECT schools FROM experiments
      WHERE name = ?
    `,
      [name],
      (err, row) => {
        if (err) {
          console.error('Database error:', err)
          return res.status(500).send('Database error')
        }

        if (!row) {
          return res.json([]) // no experiment found
        }

        try {
          const schools = JSON.parse(row.schools || '[]')
          res.json(schools)
        } catch (parseErr) {
          console.error('Error parsing schools JSON:', parseErr)
          res.status(500).send('Invalid JSON format in DB')
        }
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/deleteExp', async (req, res) => {
  try {
    const { title } = req.body

    if (!title) {
      return res.status(400).send('Invalid request data')
    }

    db.run(
      `
      DELETE FROM experiments
      WHERE name = ?
    `,
      [title],
      function (err) {
        if (err) {
          console.error('Database error:', err)
          return res.status(500).send('Database error')
        }

        if (this.changes === 0) {
          return res.status(404).send('Experiment not found')
        }

        res.status(200).send('Experiment deleted')
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/updateExpField', async (req, res) => {
  try {
    const { exp_title, field_name, field_value } = req.body

    const validFields = [
      'abstract',
      'hypothesis',
      'method',
      'results',
      'conclusion',
    ]
    if (!exp_title || !validFields.includes(field_name)) {
      return res.status(400).send('Invalid request data')
    }

    const sql = `UPDATE expData SET ${field_name} = ? WHERE name = ?`

    db.run(sql, [field_value, exp_title], function (err) {
      if (err) {
        console.error('Database error:', err)
        return res.status(500).send('Database error')
      }

      if (this.changes === 0) {
        return res.status(404).send('Experiment not found')
      }

      res.status(200).send('Field updated successfully')
    })
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/insertExpRow', async (req, res) => {
  const { exp_title } = req.body
  if (!exp_title) return res.status(400).send('Missing experiment title')

  db.run(
    `INSERT OR IGNORE INTO expData (name) VALUES (?)`,
    [exp_title],
    function (err) {
      if (err) {
        console.error('Insert error:', err)
        return res.status(500).send('Insert failed')
      }

      res.status(200).send('Row ensured')
    },
  )
})

app.post('/api/getExpData', async (req, res) => {
  try {
    const { name } = req.body

    if (!name) {
      return res.status(400).send('Invalid request data')
    }

    db.get(
      `
      SELECT abstract, hypothesis, method, results, conclusion
      FROM expData
      WHERE name = ?
      `,
      [name],
      function (err, row) {
        if (err) {
          console.error('Database error:', err)
          return res.status(500).send('Database error')
        }

        if (!row) {
          return res.status(404).send('Experiment not found')
        }

        res.json(row)
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/groupSubmission', async (req, res) => {
  try {
    const { name, school, variables, number, submission } = req.body

    if (!name || !school || !variables || !number || !submission) {
      return res.status(400).send('Invalid request data')
    }

    db.run(
      `
      INSERT INTO groups (experiment_name, school, variables, number, submission)
      VALUES (?, ?, ?, ?, ?)
    `,
      [name, school, JSON.stringify(variables), number, submission],
      function (err) {
        if (err) {
          console.error('Database error:', err)
          return res.status(500).send('Database error')
        }

        res.status(200).send('Submit successful!')
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/groups', async (req, res) => {
  try {
    const { name, school } = req.body

    if (!name || !school) {
      return res.status(400).send('Invalid request data')
    }
    db.all(
      'SELECT * FROM groups WHERE experiment_name = ? AND school = ?',
      [name, school],
      (err, rows) => {
        if (!rows || rows.length === 0) {
          //return res.status(404).send('No groups found')
          return res.json([])
        }
        if (err) {
          console.error('DB error:', err)
          return res.status(500).send('Internal server error')
        }

        res.json(rows)
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/groupsByNumber', async (req, res) => {
  try {
    const { number, name, school } = req.body

    if (!number) {
      return res.status(400).send('Invalid request data')
    }
    db.all(
      'SELECT * FROM groups WHERE number = ? AND experiment_name = ? AND school = ?',
      [number, name, school],
      (err, rows) => {
        if (err) {
          console.error('DB error:', err)
          return res.status(500).send('Internal server error')
        }

        if (!rows || rows.length === 0) {
          return res.status(404).send('No groups found')
        }

        res.json(rows)
      },
    )
  } catch (err) {
    console.error('Unexpected error:', err)
    res.status(500).send('Server error')
  }
})

app.post('/api/updateGroupVars', (req, res) => {
  const { name, school, number, submission, variables } = req.body

  if (!name || !school || !Array.isArray(variables)) {
    return res.status(400).send('Invalid request body.')
  }

  const query = `
    UPDATE groups
    SET variables = ?
    WHERE experiment_name = ? AND school = ? AND number = ? AND submission = ?
  `
  db.run(
    query,
    [JSON.stringify(variables), name, school, number, submission],
    function (err) {
      if (err) {
        console.error('Error updating group variables:', err)
        return res.status(500).send('Database error.')
      }

      if (this.changes === 0) {
        return res.status(404).send('No group found to update.')
      }

      res.sendStatus(200)
    },
  )
})

// Serve static files from React build (production only)
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../client/build')))

  // Fallback: send index.html for any unknown path
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../client/build/index.html'))
  })
}

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
