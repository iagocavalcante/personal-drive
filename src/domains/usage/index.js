import api from './../../lib/api'

export default async function () {
  try {
    const usage = await api.getUsage()
    
    const percentUsed = usage.percent_used || 0
    const percentFree = 100 - percentUsed
    
    document.querySelector('.progress .usage').innerHTML = `${percentUsed}% used`
    document.querySelector('.progress .free').innerHTML = `${percentFree}% free`
    
    document.querySelector('.progress').setAttribute(
      'style', 
      `grid-template-columns: ${percentUsed}% ${percentFree}%`
    )
  } catch (error) {
    console.error('Failed to load usage:', error)
  }
}
