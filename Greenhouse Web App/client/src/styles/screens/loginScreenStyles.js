const styles = {
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    backgroundColor: '#F5F7FA', // light neutral background
  },
  box: {
    width: 360,
    padding: 32,
    borderRadius: 8,
    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
    backgroundColor: '#FFFFFF',
    textAlign: 'center',
  },
  logo: {
    width: 120,
    marginBottom: 24,
  },
  tabContainer: {
    display: 'flex',
    marginBottom: 24,
    borderBottom: '2px solid #E0E0E0',
  },
  tab: (active) => ({
    flex: 1,
    padding: '8px 0',
    cursor: 'pointer',
    fontWeight: active ? '600' : '400',
    color: active ? '#277233' : '#555', // Greenhouse green
    borderBottom: active ? '3px solid #277233' : '3px solid transparent',
  }),
  input: {
    width: '100%',
    padding: '10px 12px',
    marginBottom: 16,
    borderRadius: 4,
    border: '1px solid #CCC',
    fontSize: 16,
  },
  button: {
    width: '100%',
    padding: '12px',
    border: 'none',
    borderRadius: 4,
    backgroundColor: '#277233',
    color: '#fff',
    fontSize: 16,
    cursor: 'pointer',
  },
};

export default styles;