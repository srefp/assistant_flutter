function log(info) {
    sendMessage('log', JSON.stringify({'info': info}));
}

function click() {
    sendMessage('click', JSON.stringify({'info': info}));
}

function pic(topLeft, bottomRight) {
    sendMessage('pic', JSON.stringify({'topLeft': topLeft, 'bottomRight': bottomRight}));
}
