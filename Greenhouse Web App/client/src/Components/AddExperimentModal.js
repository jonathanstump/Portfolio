import React, { useState } from 'react'
import SchoolDropdown from './SchoolDropdown'
import { styles } from '../styles/components/addExperimentModalStyles'

const AddExperimentModal = ({ schools = [], closeModal, submit }) => {
  const [experimentTitle, setExperimentTitle] = useState('')
  const [variables, setVariables] = useState([''])
  const [taggedSchools, setTaggedSchools] = useState([])
  const [showModal, setShowModal] = useState(true)
  const [titleError, setTitleError] = useState(false)

  const handleVariableChange = (index, value) => {
    const updated = [...variables]
    updated[index] = value
    setVariables(updated)
  }

  const addVariableField = () => {
    setVariables([...variables, ''])
  }

  const handleSubmit = () => {
    if (!experimentTitle.trim()) {
      setTitleError(true)
      return
    }
    submit(experimentTitle, variables, taggedSchools)
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

  return (
    <div style={getOverlayStyle()}>
      <div style={styles.modal}>
        <h2 style={styles.header}>Add New Experiment</h2>

        <input
          type="text"
          placeholder="Experiment Title"
          value={experimentTitle}
          onChange={(e) => {
            setExperimentTitle(e.target.value)
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

        <div style={{ margin: '1rem 0' }}>
          <SchoolDropdown
            schools={schools}
            onSelect={(tagged) => setTaggedSchools(tagged)}
          />
        </div>

        <div style={styles.buttonRow}>
          <button onClick={handleSubmit} style={styles.primaryButton}>
            Submit Experiment
          </button>
          <button onClick={handleClose} style={styles.cancelButton}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}

export default AddExperimentModal
