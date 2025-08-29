import React, { useState } from 'react'
import styles from '../styles/screens/userDashboardStyles'
import { useNavigate } from 'react-router-dom'

const ExperimentCard = ({ experiment }) => {
  const [hovered, setHovered] = useState(false)
  const navigate = useNavigate()

  return (
    <div
      style={{
        ...styles.card,
        ...(hovered ? styles.cardHover : {}),
      }}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onClick={() =>
        navigate('/school-exp', { state: { expName: experiment.name } })
      }
    >
      <h3 style={styles.cardTitle}>{experiment.name}</h3>
    </div>
  )
}

export default ExperimentCard
