import getPath from './../uploader/utils/path'
import { app } from './../../configuration/firebase'
import { UserClass } from './../auth/user/user'

export default function () {
  const dirName = prompt('Qual o nome do novo diretório', 'Minha pasta')
  if (dirName == null || dirName == '') {
    return
  }

  const path = getPath()

  const userInstance = new UserClass

  const folderRef = app.database().ref('files/' + userInstance.user.uid + path)
  folderRef.push({
    type: 'folder-open',
    title:  dirName
  })
}
