/**
 * Optimistic UI operations for Personal Drive
 * Updates UI immediately before server responds
 */

// Add a file to the UI immediately (before upload completes)
export function addFileOptimistic(fileData) {
  const container = document.querySelector('#main .files')
  if (!container) return null
  
  // Check if no-files message exists
  const noFiles = container.querySelector('.no-files')
  if (noFiles) {
    container.innerHTML = ''
  }
  
  // Create optimistic file element
  const tempId = `temp-${Date.now()}`
  const fileElement = createFileElement({
    id: tempId,
    name: fileData.name,
    size: fileData.size,
    content_type: fileData.content_type,
    is_folder: false,
    optimistic: true // Mark as optimistic
  })
  
  container.insertAdjacentHTML('beforeend', fileElement)
  
  // Add uploading class
  const el = container.querySelector(`[data-id="${tempId}"]`)
  el.classList.add('uploading')
  
  return { tempId, element: el }
}

// Update optimistic file to real file after upload completes
export function confirmFileUpload(tempId, realFile) {
  const container = document.querySelector('#main .files')
  if (!container) return
  
  const tempEl = container.querySelector(`[data-id="${tempId}"]`)
  if (tempEl) {
    // Replace with real file
    const realElement = createFileElement(realFile)
    tempEl.replaceWith(realElement)
  }
}

// Remove optimistic file on upload failure
export function removeFileOptimistic(tempId) {
  const container = document.querySelector('#main .files')
  if (!container) return
  
  const tempEl = container.querySelector(`[data-id="${tempId}"]`)
  if (tempEl) {
    tempEl.remove()
    
    // Show no-files if empty
    const remaining = container.querySelectorAll('.file-item')
    if (remaining.length === 0) {
      container.innerHTML = '<div class="no-files">No files or folders found</div>'
    }
  }
}

// Optimistic delete - remove immediately
export function deleteFileOptimistic(fileId) {
  const container = document.querySelector('#main .files')
  if (!container) return
  
  const fileEl = container.querySelector(`[data-id="${fileId}"]`)
  if (fileEl) {
    fileEl.classList.add('deleting')
    // Animate out
    fileEl.style.opacity = '0.5'
    fileEl.style.transform = 'translateX(-20px)'
    
    setTimeout(() => {
      fileEl.remove()
      
      // Show no-files if empty
      const remaining = container.querySelectorAll('.file-item')
      if (remaining.length === 0) {
        container.innerHTML = '<div class="no-files">No files or folders found</div>'
      }
    }, 200)
  }
}

// Restore file if delete fails
export function restoreFile(fileData) {
  const container = document.querySelector('#main .files')
  if (!container) return
  
  // Remove deleting class and restore
  const fileEl = container.querySelector(`[data-id="${fileData.id}"]`)
  if (fileEl) {
    fileEl.classList.remove('deleting')
    fileEl.style.opacity = '1'
    fileEl.style.transform = 'none'
  } else {
    // Re-add to container
    const noFiles = container.querySelector('.no-files')
    if (noFiles) {
      container.innerHTML = ''
    }
    
    const fileElement = createFileElement(fileData)
    container.insertAdjacentHTML('beforeend', fileElement)
  }
}

// Create HTML for a file item
function createFileElement(file) {
  const icon = file.is_folder ? 'folder' : getFileIcon(file.content_type)
  const url = file.is_folder ? '' : file.r2_key || ''
  const size = file.is_folder ? '' : formatSize(file.size)
  
  return `
    <div class="file-item ${file.optimistic ? 'uploading' : ''} ${file.deleting ? 'deleting' : ''}" 
         data-id="${file.id}" 
         data-type="${file.is_folder ? 'folder' : 'file'}">
      <div class="file-icon">
        ${file.optimistic 
          ? '<i class="fa fa-spinner fa-spin"></i>' 
          : `<i class="fa fa-${icon}"></i>`
        }
      </div>
      <div class="file-info">
        <div class="file-name">${file.name}</div>
        <div class="file-meta">${file.optimistic ? 'Uploading...' : size}</div>
      </div>
      <div class="file-actions">
        ${!file.is_folder ? `<a href="#" class="file-download" data-url="${url}"><i class="fa fa-download"></i></a>` : ''}
        <a href="#" class="file-delete" data-id="${file.id}"><i class="fa fa-trash"></i></a>
      </div>
    </div>
  `
}

function getFileIcon(contentType) {
  if (!contentType) return 'file'
  
  if (contentType.startsWith('image/')) return 'image'
  if (contentType.startsWith('video/')) return 'video-camera'
  if (contentType.startsWith('audio/')) return 'music'
  if (contentType.includes('pdf')) return 'file-pdf-o'
  if (contentType.includes('zip') || contentType.includes('rar') || contentType.includes('tar')) return 'file-archive-o'
  if (contentType.includes('text')) return 'file-text'
  
  return 'file'
}

function formatSize(bytes) {
  if (!bytes || bytes === 0) return ''
  
  const units = ['B', 'KB', 'MB', 'GB']
  let unitIndex = 0
  let size = bytes
  
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024
    unitIndex++
  }
  
  return `${size.toFixed(1)} ${units[unitIndex]}`
}
