import api from './../../lib/api'

export default async function (fileId) {
  const email = prompt('Enter email address to share with:')
  
  if (!email) {
    return
  }
  
  try {
    const result = await api.shareFile(fileId, email)
    
    if (result.success) {
      alert('File shared successfully!')
    } else {
      alert(result.error || 'Failed to share file')
    }
  } catch (error) {
    console.error('Share failed:', error)
    alert('Failed to share file: ' + error.message)
  }
}
