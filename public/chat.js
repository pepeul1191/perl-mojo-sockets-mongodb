// Clase FileUploader en MooTools
var FileUploader = new Class({
  
  Implements: [Events, Options],
  
  options: {
    url: '/file/upload',
    progressElement: null,
    resultElement: null
  },
  
  initialize: function(form, options) {
    this.setOptions(options);
    this.form = document.id(form);
    this.fileInput = this.form.getElement('input[type=file]');
    this.progress = document.id(this.options.progressElement) || this.form.getElement('#progress');
    this.result = document.id(this.options.resultElement) || this.form.getElement('#result');
    
    this.attachEvents();
  },
  
  attachEvents: function() {
    this.form.addEvent('submit', this.handleSubmit.bind(this));
  },
  
  handleSubmit: function(e) {
    e.preventDefault();
    
    var file = this.fileInput.files[0];
    
    if (!file) {
      this.showMessage('Por favor seleccione un archivo', 'error');
      return;
    }
    
    this.uploadFile(file);
  },
  
  uploadFile: function(file) {
    this.showProgress(true);
    this.clearMessage();
    
    var formData = new FormData();
    formData.append('file', file);
    
    var request = new Request({
      url: this.options.url,
      method: 'post',
      data: formData,
      emulation: false,
      urlEncoded: false,
      
      onSuccess: this.onUploadSuccess.bind(this),
      onFailure: this.onUploadFailure.bind(this)
    }).send();
  },
  
  onUploadSuccess: function(response) {
    this.showProgress(false);
    try {
      var result = JSON.decode(response);
      this.showMessage('Éxito: ' + result.message, 'success');
    } catch(e) {
      this.showMessage('Archivo subido correctamente', 'success');
    }
  },
  
  onUploadFailure: function(xhr) {
    this.showProgress(false);
    this.showMessage('Error (' + xhr.status + '): ' + xhr.responseText, 'error');
  },
  
  showProgress: function(show) {
    if (this.progress) {
      this.progress.setStyle('display', show ? 'block' : 'none');
    }
  },
  
  showMessage: function(message, type) {
    if (this.result) {
      this.result.set('html', message);
      this.result.className = type || '';
    }
  },
  
  clearMessage: function() {
    if (this.result) {
      this.result.set('html', '');
      this.result.className = '';
    }
  }
});


let ws = null;

// Inicializar cuando el DOM esté listo
window.addEvent('domready', function() {
  connectWebSocket();
  loadUsers();

  // Ping periódico para mantener conexión viva
  setInterval(() => {
    console.log(ws);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({type: 'ping'}));
    }
  }, 30000); // Cada 30 segundos
});

const loadUsers = () => {
  var xhr = new XMLHttpRequest();
  xhr.open('GET', '/users.json', true);
  
  // Setear las cabeceras personalizadas
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('Accept', 'application/json');
  xhr.setRequestHeader('X-Auth-Trigger', '<%= $config->{xauthtrigger} %>');
  
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        console.log('Respuesta completa:', response);
        showUsers(response);
      } else {
        alert('Error al actualizar el usuario');
      }
    }
  };
  
  xhr.send();
};

const userClick = (event, user) => {
  console.log(event)
  console.log(user)
  document.getElementById("recipientName").innerHTML = user.name;
}

const showUsers = (response) => {
  var ul = document.getElementById('userList');
  if (!ul) return;
  
  // Limpiar lista existente (opcional)
  // ul.innerHTML = '';
  
  // ✅ Crear lista con la respuesta
  if (Array.isArray(response)) {
    // Si response es un array
    response.forEach(function(user, index) {
      var li = document.createElement('li');
      
      li.addEventListener('click', (event) => {
        userClick(event, user);
      });

      li.classList.add('user');

      if (typeof user === 'object') {
        li.innerHTML = `
          <img src="${user.image_url}" height=20 width=20 />
          <strong>${user.name}</strong>
        `;
      } else {
        li.textContent = user;
      }
      ul.appendChild(li);
    });
    
  } else if (typeof response === 'object') {
    // Si response es un objeto
    Object.keys(response).forEach(function(key) {
      var li = document.createElement('li');
      var value = response[key];
      
      if (typeof value === 'object' && value !== null) {
        li.innerHTML = `
          <strong>${key}:</strong>
          <ul>
            ${Object.keys(value).map(subKey => 
              `<li><strong>${subKey}:</strong> ${value[subKey]}</li>`
            ).join('')}
          </ul>
        `;
      } else {
        li.innerHTML = `<strong>${key}:</strong> ${value}`;
      }
      
      ul.appendChild(li);
    });
    
  } else {
    // Si response es un valor simple
    var li = document.createElement('li');
    li.textContent = response;
    ul.appendChild(li);
  }
}

const connectWebSocket = () => {
  if (ws && ws.readyState === WebSocket.OPEN) {
    addMessage('Ya estás conectado!', 'system');
    return;
  }
  
  //jwt token
  const userInfo = JSON.parse(localStorage.getItem('user_info'));

  // Conectar al endpoint WebSocket
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  const wsUrl = protocol + '//' + window.location.host + '/ws/chat?token=' + userInfo.token;
  
  ws = new WebSocket(wsUrl);
  
  ws.onopen = function(event) {
    console.log('Conectado al WebSocket');
  };
  
  ws.onmessage = function(event) {
    console.log('Mensaje recibido:', event.data);
    const data = JSON.parse(event.data);
    
    if (data.type == 'error'){
      document.getElementById('flash').innerHTML = data.message;
    }
  };
  
  ws.onclose = function(event) {
    console.log(event);
    console.log('Desconectado del WebSocket');
  };
  
  ws.onerror = function(error) {
    console.error('Error WebSocket:', error);
  };
}