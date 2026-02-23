import api from './../../../lib/api'
import { foldersPath } from './../../files-list/data-manipulate/getData'
import { addFileOptimistic, confirmFileUpload, removeFileOptimistic } from './../../../lib/optimistic'

export default async function uploadFile(file, name) {
  // Get current folder ID (null for root)
  const parentId = foldersPath.length > 0 ? foldersPath[foldersPath.length - 1].id : null
  
  // Add file to UI optimistically
  const optimistic = addFileOptimistic({
    name: name,
    size: file.size,
    content_type: file.type || 'application/octet-stream'
  })
  
  try {
    // Upload file via API
    const response = await api.uploadFile(file, parentId)
    
    // Confirm the upload in UI
    if (optimistic && response.data) {
      confirmFileUpload(optimistic.tempId, response.data)
    }
    
    return response
  } catch (error) {
    console.error('Upload failed:', error)
    
    // Remove optimistic file on failure
    if (optimistic) {
      removeFileOptimistic(optimistic.tempId)
    }
    
    throw error
  }
}
