/**
 * Phoenix API Client for Personal Drive
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api/v1'

class ApiClient {
  constructor() {
    this.token = localStorage.getItem('auth_token')
  }

  setToken(token) {
    this.token = token
    if (token) {
      localStorage.setItem('auth_token', token)
    } else {
      localStorage.removeItem('auth_token')
    }
  }

  getToken() {
    return this.token || localStorage.getItem('auth_token')
  }

  async request(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`
    
    const headers = {
      ...options.headers
    }

    const token = this.getToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    const response = await fetch(url, {
      ...options,
      headers,
      credentials: 'include' // Important: include cookies for session auth
    })

    // Handle empty responses
    const text = await response.text()
    if (!text) {
      return {}
    }

    try {
      const data = JSON.parse(text)
      
      if (!response.ok) {
        if (response.status === 401) {
          this.setToken(null)
          localStorage.removeItem('user')
          window.dispatchEvent(new CustomEvent('auth:logout'))
        }
        throw new Error(data.error || `API Error: ${response.status}`)
      }

      return data
    } catch (e) {
      if (!response.ok) {
        throw new Error(`API Error: ${response.status}`)
      }
      return {}
    }
  }

  // Auth
  async register(email, password) {
    return this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })
  }

  async login(email, password) {
    return this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })
  }

  async logout() {
    try {
      await this.request('/auth/logout', { method: 'POST' })
    } catch (e) {
      // Ignore errors
    }
    this.setToken(null)
    localStorage.removeItem('user')
  }

  // Files
  async getFiles(parentId = null) {
    const endpoint = parentId ? `/files?parent_id=${parentId}` : '/files'
    return this.request(endpoint)
  }

  async getFile(id) {
    return this.request(`/files/${id}`)
  }

  async createFolder(name, parentId = null) {
    const body = { name }
    if (parentId) body.parent_id = parentId
    
    return this.request('/files/folder', {
      method: 'POST',
      body: JSON.stringify(body)
    })
  }

  async uploadFile(file, parentId = null) {
    const formData = new FormData()
    formData.append('file', file)
    if (parentId) formData.append('parent_id', parentId)

    const url = `${API_BASE_URL}/files/upload`
    
    const response = await fetch(url, {
      method: 'POST',
      body: formData,
      credentials: 'include'
    })

    if (!response.ok) {
      throw new Error('Upload failed')
    }

    return response.json()
  }

  async getDownloadUrl(fileId) {
    return this.request(`/files/${fileId}/download`)
  }

  async deleteFile(fileId) {
    return this.request(`/files/${fileId}`, {
      method: 'DELETE'
    })
  }
}

export const api = new ApiClient()
export default api
