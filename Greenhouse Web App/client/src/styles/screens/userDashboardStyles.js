const styles = {
  container: {
    padding: '40px',
    backgroundColor: '#F5F7FA',
    minHeight: '100vh',
  },
  heading: {
    textAlign: 'center',
    fontSize: '28px',
    marginBottom: '32px',
    color: '#277233',
  },
  cardGrid: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '24px',
    justifyContent: 'center',
  },
  card: {
    width: '280px',
    height: '140px',
    backgroundColor: '#FFFFFF',
    borderRadius: '8px',
    border: '1px solid #BFE4C2', // light green thin border
    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    cursor: 'pointer',
    transition: 'transform 0.2s ease, box-shadow 0.2s ease, border 0.2s ease',
  },
  cardHover: {
    transform: 'scale(1.03)',
    boxShadow: '0 6px 16px rgba(0,0,0,0.15)',
    border: '1px solid #277233', // darker green border on hover
  },
  cardTitle: {
    fontSize: '20px',
    color: '#333',
    textAlign: 'center',
    padding: '0 10px',
  },
}

export default styles
