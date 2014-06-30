
var socket = io.connect(window.location.hostname);

socket.on('connect', function () {
    socket.emit('login', 'ac3b17629917e9230f9b0577f3036367');
    socket.emit('data_change', { hello: 'world1' });
    socket.on('data_change',function (data) {
      console.log(data);
    })
    socket.emit('status_change', { hello: 'world2' });
    socket.on('status_change',function (data) {
      console.log(data);
    })
  });

