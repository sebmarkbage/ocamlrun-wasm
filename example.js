var initialTitle = document.title;

var maxDep = 0;

var Module = {
  arguments: ['build/example'],
  preRun: [],
  postRun: [],
  print: function(text) {
    console.log(text);
  },
  printErr: function(text) {
    console.error(text);
  },
  setStatus: function(text) {
    document.title = initialTitle + (text ? ' - ' + text : '');
  },
  monitorRunDependencies: function(remaining) {
    maxDep = Math.max(maxDep, remaining);
    Module.setStatus(remaining ? '' + (maxDep - remaining) + '/' + maxDep + ')' : '');
  }
};
Module.setStatus('Downloading...');
window.onerror = function(event) {
  Module.setStatus('Exception thrown, see JavaScript console');
  Module.setStatus = function(text) {
    if (text) Module.printErr('[post-exception status] ' + text);
  };
};

var xhr = new XMLHttpRequest();
xhr.open('GET', 'ocamlrun.wasm', true);
xhr.responseType = 'arraybuffer';
xhr.onload = function() {
  Module.wasmBinary = xhr.response;
  var script = document.createElement('script');
  script.src = 'ocamlrun.js';
  document.body.appendChild(script);
};
xhr.send(null);
