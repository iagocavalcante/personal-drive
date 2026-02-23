import getData, { navigateBack } from './../data-manipulate/getData'
import api from './../../../lib/api'

export default function () {
  let onClick = async (e) => {
    e.preventDefault()
    let element = e.target

    // Handle icon clicks
    if (e.target.tagName == 'I') {
      element = e.target.parentElement
    }

    // Handle folder/file item clicks
    const fileItem = element.closest('.file-item')
    if (fileItem) {
      const fileType = fileItem.dataset.type
      const fileId = fileItem.dataset.id
      
      if (fileType === 'folder') {
        // Get folder name from the file item
        const folderName = fileItem.querySelector('.file-name').textContent
        getData({ id: fileId, title: folderName })
        return
      }
    }

    // Handle link clicks (breadcrumbs)
    if (element.tagName == 'A') {
      if (element.dataset.type == 'folder-open') {
        if (element.dataset.fid === 'root') {
          navigateBack() // This will go back to root
        } else {
          getData({
            id: element.dataset.fid,
            title: element.dataset.title
          })
        }
      }
      return
    }

    // Handle download button
    if (element.classList.contains('file-download')) {
      e.stopPropagation()
      try {
        const fileId = element.closest('.file-item').dataset.id
        const response = await api.getDownloadUrl(fileId)
        if (response.download_url) {
          window.open(response.download_url, '_blank')
        }
      } catch (error) {
        console.error('Download failed:', error)
        alert('Download failed')
      }
      return
    }

    // Handle delete button
    if (element.classList.contains('file-delete')) {
      e.stopPropagation()
      if (confirm('Are you sure you want to delete this file?')) {
        try {
          const fileId = element.closest('.file-item').dataset.id
          await api.deleteFile(fileId)
          // Reload current folder
          getData({ id: null, title: 'Home' })
        } catch (error) {
          console.error('Delete failed:', error)
          alert('Delete failed')
        }
      }
      return
    }
  }

  document.querySelector('#main').addEventListener('click', onClick)
}
