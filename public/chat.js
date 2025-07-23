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

// Inicializar cuando el DOM esté listo
window.addEvent('domready', function() {
  var uploader = new FileUploader('uploadForm', {
    url: '/file/upload',
    progressElement: 'progress',
    resultElement: 'result'
  });
});