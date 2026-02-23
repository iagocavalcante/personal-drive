import api from './../../lib/api'

export default async function () {
  try {
    const response = await api.getSharedWithMe()
    const files = response.data || []
    
    let html = ''
    for (let file of files) {
      html += `<li>
        <a href="#" data-type="file-open" data-id="${file.id}">
          ${file.name}
        </a>
        (shared by: ${file.shared_by})
      </li>`
    }
    
    if (html === '') {
      html = '<li>No files shared with you</li>'
    }
    
    html += '<li><a href="#" data-action="my-files">View my files</a></li>'
    
    document.getElementById('shared-list').innerHTML = html
  } catch (error) {
    console.error('Failed to load shared files:', error)
    document.getElementById('shared-list').innerHTML = '<li>Failed to load shared files</li>'
  }
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
  // Check if we're on the shared page
  if (document.getElementById('shared-list')) {
    export default()
  }
})
