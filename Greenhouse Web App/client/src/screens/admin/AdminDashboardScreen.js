import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { styles } from '../../styles/screens/adminDashboardScreenStyles'
import AddExperimentModal from '../../Components/AddExperimentModal'

const AdminDashboardScreen = () => {
  const [schools, setSchools] = useState([])
  const [experiments, setExperiments] = useState([])
  const [expandedSections, setExpandedSections] = useState({
    schools: true,
    experiments: true,
  })
  const [hoveredCard, setHoveredCard] = useState(null)
  const [modalVisible, setModalVisible] = useState(false)
  const [schoolPreviews, setSchoolPreviews] = useState({})

  const navigation = useNavigate()

  useEffect(() => {
    fetchSchoolData()
    fetchExperimentData()
  }, [])

  const toggleSection = (sectionKey) => {
    if (modalVisible) {
      return
    }
    setExpandedSections((prev) => ({
      ...prev,
      [sectionKey]: !prev[sectionKey],
    }))
  }

  const fetchSchoolData = async () => {
    try {
      const res = await fetch('http://localhost:5000/api/schools')
      if (res.ok) setSchools(await res.json())
      else alert(await res.text())
    } catch (err) {
      console.error('Fetch error (schools):', err)
    }
  }

  const fetchExperimentData = async () => {
    try {
      const res = await fetch('http://localhost:5000/api/experiments')
      if (res.ok) setExperiments(await res.json())
      else alert(await res.text())
    } catch (err) {
      console.error('Fetch error (experiments):', err)
    }
  }

  const showExperimentsForSchool = async (schoolName, schoolId) => {
    console.log('School previews: ', schoolPreviews)

    // Avoid refetching if we've already cached it
    if (schoolPreviews[schoolId]) return

    try {
      const res = await fetch('http://localhost:5000/api/schoolExp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: schoolName }),
      })
      if (res.ok) {
        const data = await res.json()
        setSchoolPreviews((prev) => ({
          ...prev,
          [schoolId]: data,
        }))
      } else {
        console.error(await res.text())
      }
    } catch (err) {
      console.error('Fetch error (experiments):', err)
    }
  }

  const handleNewExperiment = async (title, vars, tagged) => {
    const body = {
      name: title,
      variables: vars,
      schools: tagged,
    }

    try {
      const res = await fetch('http://localhost:5000/api/addExperiment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      if (res.ok) {
        setModalVisible(false)
        fetchExperimentData() // refresh the list
      } else {
        console.error(await res.text())
      }
    } catch (err) {
      console.error('Error submitting experiment:', err)
    }
  }

  const renderCard = ({ title, subtitle, onClick, itemId, type }) => (
    <div
      key={itemId}
      style={{
        ...styles.card,
        ...(hoveredCard === itemId ? styles.hoveredCard : {}),
      }}
      onMouseEnter={() => {
        setHoveredCard(itemId)
        if (type === 'school') {
          showExperimentsForSchool(title, itemId)
        }
      }}
      onMouseLeave={() => setHoveredCard(null)}
      onClick={onClick}
    >
      <h3 style={styles.cardTitle}>{title}</h3>

      {hoveredCard === itemId && (
        <div>
          <p style={styles.cardSubtitle}>{subtitle}</p>

          {type === 'school' && (
            <div style={styles.previewContainer}>
              {schoolPreviews[itemId] ? (
                schoolPreviews[itemId].length > 0 ? (
                  <ul style={styles.previewList}>
                    {schoolPreviews[itemId].map((exp) => (
                      <li key={exp.id} style={styles.previewItem}>
                        {exp.name}
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p style={styles.previewItem}>No experiments found.</p>
                )
              ) : (
                <p style={styles.previewItem}>Loading...</p>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  )

  return (
    <div style={styles.container}>
      {/* Schools Section */}
      <div>
        <div
          style={styles.sectionHeader}
          onClick={() => toggleSection('schools')}
        >
          <h2 style={styles.sectionTitle}>Schools</h2>
        </div>
        {expandedSections.schools && (
          <div style={styles.cardContainer}>
            {schools.map((item) =>
              renderCard({
                title: item.name,
                subtitle: 'Experiments: ',
                itemId: item.id,
                onClick: () => {},
                type: 'school',
              }),
            )}
          </div>
        )}
      </div>

      {/* Experiments Section */}
      <div>
        <div
          style={styles.sectionHeader}
          // onClick={() => toggleSection('experiments')}
        >
          <h2 style={styles.sectionTitle}>Experiments</h2>
          <button
            style={styles.addExperimentButton}
            onClick={() => setModalVisible(true)}
            aria-label="Add Experiment"
          >
            +
          </button>
          {/* Modal */}
          {modalVisible && (
            <AddExperimentModal
              schools={schools}
              closeModal={setModalVisible}
              submit={handleNewExperiment}
            />
          )}
        </div>
        {expandedSections.experiments && (
          <div style={styles.cardContainer}>
            {experiments.map((e) =>
              renderCard({
                title: e.name,
                subtitle: 'Click to manage',
                itemId: e.name,
                onClick: () => {
                  console.log(schools)
                  navigation('/exp', {
                    state: {
                      e,
                      schools,
                    },
                  })
                },
                type: 'experiment',
              }),
            )}
          </div>
        )}
      </div>
    </div>
  )
}

export default AdminDashboardScreen
