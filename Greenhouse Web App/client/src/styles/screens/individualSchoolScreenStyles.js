const styles = {
  container: {
    padding: '40px 20px',
    maxWidth: '1000px',
    margin: '0 auto',
    fontFamily: "'Inter', sans-serif",
  },
  headerRow: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: '30px',
  },
  title: {
    fontSize: '28px',
    fontWeight: '700',
    color: '#023D54',
  },
  section: {
    marginBottom: '40px',
  },
  sectionTitle: {
    fontSize: '22px',
    fontWeight: '600',
    color: '#023D54',
    marginBottom: '20px',
  },
  imageGrid: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '20px',
    justifyContent: 'flex-start',
  },
  imageWrapper: {
    borderRadius: '8px',
    overflow: 'hidden',
    boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
    backgroundColor: '#fff',
    padding: '4px',
    border: '2px solid #5ca67c', // updated green border
  },
  image: {
    width: '220px',
    height: 'auto',
    display: 'block',
  },
  emptyText: {
    color: '#666',
    fontStyle: 'italic',
  },
  graphControls: {
    marginBottom: '20px',
    display: 'flex',
    justifyContent: 'flex-start',
  },
  graphWrapper: {
    padding: '20px',
    border: '1px solid #E0E0E0',
    borderRadius: '10px',
    backgroundColor: '#fff',
    boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
    minHeight: '450px',
  },
  dropdown: {
    backgroundColor: '#ffffff',
    border: '2px solid #5ca67c', // updated green border
    borderRadius: '10px',
    padding: '0.6rem',
    boxShadow: '0 4px 8px rgba(0,0,0,0.05)',
    width: '250px',
    fontSize: '14px',
  },
}

export default styles
