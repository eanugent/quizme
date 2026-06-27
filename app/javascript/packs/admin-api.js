import axios from 'axios'

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const adminApi = axios.create({
  headers: { 'X-Requested-With': 'XMLHttpRequest' }
})

adminApi.interceptors.request.use((config) => {
  const token = csrfToken()
  if (token) {
    config.headers['X-CSRF-Token'] = token
  }
  return config
})

export default adminApi
