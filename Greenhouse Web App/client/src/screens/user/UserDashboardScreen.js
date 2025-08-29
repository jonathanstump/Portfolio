import React, { useState, useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import styles from '../../styles/screens/userDashboardStyles'
import ExperimentCard from '../../Components/ExperimentCard'

const UserDashboardScreen = () => {
  const location = useLocation()
  const name = location?.state?.selectedSchoolName || ''
  const [exp, setExp] = useState([])

  useEffect(() => {
    const fetchExperiments = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/schoolExp', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name }),
        })
        if (res.ok) {
          const data = await res.json()
          setExp(data)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Fetch error (experiments):', err)
      }
    }

    fetchExperiments()
  }, [name])

  return (
    <div style={styles.container}>
      <h2 style={styles.heading}>{name}</h2>

      <div style={styles.cardGrid}>
        {exp.map((experiment) => (
          <ExperimentCard
            key={experiment.id || experiment.name}
            experiment={experiment}
          />
        ))}
      </div>
    </div>
  )
}

export default UserDashboardScreen
