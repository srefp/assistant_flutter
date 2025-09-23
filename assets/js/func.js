var scriptRunning = true;
var leftButtonPressed = false;
var rightButtonPressed = false;
var middleButtonPressed = false;
var pressedKeys = new Set();
var m, l, f;

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

// 点击
async function click() {
    await sendMessage('click', JSON.stringify([...arguments]));
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

// 滚轮
async function wheel(clicks, delay) {
    await sendMessage('wheel', JSON.stringify({'clicks': clicks, 'delay': delay}));
}

// 拖动
async function drag(coords, shortMove, delay) {
    await sendMessage('drag', JSON.stringify({'coords': coords, 'shortMove': shortMove, 'delay': delay}));
}

// 获取鼠标当前位置
async function findMousePos() {
    return await sendMessage('findMousePos', '[]');
}

// 点击
async function clickAsync() {
    await sendMessage('clickAsync', JSON.stringify([...arguments]));
}

// 移动鼠标
async function moveAsync() {
    await sendMessage('moveAsync', JSON.stringify([...arguments]));
}

// 相对移动鼠标
async function moveRAsync() {
    await sendMessage('moveRAsync', JSON.stringify([...arguments]));
}

// 3D视角下移动鼠标
async function moveR3DAsync() {
    await sendMessage('moveR3DAsync', JSON.stringify([...arguments]));
}

// 鼠标按下
async function mDownAsync() {
    if (arguments[0] === 'left') {
        leftButtonPressed = true;
    } else if (arguments[0] === 'right') {
        rightButtonPressed = true;
    } else if (arguments[0] ==='middle') {
        middleButtonPressed = true;
    }
    await sendMessage('mDownAsync', JSON.stringify([...arguments]));
}

// 鼠标抬起
async function mUpAsync() {
    if (arguments[0] === 'left') {
        leftButtonPressed = false;
    } else if (arguments[0] === 'right') {
        rightButtonPressed = false;
    } else if (arguments[0] === 'middle') {
        middleButtonPressed = false;
    }
    await sendMessage('mUpAsync', JSON.stringify([...arguments]));
}

// 滚轮
async function wheelAsync(clicks, delay) {
    await sendMessage('wheelAsync', JSON.stringify({'clicks': clicks, 'delay': delay}));
}

// 拖动
async function dragAsync(coords, shortMove, delay) {
    await sendMessage('dragAsync', JSON.stringify({'coords': coords, 'shortMove': shortMove, 'delay': delay}));
}

// 按键
async function press(key, delay) {
    await sendMessage('press', JSON.stringify({'key': key, 'delay': delay}));
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

// 传送
async function tp(params, remember, delay) {
    await sendMessage('tp', JSON.stringify({'params': params, 'remember': remember, 'delay': delay}));
}

// 传送确认
async function tpc(coords, delay) {
    await sendMessage('tpc', JSON.stringify([...arguments]));
}

// 包传送的传送确认
async function tpcPlus(coords, delay) {
    await sendMessage('tpcPlus', JSON.stringify([...arguments]));
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

// 找图（左上角位置）
async function findPicLT() {
    return await sendMessage('findPicLT', JSON.stringify([...arguments]));
}

// 找图（右上角位置）
async function findPicRT() {
    return await sendMessage('findPicRT', JSON.stringify([...arguments]));
}

// 找图（右下角位置）
async function findPicRB() {
    return await sendMessage('findPicRB', JSON.stringify([...arguments]));
}

// 找图（左下角位置）
async function findPicLB() {
    return await sendMessage('findPicLB', JSON.stringify([...arguments]));
}

// 跳过下一个点位
function skipNext() {
    return sendMessage('skipNext', JSON.stringify([]));
}

// 根据名称去往指定点位
function toByName(name) {
    return sendMessage('toByName', JSON.stringify([name]));
}

// 执行shell脚本
async function sh() {
    return await sendMessage('sh', JSON.stringify([...arguments]));
}

// 最大化当前窗口
async function maxCurrentWindow() {
    return await sendMessage('maxCurrentWindow', JSON.stringify([]));
}

// 数据库
function plusMills() {
    return sendMessage('plusMills', JSON.stringify([...arguments]));
}

function plusSeconds() {
    return sendMessage('plusSeconds', JSON.stringify([...arguments]));
}

function plusMinutes() {
    return sendMessage('plusMinutes', JSON.stringify([...arguments]));
}

function plusHours() {
    return sendMessage('plusHours', JSON.stringify([...arguments]));
}

function plusDays() {
    return sendMessage('plusDays', JSON.stringify([...arguments]));
}

function plusWeeks() {
    return sendMessage('plusWeeks', JSON.stringify([...arguments]));
}

function plusMonths() {
    return sendMessage('plusMonths', JSON.stringify([...arguments]));
}

function plusYears() {
    return sendMessage('plusYears', JSON.stringify([...arguments]));
}

function getInfo() {
    return sendMessage('getInfo', JSON.stringify([...arguments]));
}

function gen() {
    return sendMessage('gen', JSON.stringify([...arguments]));
}

// 随机数
function randInt() {
    return sendMessage('randInt', JSON.stringify([...arguments]));
}

function randDouble() {
    return sendMessage('randDouble', JSON.stringify([...arguments]));
}

function executeSql() {
    return sendMessage('executeSql', JSON.stringify([...arguments]));
}

function getSqlStr() {
    return sendMessage('getSqlStr', JSON.stringify([...arguments]));
}

function now() {
    return sendMessage('now', JSON.stringify([...arguments]));
}
