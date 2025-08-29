import React, { useState, useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import { styles } from '../../styles/screens/experimentDisplayScreenStyles'
import { useNavigate } from 'react-router-dom'

const ExperimentDisplayScreen = () => {
  const location = useLocation()
  const name = location?.state?.expName
  const [abs, setAbs] = useState('')
  const [hyp, setHyp] = useState('')
  const [method, setMethod] = useState('')
  const [results, setResults] = useState('')
  const [conc, setConc] = useState('')
  const [schools, setSchools] = useState([])
  const [allExp, setAllExp] = useState([])

  const navigation = useNavigate()

  useEffect(() => {
    const fetchExperimentData = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/getExpData', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name }),
        })

        if (res.ok) {
          const data = await res.json()
          setAbs(data.abstract || '')
          setHyp(data.hypothesis || '')
          setMethod(data.method || '')
          setResults(data.results || '')
          setConc(data.conclusion || '')
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Fetch error (experiments):', err)
      }
    }

    if (name) fetchExperimentData()
  }, [name])

  useEffect(() => {
    const fetchSchoolData = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/expSchools', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name }),
        })

        if (res.ok) {
          const data = await res.json()
          setSchools(data)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Fetch error (schools):', err)
      }
    }

    if (name) fetchSchoolData()
  }, [name])

  useEffect(() => {
    const fetchExperiments = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/experiments')
        if (res.ok) {
          setAllExp(await res.json())
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Fetch error (experiments):', err)
      }
    }

    fetchExperiments()
  }, [])

  return (
    <div style={styles.container}>
      <h2 style={styles.title}>{name}</h2>

      <div style={styles.schoolList}>
        {schools.map((school, index) => (
          <div
            key={index}
            style={styles.schoolItem}
            onMouseEnter={(e) => (e.currentTarget.style.color = '#5ca67c')}
            onMouseLeave={(e) => (e.currentTarget.style.color = '#023D54')}
            onClick={() => {
              navigation('/indv-school-exp', { state: { name, school } })
            }}
          >
            {school.name}
          </div>
        ))}
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>Abstract</h3>
        <p style={{ ...styles.sectionText, whiteSpace: 'pre-wrap' }}>{abs}</p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>Hypothesis</h3>
        <p style={{ ...styles.sectionText, whiteSpace: 'pre-wrap' }}>{hyp}</p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>Method</h3>
        <p style={{ ...styles.sectionText, whiteSpace: 'pre-wrap' }}>
          {method}
        </p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>Results</h3>
        <p style={{ ...styles.sectionText, whiteSpace: 'pre-wrap' }}>
          {results}
        </p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>Conclusion</h3>
        <p style={{ ...styles.sectionText, whiteSpace: 'pre-wrap' }}>{conc}</p>
      </div>
    </div>
  )
}

export default ExperimentDisplayScreen
