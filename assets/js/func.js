var scriptRunning = true;
var leftButtonPressed = false;
var rightButtonPressed = false;
var middleButtonPressed = false;
var pressedKeys = new Set();

// 终止脚本
async function stopScript() {
    scriptRunning = false;
    if (leftButtonPressed) {
      leftButtonPressed = false;
      await sendMessage('mUp', JSON.stringify({'delay': 0}));
    }
    for (const key of pressedKeys) {
      await sendMessage('kUp', JSON.stringify({'key': key, 'delay': 0}));
    }
}

// 打印日志
function log(info) {
    sendMessage('log', JSON.stringify({'info': info}));
}

// 点击
async function click() {
    await sendMessage('click', JSON.stringify([...arguments]));
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
async function cp(text) {
    await sendMessage('cp', JSON.stringify({'text': text}));
}

// 移动鼠标
async function move() {
    await sendMessage('move', JSON.stringify([...arguments]));
}

// 相对移动鼠标
async function moveR() {
    await sendMessage('moveR', JSON.stringify([...arguments]));
}

// 3D视角下移动鼠标
async function moveR3D() {
    await sendMessage('moveR3D', JSON.stringify([...arguments]));
}

// 鼠标按下
async function mDown() {
    if (arguments[0] === 'left') {
        leftButtonPressed = true;
    } else if (arguments[0] === 'right') {
        rightButtonPressed = true;
    } else if (arguments[0] ==='middle') {
        middleButtonPressed = true;
    }
    await sendMessage('mDown', JSON.stringify([...arguments]));
}

// 鼠标抬起
async function mUp() {
    if (arguments[0] === 'left') {
        leftButtonPressed = false;
    } else if (arguments[0] === 'right') {
        rightButtonPressed = false;
    } else if (arguments[0] === 'middle') {
        middleButtonPressed = false;
    }
    await sendMessage('mUp', JSON.stringify([...arguments]));
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
    pressedKeys.add(key);
    await sendMessage('kDown', JSON.stringify({'key': key, 'delay': delay}));
}

// 按下
async function kUp(key, delay) {
    pressedKeys.delete(key);
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

// 找色
async function findColor() {
    return await sendMessage('findColor', JSON.stringify([...arguments]));
}

// 找图
async function findPic() {
    return await sendMessage('findPic', JSON.stringify([...arguments]));
}
