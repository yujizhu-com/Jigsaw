#!bin/bash

function Main()
{
	# brew install tree #安装tree
    # grep -rnl "你" "$DIR"  	#r 递归文件夹 n 显示行号 l只显示文件 o 只显示匹配的pattern部分 h 不显示所在文件名 E 应用regex拓展文法 #v 显示未匹配的行 f 读取规则文件
    # tree -fi "$DIR" 			#f 显示完整的相对路径 i 不显示结构图
    # find . -name "*.png"
    # uniq                      #d 仅显示重复的行
    
  	local wd=`pwd`
    local temp="$wd/temp.txt"
    cd "$DIR"
    local skip="_moban"

    local ap="$wd/2_ap.txt"
    	find . -regex ".*" | sort -k1,1  |  uniq  > "$ap"

    local apBuiltin="$wd/2_apBuiltin.txt"
        grep -E "\.(\/[_\*\#][_a-zA-Z0-9]+){2,}.*\.(png|jpg|webp|mp3|ogg|json|plist|cpp)" "$ap" | sort -k1,1  |  uniq > "$apBuiltin"
        
    local napBuiltin="$wd/2_napBuiltin.txt"
    	grep -oE "[^\/]+$" "$apBuiltin" | sort -k1,1  |  uniq > "$napBuiltin"

    local builtinPlist="$wd/包内Plist.txt"
    	grep -E ".*\.plist" "$apBuiltin" > "$builtinPlist"

    local builtinPlistSubRes="$wd/包内Plist中资源.txt"
        grep -oE "<key.+key>" `grep -E ".*\.plist" "$apBuiltin"` > "$temp"
        sed -in "s|<key>||g" "$temp"
        sed -in "s|</key>||g" "$temp"
        grep -oE ".+\.(png|jpg|webp|mp3|ogg)" "$temp" > "$builtinPlistSubRes"

    local builtinJson="$wd/包内Json.txt"
        grep -E ".*\.json" "$apBuiltin" > "$builtinJson"

    local builtinJsonSubRes="$wd/包内Json中资源.txt"
        grep -ohE "\"[^\"\n]+\.(png|jpg|webp|mp3|ogg)\"" `cat "$builtinJson"` | sort |uniq > "$builtinJsonSubRes"
        sed -in "s|\"||g" "$builtinJsonSubRes"

   	local apBuiltin2="$wd/2_apBuiltin2.txt"
   		cp "$apBuiltin" "$apBuiltin2"
   		cat "$builtinPlistSubRes" >> "$apBuiltin2"


    local apOrigin="$wd/3_apOrigin.txt"
        grep -vE "\.(\/[_\*][_a-zA-Z0-9]+){2,}.*\.(png|jpg|webp|mp3|plist)" "$ap" | grep -E ".*\.(png|jpg|webp|mp3|plist)" | sort -k1,1  |  uniq >  "$apOrigin"

    local napOrigin="$wd/3_napOrigin.txt"
    	grep -oE "[^\/]+\..+$" "$apOrigin" | sort -k1,1  |  uniq > "$napOrigin"
       
    local builtinRes="$wd/8_builtinRes.txt"
        rm -f "$builtinRes"
        grep -E ".*\.(png|jpg|webp|mp3)" "$napBuiltin" > "$temp"
        # [^...]不含...中任一元素
        grep -ohE "[^\:]+\.(png|jpg|webp)$" "$builtinPlistSubRes" >> "$temp" 
        sort -k1 "$temp" | uniq > "$builtinRes"  

    local napMutiBuiltin="$wd/napMutiBuiltin.txt"
    	sort -k1 "$temp" | uniq -d > "$napMutiBuiltin"

    local apMutiBuiltin="$wd/包内重名.txt"
        #错误做法,如YY.png能匹配XXXYY.png
        #grep -f "$napMutiBuiltin" "$apBuiltin2" > "$apMutiBuiltin" 
        rm -f "$temp"
        for i in `cat "$napMutiBuiltin"`
        do
            grep -hE "[:\/]${i}$" "$apBuiltin2" >> "$temp"  
        done
    	for i in `cat "$temp"`
    	do
    		local file=${i##*/}
    		file=${file##*:}
    		local dir=${i%:*}
    		sed -in "s|${i}|${file}\t${dir}|g" "$temp" # n用's|||g'中的字符指定分隔符
    	done
    	sort -k1 "$temp" | uniq > "$apMutiBuiltin"
    	
    local ccbRes="$wd/8_ccbRes.txt"
        rm -f "$ccbRes"
        rm -f "$temp"
        #读取ccb目录
        for i in `find . -regex ".*.redproj"`
        do
            local dir=${i%%/*}
            find $dir -regex ".*.red" >> "$temp"
        done
        #o 只显示匹配的pattern部分 h 不显示所在文件名 E 应用regex拓展文法 
        grep -ohE "[^\/\<\>\.]+\.(png|jpg|webp|mp3)" `cat "$temp"` | sort -k1  |  uniq  >> "$ccbRes" 


        #解析代码文件
    # local cppRes="$wd/8_cppRes.txt"
    #     # cpp文件中,过滤加号
    #     grep -ohE "[^\/\<\>\.\+]+\.(png|jpg|webp|mp3)" `grep -E ".*\.cpp" "$apBuiltin"` | sort -k1  |  uniq > "$cppRes"  
        #分析代码中的资源
        
    local codeFile="$wd/代码文件.txt"
        local cppDir=${DIR/\/res\//\/src\/projectCode\/}
        find "$cppDir" > "$codeFile"
        grep -E ".*\.(c|cpp|h|hpp|m|mm)$" "$codeFile"> "$temp"
        grep -E ".*\.cpp" "$apBuiltin" >> "$temp"
        sort -k1 "$temp" | uniq   > "$codeFile"

    local codeRawStr="$wd/代码原始字串.txt"
        grep -ohE "\"[^\"]+\"" `cat "$codeFile"` >"$codeRawStr" 
        sed -in "s|\"|\\n|g" "$codeRawStr"
        sed -in "s|\\\|\\n|g" "$codeRawStr"
        sed -in "s|\\/|\\n|g" "$codeRawStr"

    local codeStr="$wd/代码字串.txt"
        grep -ohE ".+\.(png|jpg|webp|mp3|ogg|plist|json)" "$codeRawStr" > "$temp"
        grep -vohE ".*\.(redream|cpp|hpp|php|zip|h|c|frag|fsh|vert)" "$temp" > "$codeStr"

    local codeRes="$wd/代码资源.txt"
        grep -ohE "\".+\.(png|jpg|webp|mp3|ogg|plist|json)\"" `cat "$codeFile"` > "$temp" 
        sed -in "s|\"|\\n|g" "$temp"
        sed -in "s|\\\|\\n|g" "$temp"
        sed -in "s|\\/|\\n|g" "$temp"
        grep -E ".+\.(png|jpg|webp|mp3|ogg|plist|json)$" "$temp" > "$codeRes"

    local codePlist="$wd/代码Plist.txt"
        grep -E ".+\.plist$" "$codeRes" | sort | uniq > "$codePlist"

    local codePlistRes="$wd/代码Plist.txt"

    local codeJson="$wd/代码Json.txt"
        grep -E ".+\.json$" "$codeRes" | sort | uniq  > "$codeJson"

    local codeJsonRes="$wd/代码Json.txt"

    local needRes="$wd/8_needRes.txt"
        rm -f "$needRes"
        cat "$ccbRes" >> "$needRes"
        cat "$cppRes" >> "$needRes"

    local unuseBuiltin="$wd/9_unuseBuiltin.txt"
        rm -f "$unuseBuiltin"
        grep -vf "$needRes" "$builtinRes" | sort -k1,1  |  uniq  >> "$unuseBuiltin"

    local lackBuiltin="$wd/9_lackBuiltin.txt"
        rm -f "$lackBuiltin"
        #v 显示未匹配的行 f 读取规则文件
        grep -vf "$builtinRes" "$needRes" | sort -k1,1  |  uniq  >> "$lackBuiltin" 

    local unuseOrigin="$wd/10_unuseOrigin.txt"
        grep -vf "$needRes" "$napOrigin" | sort -k1,1  |  uniq  > "$unuseOrigin"

    local lackOrigin="$wd/10_lackOrigin.txt"
        rm -f "$lackOrigin"
        grep -vf "$napOrigin" "$needRes" | sort -k1,1  |  uniq  >> "$lackOrigin"

        #导出
    local apNameError="$wd/命名错误.txt"
        grep -E "[[:space:]]+" "$ap" > "$apNameError"

    local napBuiltinOgg="$wd/12_napBuiltinOgg.txt"
        grep -oE "[^\/\.]+\.ogg" "$napBuiltin" | sort -k1,1  |  uniq  > "$napBuiltinOgg"

    local napBuiltinMp3="$wd/12_napBuiltinMp3.txt"
        grep -oE "[^\/\.]+\.mp3" "$napBuiltin" | sort -k1,1  |  uniq  > "$napBuiltinMp3"


    local lackBuiltinMp3="$wd/包内缺失mp3.txt"
    	grep -E ".*\.mp3" "$lackBuiltin" > "$lackBuiltinMp3"

    local lackBuiltinOgg="$wd/包内缺失ogg.txt"
    	grep -oE ".*\." "$napBuiltinOgg" > "$temp"
    	grep -vf "$temp" "$napBuiltinMp3" | sed 's/.mp3/.ogg/g' > "$lackBuiltinOgg"


    local lackBuiltinPng="$wd/包内缺失png.txt"
    	grep -E ".*\.png" "$lackBuiltin" > "$lackBuiltinPng"

    local lackBuiltinJpg="$wd/包内缺失jpg.txt"
    	grep -E ".*\.jpg" "$lackBuiltin" > "$lackBuiltinJpg"

    local lackBuiltinWebp="$wd/包内缺失webp.txt"
    	grep -E ".*\.webp" "$lackBuiltin" > "$lackBuiltinWebp"



    
    #f 强力删除 r 递归文件夹
    # rm -f "$temp" 
}

read -p 拖入文件夹: DIR

Main "$DIR"