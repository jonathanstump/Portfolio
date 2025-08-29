import React, { useState, useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import EditExperimentModal from '../../Components/EditExperimentModal'
import { styles } from '../../styles/screens/experimentHandlerScreenStyles'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faEdit } from '@fortawesome/free-solid-svg-icons'

const ExperimentHandlerScreen = () => {
  const location = useLocation()
  const navigation = useNavigate()
  const [exp, setExp] = useState(location.state?.e || {})
  const [showModal, setShowModal] = useState(false)
  const [hoveredId, setHoveredId] = useState(null)
  const [fields, setFields] = useState({
    abstract: '',
    hypothesis: '',
    method: '',
    results: '',
    conclusion: '',
  })
  const [status, setStatus] = useState({
    abstract: false,
    hypothesis: false,
    method: false,
    results: false,
    conclusion: false,
  })

  const allSchools = location.state.schools
  const parsedSchools = Array.isArray(exp.schools)
    ? exp.schools
    : typeof exp.schools === 'string'
      ? JSON.parse(exp.schools)
      : []

  const textSections = [
    { key: 'abstract', label: 'Abstract' },
    { key: 'hypothesis', label: 'Hypothesis' },
    { key: 'method', label: 'Method' },
    { key: 'results', label: 'Results' },
    { key: 'conclusion', label: 'Conclusion' },
  ]

  useEffect(() => {
    const insertIfNeeded = async () => {
      if (!exp.name) return
      try {
        await fetch('http://localhost:5000/api/insertExpRow', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ exp_title: exp.name }),
        })
      } catch (err) {
        console.error('Failed to ensure expData row:', err)
      }
    }

    insertIfNeeded()
  }, [exp.name])

  useEffect(() => {
    const getStuff = async () => {
      if (!exp.name) return
      try {
        const res = await fetch('http://localhost:5000/api/getExpData', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: exp.name }), // match backend field
        })

        if (res.ok) {
          const data = await res.json()
          setFields({
            abstract: data.abstract || '',
            hypothesis: data.hypothesis || '',
            method: data.method || '',
            results: data.results || '',
            conclusion: data.conclusion || '',
          })
          setStatus({
            abstract: true,
            hypothesis: true,
            method: true,
            results: true,
            conclusion: true,
          })
        } else if (res.status === 404) {
          console.log('No existing expData row, inserting...')
          await fetch('http://localhost:5000/api/insertExpRow', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ exp_title: exp.name }),
          })
        } else {
          console.error('Failed to fetch expData:', await res.text())
        }
      } catch (err) {
        console.error('Failed to fetch expData:', err)
      }
    }

    getStuff()
  }, [exp.name])

  const updateExperiment = async (id, variables, schools, newName) => {
    const body = {
      name: newName,
      variables,
      schools,
      id,
    }

    try {
      const res = await fetch('http://localhost:5000/api/updateExperiment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      if (res.ok) {
        setShowModal(false)
        setExp({ name: newName, vars: variables, schools })
      } else {
        console.error('Update failed:', await res.text())
      }
    } catch (err) {
      console.error('Error submitting updated experiment:', err)
    }
  }

  const handleSubmit = async (key) => {
    const body = {
      exp_title: exp.name,
      field_name: key,
      field_value: fields[key],
    }

    try {
      const res = await fetch('http://localhost:5000/api/updateExpField', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      if (res.ok) {
        setStatus((prev) => ({ ...prev, [key]: true }))
      } else {
        console.error('Submit failed:', await res.text())
      }
    } catch (err) {
      console.error('Error submitting experiment:', err)
    }
  }

  const handleTextChange = (key, value) => {
    setFields((prev) => ({ ...prev, [key]: value }))
    setStatus((prev) => ({ ...prev, [key]: false }))
  }

  return (
    <div style={styles.container}>
      <div style={styles.headerRow}>
        <h1 style={styles.experimentName}>
          {exp?.name || 'Unnamed Experiment'}
        </h1>
        <button
          style={styles.editButton}
          onClick={() => setShowModal(true)}
          aria-label="Edit"
        >
          <FontAwesomeIcon icon={faEdit} />
        </button>
      </div>

      {showModal && (
        <EditExperimentModal
          experiment={exp}
          allSchools={allSchools}
          closeModal={setShowModal}
          submit={updateExperiment}
        />
      )}

      {parsedSchools.length > 0 && (
        <div style={styles.schoolsContainer}>
          {parsedSchools.map((school) => (
            <div key={school.id} style={styles.schoolChip}>
              <div
                style={{
                  ...styles.schoolLink,
                  ...(hoveredId === school.id ? styles.schoolLinkHover : {}),
                }}
                onMouseEnter={() => setHoveredId(school.id)}
                onMouseLeave={() => setHoveredId(null)}
                onClick={() => {
                  navigation('/exp-school', { state: { exp, school } })
                }}
              >
                {school.name}
              </div>
            </div>
          ))}
        </div>
      )}

      {textSections.map(({ key, label }) => (
        <div key={key} style={styles.sectionContainer}>
          <h2 style={styles.sectionTitle}>{label}</h2>
          <textarea
            style={styles.textarea}
            value={fields[key]}
            onChange={(e) => handleTextChange(key, e.target.value)}
            placeholder={`Enter ${label.toLowerCase()}...`}
          />
          <br />
          <button style={styles.submitButton} onClick={() => handleSubmit(key)}>
            Submit
          </button>
          <p style={styles.statusText}>
            {status[key] ? `${label} saved!` : `${label} ready to save`}
          </p>
        </div>
      ))}
    </div>
  )
}

export default ExperimentHandlerScreen
