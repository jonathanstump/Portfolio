import React, { useState, useEffect } from 'react'

const SingleSchoolSelector = ({ onSelect, value }) => {
  const [schools, setSchools] = useState([])

  useEffect(() => {
    const fetchSchools = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/schools')
        if (res.ok) setSchools(await res.json())
        else alert(await res.text())
      } catch (err) {
        console.error('Fetch error (schools):', err)
      }
    }
    fetchSchools()
  }, [])

  return (
    <div style={styles.wrapper}>
      <select
        onChange={(e) => onSelect(e.target.value)}
        value={value}
        style={styles.select}
      >
        <option value="">Select School</option>
        {schools.map((school) => (
          <option key={school.id} value={school.name}>
            {school.name}
          </option>
        ))}
      </select>
    </div>
  )
}

const styles = {
  wrapper: {
    display: 'flex',
    flexDirection: 'column',
    width: '100%',
    maxWidth: '260px',
    marginBottom: '1rem',
  },
  select: {
    padding: '0.6rem 0.8rem',
    borderRadius: '10px',
    border: '2px solid #5ca67c',
    backgroundColor: '#f5f5f5',
    color: '#023D54',
    fontSize: '1rem',
    fontWeight: 500,
    appearance: 'none',
    cursor: 'pointer',
  },
}

export default SingleSchoolSelector
