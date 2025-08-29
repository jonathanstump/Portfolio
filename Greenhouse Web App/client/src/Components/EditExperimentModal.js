import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import SchoolDropdown from './SchoolDropdown'
import { styles } from '../styles/components/addExperimentModalStyles'

const EditExperimentModal = ({
  experiment,
  allSchools,
  closeModal,
  submit,
}) => {
  const [experimentTitle, setExperimentTitle] = useState('')
  const [newName, setNewName] = useState('')
  const [variables, setVariables] = useState([''])
  const [schools, setSchools] = useState([''])
  const [taggedSchools, setTaggedSchools] = useState([])
  const [showModal, setShowModal] = useState(true)
  const [titleError, setTitleError] = useState(false)
  const [isParsed, setIsParsed] = useState(false)

  const navigation = useNavigate()

  useEffect(() => {
    setExperimentTitle(experiment.name || '')

    try {
      const parsed = JSON.parse(experiment.elements)
      setVariables(Array.isArray(parsed) ? parsed : [''])
    } catch (err) {
      console.error('Failed to parse elements:', err)
      setVariables(
        Array.isArray(experiment.elements) ? experiment.elements : [''],
      )
    }

    try {
      const arr = JSON.parse(experiment.schools)
      console.log('Parsed schools from experiment:', arr)
      console.log('Type of parsed schools:', typeof arr, Array.isArray(arr))
      setSchools(Array.isArray(arr) ? arr : [''])
    } catch (err) {
      console.error('Failed to parse schools:', err)
      setSchools(Array.isArray(experiment.schools) ? experiment.schools : [''])
    }

    setIsParsed(true)
  }, [experiment])

  const handleVariableChange = (index, value) => {
    const updated = [...variables]
    updated[index] = value
    setVariables(updated)
  }

  const addVariableField = () => {
    setVariables([...variables, ''])
  }

  const removeVariableField = () => {
    if (variables.length > 0) {
      setVariables(variables.slice(0, -1))
    }
  }

  const deleteExp = async (title) => {
    try {
      const res = await fetch('http://localhost:5000/api/deleteExp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title }),
      })
      if (res.ok) {
        console.log('Deleted!')
        navigation('/admin-dashboard')
        // const deleted = experiments.filter((e) => e.title !== title)
        // setExperiments(deleted)
      } else {
        console.error(await res.text())
      }
    } catch (err) {
      console.error('Could not delete:', err)
    }
  }

  const handleSubmit = () => {
    if (!newName.trim()) {
      setTitleError(true)
      return
    }
    submit(experiment.id, variables, taggedSchools, newName)
    handleClose()
  }

  const handleClose = () => {
    setShowModal(false)
    setTimeout(() => closeModal(false), 250)
  }

  const getOverlayStyle = () => ({
    ...styles.overlay,
    ...(showModal ? styles.fadeIn : styles.fadeOut),
  })

  console.log('allSchools:', allSchools)
  console.log('schools (checked):', schools)
  console.log('Sample school from allSchools:', allSchools?.[0])

  return (
    isParsed && (
      <div style={getOverlayStyle()}>
        <div style={styles.modal}>
          <div style={styles.headerRow}>
            <h2 style={styles.header}>Edit Experiment</h2>
            <button
              style={styles.removeButton}
              onClick={() => deleteExp(experimentTitle)}
            >
              Delete
            </button>
          </div>
          <input
            type="text"
            placeholder={experimentTitle}
            value={newName}
            onChange={(e) => {
              setNewName(e.target.value)
              setTitleError(false)
            }}
            style={{
              ...styles.input,
              ...(titleError ? styles.inputError : {}),
            }}
          />
          {titleError && <p style={styles.errorText}>Title is required</p>}

          {variables.map((variable, index) => (
            <input
              key={index}
              type="text"
              placeholder={`Enter Variable ${index + 1}`}
              value={variable}
              onChange={(e) => handleVariableChange(index, e.target.value)}
              style={styles.input}
            />
          ))}

          <button onClick={addVariableField} style={styles.secondaryButton}>
            + Add Variable
          </button>

          {variables.length > 0 && (
            <button onClick={removeVariableField} style={styles.removeButton}>
              - Remove Variable
            </button>
          )}

          <div style={{ margin: '1rem 0' }}>
            <SchoolDropdown
              schools={allSchools}
              onSelect={(tagged) => setTaggedSchools(tagged)}
              checked_s={schools}
            />
          </div>

          <div style={styles.buttonRow}>
            <button onClick={handleSubmit} style={styles.primaryButton}>
              Update Experiment
            </button>
            <button onClick={handleClose} style={styles.cancelButton}>
              Cancel
            </button>
          </div>
        </div>
      </div>
    )
  )
}

export default EditExperimentModal
