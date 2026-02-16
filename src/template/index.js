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
        ${header}
        <div class="main-wrapper">
            ${sidebar}
            <div class="content-wrapper">
                ${content}
                ${footer}
            </div>
        </div>
    </div>`,
    afterBind: () => {
      const menuBtn = document.getElementById('menuBtn');
      const sidebar = document.getElementById('sidebar');
      
      if (menuBtn) {
        menuBtn.addEventListener('click', (e) => {
          e.preventDefault();
          sidebar.classList.toggle('collapsed');
        });
      }

      const addSharerForm = document.getElementById('addSharer');
      if (addSharerForm) {
        addSharerForm.addEventListener('submit', function (e) {
          e.preventDefault();
          const input = document.getElementById('addSharerInput');
          if (input && input.value) {
            sharer(input.value);
            input.value = '';
          }
        });
      }
    }
}
