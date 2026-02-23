import api from './../../../lib/api'
import renderFiles from './updateData'

export const foldersPath = []

export default async function (ref) {
  // Update folder path
  const pos = foldersPath.findIndex((e) => e.id == ref.id)
  if (pos == -1) {
    foldersPath.push(ref)
  } else {
    foldersPath.splice(pos + 1, foldersPath.length - pos)
  }

  // Build breadcrumbs
  let breadcrumbs = ' / <a href="" data-type="folder-open" data-fid="root" data-title="Home">Home</a>'
  
  for (let index in foldersPath) {
    breadcrumbs += ` / <a href="" data-type="folder-open" data-fid="${foldersPath[index].id}" data-title="${foldersPath[index].title}">${foldersPath[index].title}</a>`
  }

  // Get current folder ID (null for root)
  const parentId = foldersPath.length > 0 ? foldersPath[foldersPath.length - 1].id : null

  try {
    // Fetch files from API
    const response = await api.getFiles(parentId)
    const files = response.data || []
    
    // Render files
    renderFiles(files)
  } catch (error) {
    console.error('Failed to load files:', error)
    renderFiles([])
  }

  document.querySelector('#path').innerHTML = breadcrumbs
}

export function navigateToFolder(folderId, folderTitle) {
  const ref = { id: folderId, title: folderTitle }
  default(ref)
}

export function navigateBack() {
  if (foldersPath.length > 1) {
    foldersPath.pop()
    const parent = foldersPath[foldersPath.length - 1]
    navigateToFolder(parent.id, parent.title)
  } else {
    // Go to root
    foldersPath.length = 0
    navigateToFolder(null, 'Home')
  }
}

// Alias for backwards compatibility
const default = export default
