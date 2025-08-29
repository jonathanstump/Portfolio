import React, { useState, useEffect } from 'react'
import { styles } from '../styles/components/addExperimentModalStyles'

const AddGroupModal = ({ experiment, number, closeModal, submit }) => {
  const [variables, setVariables] = useState([])
  const [showModal, setShowModal] = useState(true)
  const [values, setValues] = useState([])

  useEffect(() => {
    try {
      const parsed = JSON.parse(experiment.elements)
      const vars = Array.isArray(parsed) ? parsed : ['']
      setVariables(vars)
      setValues(Array(vars.length).fill(''))
    } catch (err) {
      console.error('Failed to parse elements:', err)
      setVariables([''])
      setValues([''])
    }
  }, [experiment.elements])

  const handleValueChange = (index, value) => {
    setValues((prev) => {
      const updated = [...prev]
      updated[index] = value
      return updated
    })
  }

  const handleSubmit = () => {
    // const result = {}
    // variables.forEach((v, i) => {
    //   result[v] = values[i]
    // })
    submit(values)
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
        <h2 style={styles.header}>Add New Group</h2>
        <h3>Group {number}</h3>
        <h4>Submission 1</h4>

        {variables.map((variable, index) => (
          <div
            key={index}
            style={{
              marginBottom: '1rem',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <label
              style={{
                marginBottom: '0.5rem',
                fontWeight: '600',
                color: '#023D54',
              }}
            >
              {variable}
            </label>
            <input
              type="text"
              placeholder="Enter a value"
              value={values[index]}
              onChange={(e) => handleValueChange(index, e.target.value)}
              disabled={index > 0 && values[index - 1].trim() === ''}
              style={{
                ...styles.input,
                backgroundColor:
                  index > 0 && values[index - 1].trim() === ''
                    ? '#f0f0f0'
                    : 'white',
              }}
            />
          </div>
        ))}

        <div style={styles.buttonRow}>
          <button onClick={handleSubmit} style={styles.primaryButton}>
            Submit Group
          </button>
          <button onClick={handleClose} style={styles.cancelButton}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}

export default AddGroupModal
