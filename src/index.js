import { Elm } from './Main.elm';
import 'bootstrap-css-only/css/bootstrap.min.css';
import '@fortawesome/fontawesome-free/css/svg-with-js.min.css';
import { set, get } from 'idb-keyval';

get('tasks')
  .then(tasks => {
    const app = Elm.Main.init({
      node: document.getElementById('root'),
      flags: tasks
    });

    app.ports.saveTasks.subscribe(tasks => {
      set('tasks', tasks);
    });
  })
  .catch(() => {
    // IndexedDB cannot be accessed, run without persistent storage
    Elm.Main.init({
      node: document.getElementById('root'),
    });
  });
