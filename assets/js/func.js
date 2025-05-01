// 打印日志
function log(info) {
    sendMessage('log', JSON.stringify({'info': info}));
}

// 点击
async function click(arg1, arg2, arg3) {
    if (typeof arg1 === 'number') {
        await sendMessage('click', JSON.stringify({'delay': arg1}));
    }
    else if (typeof arg1 === 'object' && typeof arg2 === 'number') {
        await sendMessage('click', JSON.stringify({'coords': arg1, 'delay': arg2}));
    }
    else if (typeof arg1 === 'string' && typeof arg2 === 'number') {
        await sendMessage('click', JSON.stringify({'type': arg1, 'delay': arg2}));
    }
    else if (typeof arg1 === 'string' && typeof arg2 === 'object' && typeof arg3 === 'number') {
        await sendMessage('click', JSON.stringify({'type': arg1, 'coords': arg2, 'delay': arg3}));
    }
}

// 弹出消息
function tip(message, duration) {
    sendMessage('tip', JSON.stringify({'message': message, 'duration': duration}));
}

// 等待时间
async function wait(delay) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve();
        }, delay);
    });
}

// 复制粘贴
function cp(text) {
    sendMessage('cp', JSON.stringify({'text': text}));
}

// 基础鼠标操作
async function move(coords, delay) {
    sendMessage('move', JSON.stringify({'coords': coords}));
}

// 按键
async function press(key, delay) {
    sendMessage('press', JSON.stringify({'key': key, 'delay': delay}));
}

// 图片
function pic(topLeft, bottomRight) {
    sendMessage('pic', JSON.stringify({'topLeft': topLeft, 'bottomRight': bottomRight}));
}
