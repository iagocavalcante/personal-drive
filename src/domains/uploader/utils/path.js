import { foldersPath } from './../../files-list/data-manipulate/getData'

export default function () {
  let path = '/'

  foldersPath.forEach((item, key) => {
    if (key > 0) {
      path += item.id + '/'
    }
  })

  return path
}