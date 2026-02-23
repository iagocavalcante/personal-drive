import getData from './data-manipulate/getData'
import onClick from './events/onClick'

require('./template/css/style.scss')

export default {
  el: '#main',
  template: require('./template/index.html'),
  afterBind() {
    // Load root folder by default
    getData({
      id: null,
      title: 'Home'
    })
    
    onClick()
  }
}
