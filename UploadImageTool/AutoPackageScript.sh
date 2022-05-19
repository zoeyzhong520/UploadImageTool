#!/bin/sh

# 使用方法:
# step1 : 将该脚本AutoPackageScript.sh拖入到项目主目录（和 .xcworkspace文件 或者 .xcodeproj文件 同目录）
# step2 : 打开AutoPackageScript.sh文件,修改 "项目自定义部分" 配置好项目参数
# step3 : 打开终端, cd 到 AutoPackageScript.sh (ps:在终端中先输入cd ,直接拖入AutoPackageScript.sh,回车)
# step4 : 输入 sh AutoPackageScript.sh 命令,回车,开始执行此打包脚本
# step5 : 根据提示,选择编译发布平台

# ============= 发布渠道选择 (输入数字选择) =================== #
echo "------------ 请指定打包编译后发布渠道方式(输入数字) ------------"
echo "              1  Tiens  【测试人员蒲公英】送测"
echo "              2  Tiens  【开发人员蒲公英】内测"
echo "              6  Tiens  【 AppStrore】 提审"
echo "---------------------------------------------------------"

# jenkins环境变量
if [ -n "$PUBLISH_CHANNEL_ID" ];
then
echo "PUBLISH_CHANNEL_ID==$PUBLISH_CHANNEL_ID"
build="$PUBLISH_CHANNEL_ID"
else
# 读取输入
read parameter
sleep 0.1
build="$parameter"
fi
echo "build==$build"

#login.keychain
LOGIN_KEYCHAIN=~/Library/Keychains/login.keychain-db
# 用户密码
LOGIN_PASSWORD=0805

# 先更新pod库
#echo "更新pod库😊😊..."
#if [ "$1" = "0" ]; then
#    echo "不更新Pod库......"
#else
#    tempDate=`date +%s`
#
#    temp_log_path="$(pwd)/TempPath"
#    ./tiensinstall.sh package $tempDate
#
#    # 判断是否安装成功
#    if cat $temp_log_path/$tempDate.log | grep "Pod installation complete!" > /dev/null
#    then
#        echo "pod install成功 🌹🌹🌹"
#        rm -rf $temp_log_path
#    else
#        echo "pod install失败 ⚠️⚠️⚠️"
#        rm -rf $temp_log_path
#        exit 1
#    fi
#fi
#
#echo "更新pod库完成😊😊..."


# =============项目自定义部分(自定义好下列参数后再执行该脚本)=================== #

# 是否编译工作空间 (例:若是用Cocopods管理的.xcworkspace项目,赋值true;用Xcode默认创建的.xcodeproj,赋值false)
is_workspace="false"

# .xcworkspace的名字，如果is_workspace为true，则必须填。否则可不填
workspace_name="Tiens"

# .xcodeproj的名字，如果is_workspace为false，则必须填。否则可不填
project_name="UploadImageTool"

# 指定项目的scheme名称（也就是工程的target名称），必填
scheme_name="UploadImageTool"

# 项目的bundleID，手动管理Profile时必填
bundle_identifier="com.zoneTech.voiceCopy"

# 指定要打包编译的方式 : Release,Debug。一般用Release。必填
# build_configuration="Release"

# method，打包的方式。方式分别为 development, ad-hoc, app-store, enterprise 。必填
# method="ad-hoc"

# (跟method对应的)mobileprovision文件名，需要先双击安装.mobileprovision文件.手动管理Profile时必填
# mobileprovision_name=""

# 判断输入
if [ -n "$build" ]
then
    if [ "$build" = "1" ];
    then
        # 蒲公英 api_key [必填]
        pgyer_api_key="bf926df5597dc5edc14d68f42c271e4b"
        # 蒲公英 app_key [必填]
        pgyer_app_key="f6552dc3e1082522efb035ea75ae1e3a"
        
        build_configuration="DEV"
        method="development"
        mobileprovision_name="ZoneTech_Development"
    elif [ "$build" = "2" ];
    then
        # 蒲公英 api_key [必填]
        pgyer_api_key="bf926df5597dc5edc14d68f42c271e4b"
        # 蒲公英 app_key [必填]
        pgyer_app_key="f6552dc3e1082522efb035ea75ae1e3a"
        
        build_configuration="UAT"
        method="development"
        mobileprovision_name="ZoneTech_AdHoc"
    elif [ "$build" = "6" ];#####生产环境请勿修改
    then
        #上传商店APIKEY  "3AL6B9W72Y"
        APIKEY=""
        #上传商店APIISUSER  "0bb255b1-3487-4188-830e-7f015e23a732"
        APIISUSER=""
        
        #开发者账号
        APPID="zhongzhaojun@saicmotor.com"
        #开发者账号密码
        APPPASSWORD="Zone,123"
    
        build_configuration="Release"
        method="app-store"
        mobileprovision_name="ZoneTech_AppStore"
    else
    echo "参数无效......"
    exit 1
    fi
