
var socket = io.connect(window.location.hostname);

socket.on('connect', function () {
    socket.on(window.location.hostname + ':biochemistry_status_change',function (data) {
      console.log(data);
    })

    socket.on(window.location.hostname + ':record_status_change',function (data) {
      console.log(data);
    })
  });
