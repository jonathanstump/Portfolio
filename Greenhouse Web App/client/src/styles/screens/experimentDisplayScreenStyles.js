export const styles = {
  container: {
    padding: '40px 20px',
    maxWidth: '900px',
    margin: '0 auto',
    fontFamily: "'Inter', sans-serif",
    color: '#023D54',
  },
  title: {
    fontSize: '32px',
    fontWeight: '700',
    color: '#277233',
    textAlign: 'center',
    marginBottom: '20px',
  },
  schoolList: {
    display: 'flex',
    justifyContent: 'center',
    gap: '16px',
    flexWrap: 'wrap',
    marginBottom: '40px',
  },
  schoolItem: {
    backgroundColor: '#BFE4C2',
    color: '#023D54',
    padding: '6px 14px',
    borderRadius: '12px',
    fontSize: '14px',
    fontWeight: '500',
    boxShadow: '0 2px 5px rgba(0, 0, 0, 0.08)',
    cursor: 'pointer',
    transition: 'color 0.2s ease, text-decoration 0.2s ease',
  },
  schoolItemHover: {
    color: '#5ca67c',
    textDecoration: 'underline',
  },
  section: {
    marginBottom: '28px',
    textAlign: 'left',
  },
  sectionTitle: {
    fontSize: '26px', // slightly bigger
    fontWeight: '600',
    color: '#277233',
    marginBottom: '10px',
  },
  sectionText: {
    fontSize: '16px',
    color: '#333',
    paddingLeft: '20px', // indented text
    lineHeight: 1.6,
  },
}

export default styles