fi

#jenkis配置了打包参数
if [ -n "$BUILD_CONFIG" -a "$build" != "6" ]; then

        build_configuration="$BUILD_CONFIG"
        
        if [ "$BUILD_CONFIG" = "DEV" ]; then
            method="development"
            mobileprovision_name="ZoneTech_Development"
        else
            method="ad-hoc"
            mobileprovision_name="ZoneTech_AdHoc"
        fi
        echo "jenkis--⚠️BUILD_CONFIG=$build_configuration---method=$method---mobileprovision_name=$mobileprovision_name-"
fi


echo "--------------------脚本配置参数检查--------------------"
echo "\033[33;1mis_workspace=${is_workspace} "
echo "workspace_name=${workspace_name}"
echo "project_name=${project_name}"
echo "scheme_name=${scheme_name}"
echo "build_configuration=${build_configuration}"
echo "bundle_identifier=${bundle_identifier}"
echo "method=${method}"
echo "mobileprovision_name=${mobileprovision_name} \033[0m"


# =======================脚本的一些固定参数定义(无特殊情况不用修改)====================== #

# 获取当前脚本所在目录
script_dir="$( cd "$( dirname "$0"  )" && pwd  )"
# 工程根目录
project_dir=$script_dir

# 时间
DATE=`date '+%Y%m%d_%H%M%S'`
# 指定输出导出文件夹路径
export_path="$HOME/Desktop/Package/$scheme_name-$DATE"
# 指定输出归档文件路径
export_archive_path="$export_path/$scheme_name.xcarchive"
# 指定输出ipa文件夹路径
export_ipa_path="$export_path"
# 指定输出ipa名称
ipa_name="${scheme_name}_${DATE}"
# 指定导出ipa包需要用到的plist配置文件的路径
export_options_plist_path="$export_path/exploreConfig.plist"


echo "--------------------脚本固定参数检查--------------------"
echo "\033[33;1mproject_dir=${project_dir}"
echo "DATE=${DATE}"
echo "export_path=${export_path}"
echo "export_archive_path=${export_archive_path}"
echo "export_ipa_path=${export_ipa_path}"
echo "export_options_plist_path=${export_options_plist_path}"
echo "ipa_name=${ipa_name} \033[0m"

# =======================自动打包部分(无特殊情况不用修改)====================== #

echo "------------------------------------------------------"
echo "\033[32m开始构建项目  \033[0m"
# 进入项目工程目录
cd ${project_dir}

# 指定输出文件目录不存在则创建
if [ -d "$export_path" ] ; then
    echo $export_path
else
    mkdir -pv $export_path
fi

#unlock keychain
security unlock-keychain -p ${LOGIN_PASSWORD} ${LOGIN_KEYCHAIN}

# 判断编译的项目类型是workspace还是project
if $is_workspace ; then
# 编译前清理工程
xcodebuild clean -workspace ${workspace_name}.xcworkspace \
                 -scheme ${scheme_name} \
                 -configuration ${build_configuration}
                 
xcodebuild archive -workspace ${workspace_name}.xcworkspace \
                   -scheme ${scheme_name} \
                   -configuration ${build_configuration} \
                   -archivePath ${export_archive_path} \
                   -destination 'generic/platform=iOS'
else
# 编译前清理工程
xcodebuild clean -project ${project_name}.xcodeproj \
                 -scheme ${scheme_name} \
                 -configuration ${build_configuration}
                 
xcodebuild archive -project ${project_name}.xcodeproj \
                   -scheme ${scheme_name} \
                   -configuration ${build_configuration} \
                   -archivePath ${export_archive_path} \
                   -destination 'generic/platform=iOS'

fi

#  检查是否构建成功
#  xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$export_archive_path" ] ; then
    echo "\033[32;1m项目构建成功 🚀 🚀 🚀  \033[0m"
else
    echo "\033[31;1m项目构建失败 😢 😢 😢  \033[0m"
    exit 1
