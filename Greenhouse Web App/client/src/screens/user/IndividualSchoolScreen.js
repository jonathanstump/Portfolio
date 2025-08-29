import React, { useState, useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import VariableDropdown from '../../Components/VariableDropdown'
import styles from '../../styles/screens/individualSchoolScreenStyles'
import LineGraph from '../../Components/LineGraph'

const IndividualSchoolScreen = () => {
  const location = useLocation()
  const name = location?.state?.name
  const school = location?.state?.school
  const [groups, setGroups] = useState([])
  const [variableNames, setVariableNames] = useState([''])
  const [images, setImages] = useState([])
  const [currVar, setCurrVar] = useState('')
  const [index, setIndex] = useState(-1)

  useEffect(() => {
    const fetchGroupData = async () => {
      const body = {
        name: name,
        school: school.name,
      }
      try {
        const res = await fetch('http://localhost:5000/api/groups', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          const data = await res.json()
          console.log('Groups returned:', data)
          setGroups(data)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error fetching group data:', err)
      }
    }
    fetchGroupData()
  }, [name, school])

  useEffect(() => {
    const fetchExp = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/single-exp', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name }),
        })

        if (res.ok) {
          const data = await res.json()
          console.log('Exp is: ', data)
          try {
            const parsed = JSON.parse(data.elements)
            const vars = Array.isArray(parsed) ? parsed : ['']
            setVariableNames(vars)
            if (vars.length > 0) {
              setCurrVar(vars[0])
              setIndex(0)
            }
          } catch (err) {
            console.error('Failed to parse variables:', err)
            const vars = Array.isArray(data.elements) ? data.elements : ['']
            setVariableNames(vars)
            if (vars.length > 0) {
              setCurrVar(vars[0])
              setIndex(0)
            }
          }
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error fetching experiment:', err)
      }
    }

    if (groups.length > 0) {
      fetchExp()
    }
  }, [name, groups.length])

  useEffect(() => {
    const body = {
      name: name,
      schoolId: school?.id,
    }

    const fetchApproved = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/images/approved', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          const data = await res.json()
          setImages(Array.isArray(data) ? data : [])
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error fetching approved images:', err)
      }
    }

    if (school?.id) {
      fetchApproved()
    }
  }, [school, name])

  const handleVariableSelect = (v, i) => {
    setCurrVar(v)
    setIndex(i)
  }

  return (
    <div style={styles.container}>
      <div style={styles.headerRow}>
        <h2 style={styles.title}>{school?.name || 'Unknown School'}</h2>
      </div>

      <section style={styles.section}>
        <h3 style={styles.sectionTitle}>Images</h3>
        <div style={styles.imageGrid}>
          {images.length > 0 ? (
            images.map((img) => (
              <div key={img.id} style={styles.imageWrapper}>
                <img
                  src={`http://localhost:5000/uploads/${img.schoolId}/${img.week}/${img.filename}`}
                  alt={img.filename}
                  style={styles.image}
                />
              </div>
            ))
          ) : (
            <p style={styles.emptyText}>No approved images available.</p>
          )}
        </div>
      </section>

      <section style={styles.section}>
        <h3 style={styles.sectionTitle}>Data Visualization</h3>
        <div style={styles.graphControls}>
          <VariableDropdown
            variables={variableNames}
            onSelect={handleVariableSelect}
            value={currVar}
            style={styles.dropdown}
          />
        </div>
        <div style={styles.graphWrapper}>
          <LineGraph groups={groups} currVar={currVar} index={index} />
        </div>
      </section>
    </div>
  )
}

export default IndividualSchoolScreen
