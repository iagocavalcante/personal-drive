export default function renderFiles(files) {
  const container = document.querySelector('#main .files')
  
  if (!container) {
    console.error('Files container not found')
    return
  }

  if (!files || files.length === 0) {
    container.innerHTML = '<div class="no-files">No files or folders found</div>'
    return
  }

  // Sort: folders first, then files
  const folders = files.filter(f => f.is_folder).sort((a, b) => a.name.localeCompare(b.name))
  const regularFiles = files.filter(f => !f.is_folder).sort((a, b) => a.name.localeCompare(b.name))
  
  const sortedFiles = [...folders, ...regularFiles]

  let html = ''
  for (let file of sortedFiles) {
    const icon = file.is_folder ? 'folder' : getFileIcon(file.content_type)
    const url = file.is_folder ? '' : file.r2_key
    const size = file.is_folder ? '' : formatSize(file.size)
    
    html += `
      <div class="file-item" data-id="${file.id}" data-type="${file.is_folder ? 'folder' : 'file'}">
        <div class="file-icon">
          <i class="fa fa-${icon}"></i>
        </div>
        <div class="file-info">
          <div class="file-name">${file.name}</div>
          <div class="file-meta">${size}</div>
        </div>
        <div class="file-actions">
          ${!file.is_folder ? `<a href="#" class="file-download" data-url="${url}"><i class="fa fa-download"></i></a>` : ''}
          <a href="#" class="file-delete" data-id="${file.id}"><i class="fa fa-trash"></i></a>
        </div>
      </div>
    `
  }

  container.innerHTML = html
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
