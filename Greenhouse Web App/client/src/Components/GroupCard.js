import React, { useState, useEffect } from 'react'
import styles from '../styles/components/groupCardStyles'

const GroupCard = ({
  group,
  school,
  variable_names,
  exp_name,
  onNumberChange,
  onCardClick,
  refreshKey,
}) => {
  const [currNumber, setCurrNumber] = useState(1)
  const [hovered, setHovered] = useState(false)
  const [groups, setGroups] = useState([])
  const [variableNames, setVariableNames] = useState([])

  useEffect(() => {
    const fetchGroupsByNumber = async () => {
      const body = {
        number: group.number,
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
          setGroups(await res.json())
          console.log('Groups w/number: ', groups)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error submitting new group:', err)
      }
    }

    fetchGroupsByNumber()
  }, [group.number, exp_name, school, refreshKey])

  useEffect(() => {
    try {
      const parsed = JSON.parse(variable_names)
      setVariableNames(Array.isArray(parsed) ? parsed : [''])
    } catch (err) {
      console.error('Failed to parse variable_names:', err)
      setVariableNames(Array.isArray(variable_names) ? variable_names : [''])
    }
  }, [variable_names])

  return (
    <div onClick={() => onCardClick(group.number, currNumber)}>
      <div
        style={{
          ...styles.card,
          ...(hovered ? styles.cardHover : {}),
        }}
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
      >
        <h3 style={styles.cardTitle}>Group {group.number}</h3>

        <select
          style={styles.select}
          onChange={(e) => {
            const newVal = Number(e.target.value)
            setCurrNumber(newVal)
            onNumberChange?.(group.number, newVal) // notify parent
          }}
          value={currNumber}
          onClick={(e) => e.stopPropagation()}
        >
          <option value={1}>Lab 1</option>
          {groups
            .filter((group) => group.submission !== 1)
            .map((group, index) => (
              <option key={index} value={group.submission}>
                Lab {group.submission}
              </option>
            ))}
        </select>

        {(() => {
          const selectedGroup = groups.find((g) => g.submission === currNumber)
          if (!selectedGroup) return null

          const raw = selectedGroup.variables
          console.log('raw type:', typeof raw)
          console.log('Vars is : ', raw)
          let parsed = []
          try {
            parsed = JSON.parse(raw)
          } catch (err) {
            console.error(
              `Failed to parse variables for group ${group.number}:`,
              err,
            )
          }

          return variableNames.map((name, index) => (
            <div key={index} style={styles.variableRow}>
              <span style={styles.variableName}>{name}: </span>
              <span style={styles.variableValue}>
                {parsed[index] !== undefined && parsed[index] !== null
                  ? parsed[index]
                  : '—'}
              </span>
            </div>
          ))
        })()}
      </div>
    </div>
  )
}

export default GroupCard