fi
echo "------------------------------------------------------"

echo "\033[32m开始导出ipa文件 \033[0m"

# =======================项目中蒲公英的配置====================== #
TEMP_APP_PATH=$(find "$export_archive_path/Products/Applications"  -name "*.app")
TEMP_APP_PATH="${TEMP_APP_PATH#./}"
TEMP_APP_PATH="${TEMP_APP_PATH%.app}"
TEMP_APP_ArchiveConfig="$TEMP_APP_PATH.app"

if [  "$method" = "ad-hoc" -o "$method" = "development" ]; then
echo "修改项目中蒲公英的配置"
#打包蒲公英设置
pgyerConfig="$project_dir/ConfigPgyer.plist"
export_pgyerConfig="$export_path/ConfigPgyer.plist"

if [ -f "$pgyerConfig" ] ; then
echo "更新ConfigPgyer.plist"
cp -rf "$pgyerConfig" "$export_path"
/usr/libexec/PlistBuddy -c "Set :dev:pgyer_api_key ${pgyer_api_key}" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Set :dev:pgyer_app_key $pgyer_app_key" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Set :dev2:pgyer_api_key ${pgyer_api_key}" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Set :dev2:pgyer_app_key $pgyer_app_key" $export_pgyerConfig
cp -rf "$export_pgyerConfig" "$TEMP_APP_ArchiveConfig"
else
echo "根据参数生成ConfigPgyer.plist"
/usr/libexec/PlistBuddy -c "Add :dev:pgyer_api_key String ${pgyer_api_key}" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Add :dev:pgyer_app_key String $pgyer_app_key" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Add :dev2:pgyer_api_key String ${pgyer_api_key}" $export_pgyerConfig
/usr/libexec/PlistBuddy -c "Add :dev2:pgyer_app_key String $pgyer_app_key" $export_pgyerConfig
cp -rf "$export_pgyerConfig" "$TEMP_APP_ArchiveConfig"
fi

echo "修改项目中蒲公英的配置完成"

else
    echo "其它不需要蒲公英"
fi
# =======================项目中蒲公英的配置====================== #

# =======================修改Build版本号[]====================== #
#这个修改plist简单
#sed -i "" -e '/CFBundleVersion/{n;s/[0-9.]*[0-9.]/'"${DATE}"'/; }' ./${project_name}/Info.plist
#CURRENT_PROJECT_VERSION
#sed -i "" "s/CURRENT_PROJECT_VERSION =.*/CURRENT_PROJECT_VERSION = ${DATE};/g" "./${project_name}.xcodeproj/project.pbxproj"

# =======================修改Build版本号====================== #

# =======================修改Build版本号===================== #
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${DATE}"   "$TEMP_APP_ArchiveConfig/Info.plist"
# =======================修改Build版本号====================== #
echo "\033[32m开始导出ipa文件 \033[0m"


# 先删除export_options_plist文件
if [ -f "$export_options_plist_path" ] ; then
    /usr/libexec/PlistBuddy -c  "Set :method ${method}"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Set :provisioningProfiles:${bundle_identifier} ${mobileprovision_name}"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Set :compileBitcode false"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Set :stripSwiftSymbols false"  $export_options_plist_path

else
# 根据参数生成export_options_plist文件
    /usr/libexec/PlistBuddy -c  "Add :compileBitcode Bool false"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Add :stripSwiftSymbols Bool false"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Add :destination String 'export'"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Add :method String ${method}"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${bundle_identifier} String ${mobileprovision_name}"  $export_options_plist_path
fi
    
if [ "$build" = "6" ]; then
    echo "😊😊AppStroe"
    /usr/libexec/PlistBuddy -c  "Set :compileBitcode true"  $export_options_plist_path
    /usr/libexec/PlistBuddy -c  "Set :stripSwiftSymbols true"  $export_options_plist_path
    echo "开始打包......"
else
    echo "开始打包......"
fi

xcodebuild  -exportArchive \
            -archivePath ${export_archive_path} \
            -exportPath ${export_ipa_path} \
            -exportOptionsPlist ${export_options_plist_path} \
            -allowProvisioningUpdates

#兼容xcode12
temp_ipa_path="$export_ipa_path/*.ipa"
# 检查ipa文件是否存在
if [ -f $temp_ipa_path ] ; then
    echo "\033[32;1mexportArchive ipa包成功,准备进行重命名\033[0m"
else
    echo "\033[31;1mexportArchive ipa包失败 😢 😢 😢     \033[0m"
    exit 1
