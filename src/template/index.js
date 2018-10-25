import sharer from './../domains/share/sharer';
import './../domains/share/sharedList';

require('./../assets/css/style.scss');
require('./../domains/usage');
require('font-awesome/css/font-awesome.css')

const header = require('./header/header.html');
const content = require('./content/content.html');
const footer = require('./footer/footer.html');
const sidebar = require('./sidebar/sidebar.html');

export default {
    el: '#app',
    template: `
    <div id="wrapper">
        ${header}${content}${footer}
    </div>
    ${sidebar}`,
    afterBind: () => {
      const openMenu = document.querySelector('#header .menu-icon');
      const closeMenu = document.getElementById('wrapper');

      const closeMenuEvent = function(e) {
          e.preventDefault();
          const body = document.querySelector('body');
          body.className = body.className.replace('show-menu', '');

          closeMenu.removeEventListener('click', closeMenuEvent, true);
      };

      const openMenuEvent = function (e) {
          e.preventDefault();
          const body = document.querySelector('body');
          body.className += " show-menu";
          body.className = body.className.trim();

          closeMenu.addEventListener('click', closeMenuEvent, true);
      };

      openMenu.addEventListener('click', openMenuEvent);

      document.getElementById('addSharer').addEventListener('submit', function (e) {
        e.preventDefault();
        sharer(document.getElementById('addSharerInput').value)
      })
    }
}