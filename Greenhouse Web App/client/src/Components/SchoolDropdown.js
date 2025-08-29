import React, { useState, useEffect, useRef } from 'react'

const SchoolDropdown = ({ schools = [], onSelect, checked_s = [] }) => {
  const [isOpen, setIsOpen] = useState(false)
  const [selectedSchools, setSelectedSchools] = useState([])
  const hasInitialized = useRef(false)

  useEffect(() => {
    onSelect(selectedSchools)
  }, [selectedSchools, onSelect])

  useEffect(() => {
    console.log('checked schools:', checked_s)
    if (
      !hasInitialized.current &&
      Array.isArray(checked_s) &&
      checked_s.length > 0
    ) {
      console.log('in dis hoe')
      const matched = schools.filter((school) =>
        checked_s.some((checked) => checked.id === school.id),
      )
      console.log('Matched', matched)
      setSelectedSchools(matched)
      hasInitialized.current = true
    }
  }, [checked_s, schools])

  const toggleDropdown = () => {
    console.log('SelectedSchools: ', selectedSchools)
    setIsOpen((prev) => !prev)
  }

  const toggleSchool = (school) => {
    const isSelected = selectedSchools.some((s) => s.id === school.id)
    const updated = isSelected
      ? selectedSchools.filter((s) => s.id !== school.id)
      : [...selectedSchools, school]
    setSelectedSchools(updated)
  }

  const toggleSelectAll = () => {
    if (selectedSchools.length === schools.length) {
      setSelectedSchools([])
    } else {
      setSelectedSchools([...schools])
    }
  }

  const isAllSelected =
    schools.length > 0 && selectedSchools.length === schools.length

  return (
    <div style={styles.container}>
      <button onClick={toggleDropdown} style={styles.button} type="button">
        {selectedSchools.length === 0
          ? 'Select Schools'
          : `${selectedSchools.length} selected`}
        <span style={styles.caret}>{isOpen ? '▲' : '▼'}</span>
      </button>

      {isOpen && (
        <div style={styles.dropdown}>
          <label style={{ ...styles.option, fontWeight: 'bold' }}>
            <input
              type="checkbox"
              checked={isAllSelected}
              onChange={toggleSelectAll}
            />
            Select All
          </label>
          {schools.map((school) => {
            const isSelected = selectedSchools.some((s) => s.id === school.id)
            return (
              <label key={school.id} style={styles.option}>
                <input
                  type="checkbox"
                  checked={isSelected}
                  onChange={() => toggleSchool(school)}
                />
                {school.name}
              </label>
            )
          })}
        </div>
      )}
    </div>
  )
}

const styles = {
  container: {
    position: 'relative',
    width: '240px',
  },
  button: {
    width: '100%',
    padding: '0.6rem 1rem',
    borderRadius: '10px',
    border: '2px solid #5ca67c',
    backgroundColor: '#f5f5f5',
    color: '#023D54',
    fontSize: '1rem',
    fontWeight: '500',
    cursor: 'pointer',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  caret: {
    marginLeft: 'auto',
    fontSize: '0.8rem',
  },
  dropdown: {
    position: 'absolute',
    top: '100%',
    left: 0,
    zIndex: 1000,
    backgroundColor: '#ffffff',
    border: '1px solid #E0E0E0',
    borderRadius: '10px',
    marginTop: '0.4rem',
    padding: '0.8rem',
    boxShadow: '0 4px 8px rgba(0,0,0,0.1)',
    width: '100%',
  },
  option: {
    display: 'flex',
    alignItems: 'center',
    gap: '0.5rem',
    padding: '0.3rem 0',
    color: '#424242',
    fontSize: '0.95rem',
  },
}

export default SchoolDropdown
