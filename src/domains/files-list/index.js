import getData from './data-manipulate/getData'
import onClick from './events/onClick'
import { UserClass } from './../auth/user/user'

require('./template/css/style.scss')

export default {
  el: '#main',
  template: require('./template/index.html'),
  afterBind() {
    let queryString = window.location.search.slice(1).split('&')
    queryString.forEach((item, key) => {
      item = item.split('=')
      queryString[item[0]] = item[1]
    })

    console.log(queryString)

    let uid = ''
    let title = ''

    if (queryString['drive']) {
      uid = queryString['drive']
      title = queryString['email']
    } else {
      let userInstance = new UserClass
      uid = userInstance.user.uid
      title = 'home'
    }

    getData({
      id: '/files/' + uid,
      title: title
    })
    onClick()
  }
}