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

// 开图
async function map(delay) {
    await sendMessage('map', JSON.stringify({'delay': delay}));
}

// 开书
async function book(delay) {
    await sendMessage('book', JSON.stringify({'delay': delay}));
}

// 复制粘贴
function cp(text) {
    sendMessage('cp', JSON.stringify({'text': text}));
}

// 移动鼠标
async function move(coords, delay) {
    await sendMessage('move', JSON.stringify({'coords': coords, 'delay': delay}));
}

// 相对移动鼠标
async function moveR(coords, delay) {
    await sendMessage('moveR', JSON.stringify({'coords': coords, 'delay': delay}));
}

// 3D视角下移动鼠标
async function moveR3D(coords, delay) {
    await sendMessage('moveR3D', JSON.stringify({'coords': coords, 'delay': delay}));
}

// 鼠标按下
async function mDown(delay) {
    await sendMessage('mDown', JSON.stringify({'delay': delay}));
}

// 鼠标抬起
async function mUp(delay) {
    await sendMessage('mUp', JSON.stringify({'delay': delay}));
}

// 按键
async function press(key, delay) {
    await sendMessage('press', JSON.stringify({'key': key, 'delay': delay}));
}

// 滚轮
async function wheel(clicks, delay) {
    await sendMessage('wheel', JSON.stringify({'clicks': clicks, 'delay': delay}));
}

// 按下
async function kDown(key, delay) {
    await sendMessage('kDown', JSON.stringify({'key': key, 'delay': delay}));
}

// 按下
async function kUp(key, delay) {
    await sendMessage('kUp', JSON.stringify({'key': key, 'delay': delay}));
}

// 拖动
async function drag(coords, shortMove, delay) {
    await sendMessage('drag', JSON.stringify({'coords': coords, 'shortMove': shortMove, 'delay': delay}));
}

// 传送
async function tp(params, remember, delay) {
    await sendMessage('tp', JSON.stringify({'params': params, 'remember': remember, 'delay': delay}));
}

// 传送确认
async function tpc(coords, delay) {
    await sendMessage('tpc', JSON.stringify({'coords': coords, 'delay': delay}));
}

// 图片
async function pic(topLeft, bottomRight) {
    return await sendMessage('pic', JSON.stringify({'topLeft': topLeft, 'bottomRight': bottomRight}));
}
