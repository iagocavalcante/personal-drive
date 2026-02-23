import api from './../../lib/api'
import fileListComponent from './../../domains/files-list/'
import { UserClass } from './user/user'

let template = document.createElement('template')
template.innerHTML = require('./template/index.html')
template = template.content.childNodes

document.querySelector('body').appendChild(template[0])

// Listen for logout events from API
window.addEventListener('auth:logout', () => {
  showLogin()
})

export default {
  el: null,
  template: null,
  
  async afterBind() {
    // Check if user is already logged in
    await checkAuth()
    
    // Set up login button
    document.querySelector('#auth-email').addEventListener('click', (e) => {
      e.preventDefault()
      login()
    })
    
    // Set up register button
    document.querySelector('#auth-create-email').addEventListener('click', (e) => {
      e.preventDefault()
      register()
    })
  }
}

async function checkAuth() {
  try {
    // Try to get current user
    const response = await api.request('/auth/me')
    if (response.user) {
      showFileList(response.user)
    } else {
      showLogin()
    }
  } catch (error) {
    // Not logged in
    showLogin()
  }
}

function showLogin() {
  const auth = document.getElementById('auth')
  if (auth) {
    auth.className = 'modal open'
  }
  
  const fileList = document.querySelector(fileListComponent.el)
  if (fileList) {
    fileList.innerHTML = ''
  }
}

function showFileList(user) {
  const auth = document.getElementById('auth')
  if (auth) {
    auth.className = 'modal'
  }
  
  // Store user in localStorage
  localStorage.setItem('user', JSON.stringify(user))
  
  // Initialize file list
  const fileList = document.querySelector(fileListComponent.el)
  if (fileList) {
    fileList.innerHTML = fileListComponent.template
    fileListComponent.afterBind()
  }
}

async function login() {
  const email = document.querySelector('#email')?.value
  const password = document.querySelector('#password')?.value
  
  if (!email || !password) {
    alert('Please enter email and password')
    return
  }
  
  try {
    const response = await api.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })
    
    if (response.success) {
      showFileList(response.user)
    }
  } catch (error) {
    alert('Login failed: ' + error.message)
  }
}

async function register() {
  const email = document.querySelector('#email')?.value
  const password = document.querySelector('#password')?.value
  const confirmPassword = document.querySelector('#confirm-password')?.value
  
  if (!email || !password) {
    alert('Please enter email and password')
    return
  }
  
  if (password !== confirmPassword) {
    alert('Passwords do not match')
    return
  }
  
  try {
    const response = await api.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })
    
    if (response.success) {
      // Auto-login after registration
      await login()
    }
  } catch (error) {
    alert('Registration failed: ' + error.message)
  }
}

export async function logout() {
  try {
    await api.request('/auth/logout', { method: 'POST' })
  } catch (error) {
    // Ignore logout errors
  }
  showLogin()
}
