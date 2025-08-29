import { Routes, Route } from 'react-router-dom'
import LoginScreen from './screens/LoginScreen'
import UserDashboardScreen from './screens/user/UserDashboardScreen'
import ExperimentDisplayScreen from './screens/user/ExperimentDisplayScreen'
import AdminDashboardScreen from './screens/admin/AdminDashboardScreen'
import ExperimentHandlerScreen from './screens/admin/ExperimentHandlerScreen'
import SchoolExperimentScreen from './screens/admin/SchoolExperimentScreen'
import IndividualSchoolScreen from './screens/user/IndividualSchoolScreen'

function App() {
  return (
    <Routes>
      <Route path="/" element={<LoginScreen />} />
      <Route path="/dashboard" element={<UserDashboardScreen />} />
      <Route path="/school-exp" element={<ExperimentDisplayScreen />} />
      <Route path="/admin-dashboard" element={<AdminDashboardScreen />} />
      <Route path="/exp" element={<ExperimentHandlerScreen />} />
      <Route path="/exp-school" element={<SchoolExperimentScreen />} />
      <Route path="/indv-school-exp" element={<IndividualSchoolScreen />} />
    </Routes>
  )
}

export default App
