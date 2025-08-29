import React, { useEffect } from 'react'

const VariableDropdown = ({ variables = [], onSelect, value = '', style }) => {
  const selectedValue = value ?? variables[0] ?? ''

  // Run on mount or when variables change
  // useEffect(() => {
  //   if (selectedValue) {
  //     const index = variables.indexOf(selectedValue)
  //     onSelect(selectedValue, index)
  //   }
  // }, [selectedValue, variables, onSelect])

  return (
    <select
      onChange={(e) => {
        const val = e.target.value
        const index = variables.indexOf(val)
        onSelect(val, index)
      }}
      value={selectedValue}
      style={style}
    >
      {variables.map((v, index) => (
        <option key={index} value={v}>
          {v}
        </option>
      ))}
    </select>
  )
}

export default VariableDropdown
