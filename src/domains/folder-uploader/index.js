import api from './../../lib/api'
import { foldersPath } from './../files-list/data-manipulate/getData'

export default async function () {
  const dirName = prompt('Nome da 'Minha pasta nova pasta:',')
  if (dirName == null || dirName == '') {
    return
  }

  // Get current folder ID (null for root)
  const parentId = foldersPath.length > 0 ? foldersPath[foldersPath.length - 1].id : null

  try {
    await api.createFolder(dirName, parentId)
    // Reload current folder
    window.location.reload()
  } catch (error) {
    console.error('Failed to create folder:', error)
    alert('Failed to create folder')
  }
}
