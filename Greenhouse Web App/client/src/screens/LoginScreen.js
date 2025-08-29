import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import styles from '../styles/screens/loginScreenStyles'
import logoSrc from '../assets/ghv-logo.png'
import SingleSchoolSelector from '../Components/SingleSchoolSelector'

const Login = () => {
  const [activeTab, setActiveTab] = useState('school')
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [selectedSchoolName, setSelectedSchoolName] = useState('')
  const navigate = useNavigate()

  const handleLogin = async () => {
    try {
      const body = {
        role: activeTab,
        password,
      }

      if (activeTab === 'admin') {
        body.username = username
      } else if (activeTab === 'school') {
        body.selectedSchoolName = selectedSchoolName
      }

      const response = await fetch('http://localhost:5000/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
        credentials: 'include',
      })

      if (response.ok) {
        console.log(await response.text())
        if (activeTab === 'admin') {
          navigate('/admin-dashboard')
        } else if (activeTab === 'school') {
          navigate('/dashboard', { state: { selectedSchoolName } })
        }
      } else {
        alert(await response.text())
      }
    } catch (err) {
      console.error('Login error:', err)
      alert('Something went wrong. Try again.')
    }
  }

  return (
    <div style={styles.container}>
      <div style={styles.box}>
        <img src={logoSrc} alt="Greenhouse STL" style={styles.logo} />

        <div style={styles.tabContainer}>
          <div
            style={styles.tab(activeTab === 'school')}
            onClick={() => setActiveTab('school')}
          >
            School Login
          </div>
          <div
            style={styles.tab(activeTab === 'admin')}
            onClick={() => setActiveTab('admin')}
          >
            Admin Login
          </div>
        </div>

        {activeTab === 'admin' ? (
          <input
            style={styles.input}
            placeholder="Admin Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
        ) : (
          <div style={{ marginBottom: '1rem' }}>
            <SingleSchoolSelector
              value={selectedSchoolName}
              onSelect={setSelectedSchoolName}
            />
          </div>
        )}

        <input
          type="password"
          style={styles.input}
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />

        <button style={styles.button} onClick={handleLogin}>
          {activeTab === 'school'
            ? 'Login as School'
            : 'Login as Administrator'}
        </button>
      </div>
    </div>
  )
}

export default Login
