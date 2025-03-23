function log(info) {
    sendMessage('log', JSON.stringify({'info': info}));
}

function click() {
    sendMessage('click', JSON.stringify({'info': info}));
}