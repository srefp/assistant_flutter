// 打印日志
function log(info) {
    sendMessage('log', JSON.stringify({'info': info}));
}

function toast(info) {
    sendMessage('toast', JSON.stringify({'info': info}));
}

// 点击
function click(arg1, arg2, arg3) {
    if (typeof arg1 === 'number') {
        sendMessage('click', JSON.stringify({'delay': arg1}));
    }
    else if (typeof arg1 === 'object' && typeof arg2 === 'number') {
        sendMessage('click', JSON.stringify({'coords': arg1, 'delay': arg2}));
    }
    else if (typeof arg1 === 'string' && typeof arg2 === 'number') {
        sendMessage('click', JSON.stringify({'type': arg1, 'delay': arg2}));
    }
    else if (typeof arg1 === 'string' && typeof arg2 === 'object' && typeof arg3 === 'number') {
        sendMessage('click', JSON.stringify({'type': arg1, 'coords': arg2, 'delay': arg3}));
    }
}

// 图片
function pic(topLeft, bottomRight) {
    sendMessage('pic', JSON.stringify({'topLeft': topLeft, 'bottomRight': bottomRight}));
}
