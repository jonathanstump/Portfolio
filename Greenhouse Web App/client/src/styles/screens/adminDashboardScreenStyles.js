export const styles = {
  container: {
    padding: '30px',
    backgroundColor: '#F5F5F5',
    minHeight: '100vh',
    fontFamily: 'Inter, sans-serif',
  },
  sectionHeader: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottom: '1px solid #E0E0E0',
    paddingBottom: '10px',
    marginBottom: '20px',
    cursor: 'pointer',
  },
  sectionTitle: {
    fontSize: '20px',
    fontWeight: 'bold',
    color: '#5ca67c',
    margin: 0,
  },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: '12px',
    padding: '20px',
    width: 'calc(25% - 15px)', // 4 per row, accounting for gap
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
    borderLeft: '4px solid #5ca67c',
    transition: 'transform 0.2s ease-in-out',
    cursor: 'pointer',
    boxSizing: 'border-box',
  },
  hoveredCard: {
    transform: 'scale(1.02)',
  },
  cardTitle: {
    fontSize: '18px',
    fontWeight: 'bold',
    marginBottom: '8px',
    color: '#212121',
  },
  cardSubtitle: {
    fontSize: '14px',
    color: '#757575',
    marginBottom: '12px',
  },
  previewContainer: {
    backgroundColor: '#f9f9f9',
    borderRadius: '8px',
    padding: '12px',
    marginTop: '10px',
    boxShadow: 'inset 0 1px 3px rgba(0,0,0,0.05)',
  },
  previewList: {
    listStyleType: 'disc',
    paddingLeft: '20px',
    margin: 0,
  },
  previewItem: {
    fontSize: '14px',
    color: '#424242',
    marginBottom: '6px',
  },
  addExperimentButton: {
    position: 'fixed',
    bottom: 30,
    right: 30,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#5ca67c',
    color: '#fff',
    fontSize: 32,
    fontWeight: 'bold',
    lineHeight: 0,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    cursor: 'pointer',
    boxShadow: '0 4px 8px rgba(92, 166, 124, 0.6)',
    userSelect: 'none',
    border: 'none',
  },
  cardContainer: {
    display: 'flex',
    flexWrap: 'wrap',
    justifyContent: 'flex-start', // or 'center' if you prefer centering
    gap: '20px',
    marginBottom: '30px',
  },
}

export default styles
