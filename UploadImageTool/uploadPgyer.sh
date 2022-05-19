#!/bin/sh

##必须参数
#$1 ipa路径
#$2 _api_key
#$3 webhook地址
#$4 上传日志地址
#echo "$1"
#echo "$2"
#echo "$3"
#echo "$4"
#
### 方法简要说明：
### 1. 是先查找一个字符串：带双引号的key。如果没找到，则直接返回defaultValue。
### 2. 查找最近的冒号，找到后认为值的部分开始了，直到在层数上等于0时找到这3个字符：,}]。
### 3. 如果有多个同名key，则依次全部打印（不论层级，只按出现顺序）
### @author lux feary
###
### 3 params: json, key, defaultValue
function getJsonValuesByAwk() {
    awk -v json="$1" -v key="$2" -v defaultValue="$3" 'BEGIN{
        foundKeyCount = 0
        while (length(json) > 0) {
            # pos = index(json, "\""key"\""); ## 这行更快一些，但是如果有value是字符串，且刚好与要查找的key相同，会被误认为是key而导致值获取错误
            pos = match(json, "\""key"\"[ \\t]*?:[ \\t]*");
            if (pos == 0) {if (foundKeyCount == 0) {print defaultValue;} exit 0;}

            ++foundKeyCount;
            start = 0; stop = 0; layer = 0;
            for (i = pos + length(key) + 1; i <= length(json); ++i) {
                lastChar = substr(json, i - 1, 1)
                currChar = substr(json, i, 1)

                if (start <= 0) {
                    if (lastChar == ":") {
                        start = currChar == " " ? i + 1: i;
                        if (currChar == "{" || currChar == "[") {
                            layer = 1;
                        }
                    }
                } else {
                    if (currChar == "{" || currChar == "[") {
                        ++layer;
                    }
                    if (currChar == "}" || currChar == "]") {
                        --layer;
                    }
                    if ((currChar == "," || currChar == "}" || currChar == "]") && layer <= 0) {
                        stop = currChar == "," ? i : i + 1 + layer;
                        break;
                    }
                }
            }

            if (start <= 0 || stop <= 0 || start > length(json) || stop > length(json) || start >= stop) {
                if (foundKeyCount == 0) {print defaultValue;} exit 0;
            } else {
                print substr(json, start, stop - start);
            }

            json = substr(json, stop + 1, length(json) - stop)
        }
    }'
}

json=$(curl -F "file=@$1" -F "_api_key=$2" \
    https://www.pgyer.com/apiv2/app/upload --progress-bar | tee "$4/pgyer_upload.log")
buildVersion=$(getJsonValuesByAwk "$json" "buildVersion" "defaultValue" | sed 's/\"//g')
buildBuildVersion=$(getJsonValuesByAwk "$json" "buildBuildVersion" "defaultValue" | sed 's/\"//g')
buildQRCodeURL=$(getJsonValuesByAwk "$json" "buildQRCodeURL" "defaultValue" | sed 's/\"//g')
ShortcutUrl=$(getJsonValuesByAwk "$json" "buildShortcutUrl" "defaultValue" | sed 's/\"//g')
buildQRCodeURL="https://www.pgyer.com/app/qrcode/${ShortcutUrl}"
buildShortcutUrl="https://www.pgyer.com/${ShortcutUrl}"
echo "😊😊😊😊buildQRCodeURL= ${buildQRCodeURL}"
echo "😊😊😊😊buildShortcutUrl= ${buildShortcutUrl}"
echo "appDescription: <img src=\"${buildQRCodeURL}\">"

curl ''$3'' -H 'Content-Type: application/json' \
   -d '{
    "msgtype": "markdown",
    "markdown": {
        "content": "<font color=\"info\">蒲公英上传信息</font> \n
         >版本信息:<font color=\"comment\">【'$buildVersion'('$buildBuildVersion')】</font> \n
         
         [蒲公英页面地址]('$buildShortcutUrl') \n
         
         [蒲公英二维码]('$buildQRCodeURL') \n"
    }
}'

exit 0

