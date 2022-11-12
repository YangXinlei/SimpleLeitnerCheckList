/*
 * @Author: yangxinlei
 * @Description:
 * @Date: 2022-11-12 20:09:03
 */
const fs = require('fs');
const { findSourceMap, builtinModules } = require('module');
const path = require('path');
const { add } = require('wechat/lib/list');


const rootDir = './db'
function appendContent(user, date, content) {
    if (!content || content.length == 0) { return; }

    const dateFile = getDateFile(user, date)
    let fullContent = {}
    let words = []
    if (fs.existsSync(dateFile)) {
        const data = fs.readFileSync(dateFile)
        if (data) {
            fullContent = JSON.parse(data)
            words = fullContent.words
        }
    }
    if (!words.includes(content)) {
        words.push(content)
    }
    fullContent.words = words
    let dataStr = JSON.stringify(fullContent)
    let appendRlt = fs.writeFileSync(dateFile, dataStr);

    console.log(`append ${dataStr} to file ${dateFile} with rlt: ${appendRlt}`)
}

function getDateFile(user, date) {
    const userDir = path.join(rootDir, user)
    if (!fs.existsSync(userDir)) {
        let mkRlt = fs.mkdirSync(userDir, { recursive: true })
        console.log(mkRlt)
    }

    return path.join(userDir, fileNameFromDate(date))
}

function getContent(user, date) {
    let dateFile  = getDateFile(user, date)
    if (fs.existsSync(dateFile)) {
        const data = fs.readFileSync(dateFile)
        return JSON.parse(data)
    }
    return []
}

function reco(user, date) {
    let recoDays = getRecoDays(date)
    let result = ''
    recoDays.forEach((date) => {
        let content = getContent(user, date)
        let words = content.words
        if (words) {
            result += `${fileNameFromDate(date)}\n`
            result += words.join('\n')
            result += '\n'
        }
    })
    return result
}

function getRecoDays(date) {
    let recoDurationDays = [0, 1, 3, 6, 13, 28, 59, 122]
    let result = []
    recoDurationDays.forEach((day) => {
        result.push(addDays(date, -day))
    })
    console.log(`reco days: ${result}`)
    return result;
}

function addDays(originalDate, days){
    cloneDate = new Date(originalDate.valueOf());
    cloneDate.setDate(cloneDate.getDate() + days);
    return cloneDate;
  }

function fileNameFromDate(date) {
    const [month, day, year] = [date.getMonth(), date.getDate(), date.getFullYear()];
    return `${year}_${month+1}_${day < 10 ? '0': ''}${day}`
}


appendContent('5gh_abcdx3', new Date(), 'hello')
appendContent('5gh_abcdx3', new Date(), 'nonsense')

console.log(reco('5gh_abcdx3', new Date()))

var db = {}
db.appendContent = appendContent
db.reco = reco


module.exports = db
