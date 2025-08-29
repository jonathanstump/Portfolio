import { useEffect, useState } from 'react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'

const LineGraph = ({ groups = [], currVar, index }) => {
  const [averages, setAverages] = useState([])

  useEffect(() => {
    const newAverages = []

    let count = 1
    while (true) {
      const curr = groups.filter((group) => group.submission === count)
      if (curr.length === 0) break

      let sum = 0
      let avCount = 0

      curr.forEach((group) => {
        let groupValues = []
        try {
          const parsed = JSON.parse(group.variables)
          groupValues = Array.isArray(parsed) ? parsed : ['']
        } catch (err) {
          console.error('Failed to parse group variable values:', err)
          groupValues = Array.isArray(group.variables) ? group.variables : ['']
        }

        const val = Number(groupValues[index])
        if (!isNaN(val)) {
          sum += val
          avCount++
        }
      })

      newAverages.push(avCount ? sum / avCount : 0)
      count++
    }

    setAverages(newAverages)
  }, [groups, index])

  // check if all averages are zero (no valid values for this variable)
  const allZero = averages.length > 0 && averages.every((val) => val === 0)

  if (averages.length === 0 || allZero) {
    return (
      <div style={{ textAlign: 'center', padding: '1rem', color: '#666' }}>
        No graph available for <strong>{currVar}</strong>
      </div>
    )
  }

  // shape data for recharts
  const data = averages.map((avg, i) => ({
    lab: i + 1, // x-axis (lab number)
    value: avg, // y-axis (average)
  }))

  // keep color consistent across line + title
  const lineColor = '#5ca67c' // green color for line and title

  return (
    <div style={{ width: '100%', height: 380, padding: '1rem' }}>
      <h3
        style={{
          textAlign: 'center',
          marginBottom: '1rem',
          fontSize: '1.25rem',
          fontWeight: '600',
          color: lineColor, // use green
        }}
      >
        Average {currVar} by Lab
      </h3>
      <ResponsiveContainer>
        <LineChart
          data={data}
          margin={{ top: 20, right: 30, left: 40, bottom: 30 }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="#ccc" />
          <XAxis
            dataKey="lab"
            label={{
              value: 'Lab Number',
              position: 'insideBottom',
              offset: -10,
              style: { fill: '#333', fontSize: 14 },
            }}
            tick={{ fill: '#555', fontSize: 12 }}
            axisLine={{ stroke: '#888' }}
            tickLine={{ stroke: '#888' }}
          />
          <YAxis
            label={{
              value: currVar,
              angle: -90,
              position: 'insideLeft',
              style: { fill: '#333', fontSize: 14 },
            }}
            tick={{ fill: '#555', fontSize: 12 }}
            axisLine={{ stroke: '#888' }}
            tickLine={{ stroke: '#888' }}
          />
          <Tooltip
            contentStyle={{ backgroundColor: '#fff', border: '1px solid #ccc' }}
            itemStyle={{ color: '#333' }}
            labelStyle={{ fontWeight: 'bold', color: '#000' }}
          />
          <Line
            type="monotone"
            dataKey="value"
            stroke={lineColor} // green line
            strokeWidth={3}
            dot={{ r: 5, fill: lineColor, stroke: '#fff', strokeWidth: 2 }}
            activeDot={{
              r: 7,
              fill: lineColor,
              stroke: '#fff',
              strokeWidth: 2,
            }}
            label={{
              position: 'top',
              fill: '#111',
              fontSize: 12,
              fontWeight: 'bold',
            }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}

export default LineGraph
