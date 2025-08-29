import React, { useState, useEffect } from 'react'
import { styles } from '../styles/components/editGroupModalStyles'

const EditGroupModal = ({ num, sub, exp_name, school, vars, onClose }) => {
  const [groups, setGroups] = useState([])
  const [targetGroup, setTargetGroup] = useState(null)
  const [values, setValues] = useState([])
  const [variableNames, setVariableNames] = useState([])
  const [currSub, setCurrSub] = useState(Number(sub))
  const [newSub, setNewSub] = useState(false)

  // 1. Fetch all groups for the given number
  useEffect(() => {
    const fetchGroupsByNumber = async () => {
      const body = {
        number: num,
        name: exp_name,
        school: school,
      }

      try {
        const res = await fetch('http://localhost:5000/api/groupsByNumber', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          const data = await res.json()
          setGroups(data)
          console.log('Groups w/number: ', data)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error fetching groups:', err)
      }
    }

    fetchGroupsByNumber()
  }, [num, exp_name, school, newSub])

  // 2. Parse variable names from `vars` prop once on mount/prop change
  useEffect(() => {
    try {
      const parsed = JSON.parse(vars)
      setVariableNames(Array.isArray(parsed) ? parsed : [''])
    } catch (err) {
      console.error('Failed to parse vars:', err)
      setVariableNames(Array.isArray(vars) ? vars : [''])
    }
  }, [vars])

  // 3. Update targetGroup & values whenever groups or currSub changes
  useEffect(() => {
    if (!groups.length) return
    const temp = groups.find((g) => g.submission === currSub)
    if (!temp) {
      setTargetGroup(null)
      setValues([])
      return
    }

    setTargetGroup(temp)

    try {
      const parsed = JSON.parse(temp.variables)
      setValues(Array.isArray(parsed) ? parsed : [''])
    } catch (err) {
      console.error('Failed to parse target group variables:', err)
      setValues(Array.isArray(temp.variables) ? temp.variables : [''])
    }
  }, [currSub, groups])

  const handleChange = (index, value) => {
    const updated = [...values]
    updated[index] = value
    setValues(updated)
  }

  const handleNewButton = () => {
    setCurrSub(groups.length + 1)
    setNewSub(true)
    setValues([])
  }

  const handleFormSubmit = async (e) => {
    e.preventDefault()

    const body = {
      name: exp_name,
      school: school,
      number: num,
      submission: currSub,
      variables: values,
    }
    if (newSub) {
      try {
        const res = await fetch('http://localhost:5000/api/groupSubmission', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          setNewSub(false)
          setCurrSub(groups.length + 1)
          console.log('Submitted Successfully!')
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error submitting group variables:', err)
      }
    } else {
      console.log('update body', body)
      try {
        const res = await fetch('http://localhost:5000/api/updateGroupVars', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          console.log('Updated Successfully!')
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error updating group variables:', err)
      }
    }
  }

  return (
    <div style={styles.modalBackdrop}>
      <div style={styles.modal}>
        <div style={styles.modalHeaderRow}>
          <h2 style={{ color: '#5ca67c', marginBottom: 0 }}>
            Edit Group {num} - Lab {currSub}
          </h2>
          <button
            style={styles.newLabButton}
            onClick={handleNewButton}
            onMouseEnter={(e) =>
              (e.currentTarget.style.backgroundColor =
                styles.newLabButtonHover.backgroundColor)
            }
            onMouseLeave={(e) =>
              (e.currentTarget.style.backgroundColor =
                styles.newLabButton.backgroundColor)
            }
          >
            New Lab
          </button>
        </div>
        {!newSub && (
          <div>
            <select
              style={styles.select}
              onChange={(e) => {
                setCurrSub(Number(e.target.value))
                setNewSub(false)
              }}
              value={currSub}
            >
              {groups.map((group, index) => (
                <option key={index} value={group.submission}>
                  Lab {group.submission}
                </option>
              ))}
            </select>
          </div>
        )}
        <form onSubmit={handleFormSubmit}>
          {variableNames.map((name, index) => (
            <div key={index} style={styles.inputGroup}>
              <label style={styles.label}>{name}</label>
              <input
                type="text"
                value={values[index] || ''}
                onChange={(e) => handleChange(index, e.target.value)}
                style={styles.input}
              />
            </div>
          ))}
          <div style={styles.buttonRow}>
            <button type="submit" style={styles.submitButton}>
              Submit
            </button>
            <button type="button" onClick={onClose} style={styles.cancelButton}>
              Close
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

export default EditGroupModal