fi

# 修改ipa文件名称
mv $temp_ipa_path $export_ipa_path/$ipa_name.ipa

# 检查文件是否存在
if [ -f "$export_ipa_path/$ipa_name.ipa" ] ; then
    echo "\033[32;1m导出 ${ipa_name}.ipa 包成功 🎉  🎉  🎉   \033[0m"
    #open $export_path
else
    echo "\033[31;1m导出 ${ipa_name}.ipa 包失败 😢 😢 😢     \033[0m"
    exit 1
fi

# 删除export_options_plist文件（中间文件）
#if [ -f "$export_options_plist_path" ] ; then
#    #echo "${export_options_plist_path}文件存在，准备删除"
#    rm -f $export_options_plist_path
#fi


# 输出打包总用时
# echo "\033[36;1m使用AutoPackageScript打包总用时: ${SECONDS}s \033[0m"
# exit 0


# 上传IPA到AppStore
if [ "$build" = "6" ]; then
    echo "😊😊准备上传AppStroe"
    echo "⚠️确保【～/用户名/private_keys/】目录有对应的【68N94Y8R4Xzhujie】私钥⚠️"
#    xcrun altool --validate-app -f "${export_ipa_path}/${ipa_name}.ipa" -t ios --apiKey $APIKEY --apiIssuer $APIISUSER [--output-format xml]
#
#    xcrun altool --upload-app -f "${export_ipa_path}/${ipa_name}.ipa" -t ios --apiKey $APIKEY --apiIssuer $APIISUSER --verbose
    
    #使用Application Loader插件上传
    ALTOOLPATH=/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool

    IPAPATH="${export_ipa_path}/${ipa_name}.ipa"

    "${ALTOOLPATH}" --validate-app -f "${IPAPATH}" -u "${APPID}" -p "${APPPASSWORD}" --output-format xml


    "${ALTOOLPATH}" --upload-app -f "${IPAPATH}" -u "${APPID}" -p "${APPPASSWORD}" --output-format xml

# 上传IPA到蒲公英
else

WEBHOOK='https://oapi.dingtalk.com/robot/send?access_token=0e80a796ce8d4c39dd5627e2236e82a046880d3727c77d7d52338169182e7939'

./uploadPgyer.sh "$export_ipa_path/$ipa_name.ipa" "${pgyer_api_key}" $WEBHOOK $export_ipa_path
#    echo "\033[32;1m开始上传 ${ipa_name}.ipa 到 Pgyer \033[0m"
#    echo "😊😊准备上传Pgyer "
#    curl -F "file=@$export_ipa_path/$ipa_name.ipa" -F "_api_key=${pgyer_api_key}" \
#    https://www.pgyer.com/apiv2/app/upload --progress-bar | tee "$export_ipa_path/pgyer_upload.log"
#
#    echo "\033[32;1m上传到 Pgyer 成功 🎉  🎉  🎉  \033[0m"

fi

# 只保存到项目打包机器上
if [ -n "$PGYER_CHANNEL_ID" ];
then
# 上传AppStore时候留个podfile记录
if [ "$build" = "6" ]; then
    SRCROOT=$(pwd)
    podfile=$(find .  -name "*odfile.lock")
    podfile="${podfile#./}"
    podfile="${podfile%.lock}"
    echo "识别:podfile=${podfile}"
    
    export_InfoConfig="$export_archive_path/Info.plist"
    
    vesionKey="ApplicationProperties:CFBundleShortVersionString"
    shortVesion=$('/usr/libexec/PlistBuddy' -c 'Print :'$vesionKey'' $export_InfoConfig)
    bundleVersionKey="ApplicationProperties:CFBundleVersion"
    bundleVesion=$('/usr/libexec/PlistBuddy' -c 'Print :'$bundleVersionKey'' $export_InfoConfig)
    logPath="～/Desktop/AppStoreVersionLog"
    if [ ! -d "$logPath" ]; then
            echo "创建文件夹"
            mkdir $logPath
    else
            echo "文件夹已存在"
    fi
    #copy下资源
    cp -r $export_path $logPath
    name="$logPath/${scheme_name}-${DATE}/Podfile_$shortVesion.lock"
    echo "name=${name}"
    cat "$podfile.lock" >> $name
   
fi
fi
# 输出打包总用时
echo "\033[36;1m使用AutoPackageScript打包总用时: ${SECONDS}s \033[0m"

exit 0

