import api from './../../../lib/api'
import { foldersPath } from './../../files-list/data-manipulate/getData'

export default async function uploadFile(file, name) {
  // Get current folder ID (null for root)
  const parentId = foldersPath.length > 0 ? foldersPath[foldersPath.length - 1].id : null
  
  try {
    // Upload file via API
    const response = await api.uploadFile(file, parentId)
    
    console.log('Upload successful:', response)
    return response
  } catch (error) {
    console.error('Upload failed:', error)
    throw error
  }
}
