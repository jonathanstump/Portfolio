import React, { useState, useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import GroupCard from '../../Components/GroupCard'
import AddGroupModal from '../../Components/AddGroupModal'
import EditGroupModal from '../../Components/EditGroupModal'
import styles from '../../styles/screens/schoolExperimentScreenStyles'

const SchoolExperimentScreen = () => {
  const location = useLocation()
  const experiment = location?.state?.exp
  const school = location?.state?.school
  const [modalVisible, setModalVisible] = useState(false)
  const [editVisible, setEditVisible] = useState(false)
  const [groups, setGroups] = useState([])
  const [cardSubmissions, setCardSubmissions] = useState({})
  const [modalData, setModalData] = useState(null)
  const [refreshKey, setRefreshKey] = useState(0)
  const [numUniqueGroups, setNumUniqueGroups] = useState(0)
  const [pending, setPending] = useState([])

  useEffect(() => {
    const fetchGroupData = async () => {
      const body = { name: experiment.name, school: school.name }
      try {
        const res = await fetch('http://localhost:5000/api/groups', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        })
        if (res.ok) {
          const data = await res.json()
          setGroups(data)
          const count = data.filter((group) => group.submission === 1).length
          setNumUniqueGroups(count)
        } else {
          console.error(await res.text())
        }
      } catch (err) {
        console.error('Error fetching groups:', err)
      }
    }
    fetchGroupData()
  }, [experiment.name, school.name])

  const fetchPending = async () => {
    const body = {
      expName: experiment.name,
      schoolId: school.id,
    }
    try {
      const res = await fetch('http://localhost:5000/api/images/pending', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body), // <-- send school.id
      })
      const data = await res.json()
      setPending(data)
    } catch (err) {
      console.error('Error fetching pending images:', err)
    }
  }

  useEffect(() => {
    fetchPending()
  }, [])

  const handleApprove = async (id) => {
    try {
      const res = await fetch(`http://localhost:5000/api/images/${id}/status`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'approved' }),
      })
      const data = await res.json()
      if (data.success) fetchPending()
    } catch (err) {
      console.error('Error approving image:', err)
    }
  }

  const handleReject = async (id) => {
    try {
      const res = await fetch(`http://localhost:5000/api/images/${id}/status`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'rejected' }),
      })
      const data = await res.json()
      if (data.success) fetchPending()
    } catch (err) {
      console.error('Error rejecting image:', err)
    }
  }

  const handleCardNumberChange = (groupNumber, submissionNumber) => {
    setCardSubmissions((prev) => ({
      ...prev,
      [groupNumber]: submissionNumber,
    }))
  }

  const handleCardClick = (groupNumber, currNumber) => {
    setModalData({ groupNumber, currNumber })
    setEditVisible(true)
  }

  const handleEditClose = () => {
    setEditVisible(false)
    setRefreshKey((prev) => prev + 1)
  }

  const handleNewGroup = async (values) => {
    const body = {
      name: experiment.name,
      school: school.name,
      variables: values,
      number: groups.length + 1,
      submission: 1,
    }

    try {
      const res = await fetch('http://localhost:5000/api/groupSubmission', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      if (res.ok) {
        setNumUniqueGroups((prev) => prev + 1)
        const groupRes = await fetch('http://localhost:5000/api/groups', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: experiment.name, school: school.name }),
        })
        if (groupRes.ok) {
          const groupData = await groupRes.json()
          setGroups(groupData)
        }
      } else {
        console.error(await res.text())
      }
    } catch (err) {
      console.error('Error submitting new group:', err)
    }
  }

  return (
    <div style={styles.container}>
      <div style={styles.headerRow}>
        <h2 style={styles.title}>
          {experiment.name} - {school.name}
        </h2>
        <button
          style={styles.addExperimentButton}
          onClick={() => setModalVisible(true)}
          aria-label="Add Experiment"
        >
          +
        </button>
      </div>

      {modalVisible && (
        <AddGroupModal
          experiment={experiment}
          number={numUniqueGroups + 1}
          closeModal={setModalVisible}
          submit={handleNewGroup}
        />
      )}

      <div style={styles.groupsContainer}>
        {groups
          .filter((group) => group.submission === 1)
          .map((group, index) => (
            <GroupCard
              key={index}
              group={group}
              school={school.name}
              variable_names={experiment.elements}
              exp_name={experiment.name}
              onNumberChange={handleCardNumberChange}
              onCardClick={handleCardClick}
              refreshKey={refreshKey}
            />
          ))}
      </div>

      <div style={styles.imagesSection}>
        <h3 style={styles.sectionTitle}>Images of the Week</h3>
        <div style={styles.imagesGrid}>
          {pending.map((img) => {
            const src = `http://localhost:5000/uploads/${img.schoolId}/${img.week}/${img.filename}`
            console.log('Image src:', src)
            return (
              <div key={img.id} style={styles.imageCard}>
                <img src={src} alt="Weekly submission" style={styles.image} />
                <div style={styles.imageButtons}>
                  <button
                    onClick={() => handleApprove(img.id)}
                    style={{ ...styles.actionButton, ...styles.approveButton }}
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => handleReject(img.id)}
                    style={{ ...styles.actionButton, ...styles.rejectButton }}
                  >
                    Reject
                  </button>
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {editVisible && (
        <EditGroupModal
          num={modalData.groupNumber}
          sub={modalData.currNumber}
          exp_name={experiment.name}
          school={school.name}
          vars={experiment.elements}
          onClose={handleEditClose}
        />
      )}
    </div>
  )
}

export default SchoolExperimentScreen
