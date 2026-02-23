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
      'Content-Type': 'application/json',
      ...options.headers
    }

    const token = this.getToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    const response = await fetch(url, {
      ...options,
      headers
    })

    if (!response.ok) {
      if (response.status === 401) {
        this.setToken(null)
        window.dispatchEvent(new CustomEvent('auth:logout'))
      }
      throw new Error(`API Error: ${response.status}`)
    }

    return response.json()
  }

  // Auth
  async register(email, password) {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    
    if (!response.ok) {
      throw new Error('Registration failed')
    }
    
    return response.json()
  }

  async login(email, password) {
    const response = await fetch(`${API_BASE_URL}/auth/session`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify({ email, password })
    })
    
    if (!response.ok) {
      throw new Error('Login failed')
    }
    
    // Get token from cookie or response
    const data = await response.json()
    if (data.token) {
      this.setToken(data.token)
    }
    
    return data
  }

  async logout() {
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

    const token = this.getToken()
    const response = await fetch(`${API_BASE_URL}/files/upload`, {
      method: 'POST',
      headers: token ? { 'Authorization': `Bearer ${token}` } : {},
      body: formData
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
