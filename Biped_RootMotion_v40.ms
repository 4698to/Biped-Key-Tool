--Maxscript
--author:4698to
--E-Mail:738746223@qq.com
--99U:199505
--https://afdian.net/@4698to
--2020-03-31
try(destroyDialog bipedRootTs )catch()
rollout bipedRootTs  "Biped RootMotion 4.0"
(

    group "1 : 选择bip质心" (
        pickbutton btn_01 "bip" width:100 height:25 across:2 toolTip:"选中biped质心"
        button btn_02 "root" width:100 height:25
    )
    group "2 : 选择停止帧" (
    	spinner sel_start "起始帧" range:[0,999999,0] type:#integer offset:[10,0] across:2 enabled:false
    	button btn_get_startFrame "设置" width:70 offset:[0,-3]
       	spinner sel_stop "停止帧" range:[0,999999,0] type:#integer  offset:[10,0]  enabled:false across:2--align:#Center
       	button btn_getFrame "设置" width:70 offset:[0,-3]
    )
    group "3 : 先处理手脚IK ,再转移位移或旋转" (
        checkbox is_do_y "Y" checked:true across:4 --align:#Left
        checkbox is_do_X "X" --align:#Center
        checkbox is_do_Z "Z" --align:#right
        checkbox is_iks "IK逐帧" checked:true

        button btn_ik "IKFK" width:70 height:25 across:3
        button btn_do  "转移位移" width:70 height:25 enabled:false
        button btn_rt "刷新" width:70 height:25 enabled:false

        button btn_do_rotationpart "转移旋转" width:70 height:25 enabled:false align:#center toolTip:"仅Z轴"
    )
    HyperLink lbl_01 "使用前必看" address:"https://github.com/4698to/Biped-Key-Tool" color:blue hoverColor:(color 0 255 255)  align:#center


    local bipRootBone = undefined
    local bipbody57 = undefined --biped骨骼质心

    local StartItFrames = 0 --从哪帧开始处理计算
    local start_index = undefined

    local StopItFrames = 1--undefined -- 在哪帧停止 ,之前都全部转移到root
    local stop_index = undefined

    local bipStratFrames = undefined --biped骨骼质心动画第一帧
    local ZbipStratFrames = undefined
    local bipEndFrames = undefined --最后一帧
    local ZbipEndFrames = undefined
    local YX_distance =#()--,Z_distance = #()
    local hori_keys =#()
    local temp_point = undefined --, biped_tg = #()

        --------------------------------------------------------
        struct moveData (
            time,
            Ydist,
            Xdist,
            Zdist,
            tm,
            rotationpart
            -- Struct body.
        )

        --------------------------------------------------------
        fn getbip_leg_arm =
        (
            biped_l_leg = biped.getNode bipbody57 #lleg link:3
            biped_r_leg = biped.getNode bipbody57 #rleg link:3
            biped_l_arm = biped.getNode bipbody57 #larm link:4
            biped_r_arm = biped.getNode bipbody57 #rarm link:4
            return #(biped_l_leg,biped_r_leg,biped_l_arm,biped_r_arm)
        )
        --------------------------------------------------------
        fn biped_add_slidkey bipobjs = --设置IKFK
        (

            for o in bipobjs do
            (
                --IK
                local keyCount = o.controller.keys.count
                if keyCount == 0 do Continue
                range_endkey = biped.getKey o.controller keyCount
                range_startkey = biped.getKey o.controller 1
                --local keyCount = (animationRange.end.frame as integer) - (animationRange.start.frame as integer)
                animationRange = interval range_startkey.time range_endkey.time
                    if is_iks.state do
                    (

                        keyCount = (range_endkey.time.frame as integer) - (range_startkey.time.frame as integer)
                        for i=1 to keyCount do
                        (
                            try(
                                --format "i::%\r\n" i
                                local the_key = biped.getKey o.controller i
                                local next_key = biped.getKey o.controller (i + 1)

                                if next_key.time - the_key.time != 1f do (

                                    local the_key_time = (the_key.time.frame as integer)+1
                                    local next_key_time = (next_key.time.frame as integer)-1


                                    if the_key.ikspace == 1 and next_key.ikspace == 1 do
                                    (
                                        for t in the_key_time to next_key_time do (
                                        biped.addNewkey o.controller t
                                        )
                                    )
                                )
                            )catch(format "%::% \r\n" o.name i )

                        )
                    )
                --FK
                keyCount = o.controller.keys.count
                for i = 1 to keyCount do
                (
                    try
                    (
                        the_key = biped.getKey o.controller i
                        if the_key != undefined do (
                            sliderTime = the_key.time
                            biped.setFreeKey o
                        )
                    )
                    catch (continue)
                )
            )
        )
        --------------------------------------------------------

        --------------------------------------------------------
    on btn_getFrame pressed do
    (

        StopItFrames = sliderTime.frame as integer ;
        if StartItFrames < StopItFrames then (
	        sel_stop.value = StopItFrames
	        btn_do.enabled =true ;btn_do_rotationpart.enabled =true
	    )else(
	    		StopItFrames = 1
	        	messageBox "设置帧错误！"
	        )
    )
    on btn_get_startFrame pressed do
    (
    	StartItFrames = sliderTime.frame as integer ;
    	if StopItFrames > StartItFrames then(
    		sel_start.value = StartItFrames
    	)else(
    		StartItFrames = 1
    		messageBox "设置帧错误！"
    	)
    )
    on btn_ik pressed do
    (
        if IsValidNode bipbody57 do
        (
            --bipbody57.controller.enableSubAnims = true
            local biped_tg = getbip_leg_arm()
            biped_add_slidkey biped_tg
        )
    )
    --------------------------------------------------------

    on btn_01 picked obj do
    (

            if classof obj == Biped_Object do
            (

                    bipbody57 = obj.controller.rootNode;
                    bipbody57.controller.enableSubAnims = true
                    if bipbody57.parent != undefined then
                    (
                        bipRootBone = bipbody57.parent
                        btn_01.text = bipbody57.name
                        btn_02.text = bipRootBone.name

                    )else(bipbody57 = undefined ;messagebox "bip质心没连接上根骨骼")

            )

    )
    on btn_02 pressed do
    (
        if selection.count != 0 do
        (
            --bipRootBone = selection[1]
        )
    )
    --------------------------------------------------------
    on btn_do pressed do
    (
        -- 水平 xy
        if isValidNode bipbody57 then
        (

            --拿到停止帧序号
            stop_index = getKeyIndex bipbody57.controller.vertical.controller StopItFrames
            if stop_index == 0 do (
                biped.addNewkey bipbody57.controller.vertical.controller StopItFrames
                biped.addNewkey bipbody57.controller.horizontal.controller StopItFrames
                stop_index = getKeyIndex bipbody57.controller.vertical.controller StopItFrames
            )
            --拿到起始帧序号
            start_index = getKeyIndex bipbody57.controller.vertical.controller StartItFrames
            if start_index == 0 do
            (
            	biped.addNewkey bipbody57.controller.vertical.controller StartItFrames
            	biped.addNewkey bipbody57.controller.horizontal.controller StartItFrames
            	start_index = getKeyIndex bipbody57.controller.vertical.controller StartItFrames
            )
            --拿到起始帧
            bipStratFrames  = biped.getKey bipbody57.controller.horizontal.controller start_index
            ZbipStratFrames  = biped.getKey bipbody57.controller.vertical.controller start_index

            bipkeycount = bipbody57.controller.horizontal.controller.keys.count
            bipEndFrames = biped.getKey bipbody57.controller.horizontal.controller bipkeycount
            --这里假设质心三轴帧数一致
            ZbipEndFrames = biped.getKey bipbody57.controller.vertical.controller bipkeycount
            --------------------------------------------

            --- 收集从第一帧到停止帧 ，这中间每一帧质心移动数据，
            for i = start_index to stop_index do
            (
                temps = moveData()
                tempKey = biped.getKey bipbody57.controller.horizontal.controller i
                --单独处理Z轴
                ZtempKey = biped.getKey bipbody57.controller.vertical.controller i
                -- 如果三轴帧数不统一这里会出问题
                --tempDistance = tempKey.y - bipStratFrames.y
                temps.time = tempKey.time
                --temp.Ydist = tempDistance
                temps.Ydist = tempKey.y - bipStratFrames.y

                temps.Xdist = tempKey.x - bipStratFrames.x
                temps.Zdist = ZtempKey.z - ZbipEndFrames.z
                append YX_distance temps
                --YX_distance[i] = temp
                temps = undefined
            )
            --------------------------------------------
            --替换为最终位移距离

            YX_distance[YX_distance.count].Ydist = bipEndFrames.y - bipStratFrames.y
            YX_distance[YX_distance.count].Xdist = bipEndFrames.x - bipStratFrames.x
            YX_distance[YX_distance.count].Zdist = ZbipEndFrames.z - ZbipStratFrames.z

            --------------------------------------------
            --保存质心动画
            hori_keys = for i in bipbody57.controller.horizontal.controller.keys collect i.time

            temp_point = point name: (bipbody57.name + "_tempBipedAnima")
            for tt in hori_keys do
            (
                at time tt, with animate on, in coordsys world
                (
                    temp_point.transform = bipbody57.transform
                )

            )
            --------------------------------------------
            --设置根骨骼动画
            undo "biped57_yxz01" on
            (
                --处理Y轴
                if is_do_y.state do
                (
                    for i=1 to YX_distance.count do
                    (
                        tt = YX_distance[i].time
                        at time tt,with animate on, in coordsys world
                        (
                            bipRootBone.pos.y = YX_distance[i].Ydist
                        )
                    )
                )
                --处理X轴
                if is_do_X.state do
                (
                    for i=1 to YX_distance.count do
                    (
                        tt = YX_distance[i].time
                        at time tt,with animate on, in coordsys world
                        (
                            bipRootBone.pos.x = YX_distance[i].Xdist
                        )
                    )
                )
                --处理Z轴
                if is_do_Z.state do
                (
                    for i=1 to YX_distance.count do
                    (
                        tt = YX_distance[i].time
                        at time tt,with animate on, in coordsys world
                        (
                            if YX_distance[i].Zdist < 0 then (
                                bipRootBone.pos.z = 0
                            )else(
                                bipRootBone.pos.z = YX_distance[i].Zdist
                            )
                        )
                    )
                )
            )
            --------------------------------------------
            --还原动画效果
            format "已处理质心动画：% \n " bipbody57.name
            undo "xxxx01" on
            (
                	keyCount = bipbody57.controller.horizontal.controller.keys.count
	    	        for i = start_index to keyCount do
		    	    (
		    	    	local tempKey = biped.getKey bipbody57.controller.horizontal.controller i

		    	        at time tempKey.time, with animate on, in coordsys world
		    	        (
		    	        	tempKey.x = temp_point.pos.x
		    	        	tempKey.y = temp_point.pos.y
		    	        )

		    	    )
		    	    keyCount = bipbody57.controller.vertical.controller.keys.count
	    	        for i = start_index to keyCount do
		    	    (
		    	    	local tempKey = biped.getKey bipbody57.controller.vertical.controller i

		    	        at time tempKey.time, with animate on, in coordsys world
		    	        (
		    	        	tempKey.z = temp_point.pos.z
		    	        )

		    	    )
            )
            format "已还原动画效果：% \n" bipbody57.name
            btn_rt.enabled = true
        )else(
            btn_01.text = "bip";btn_02.text = "root" ; sel_stop.value = 0
            is_do_X.checked = false
            is_do_Z.checked = false;btn_rt.enabled = false
            messageBox "请重新设置！"
        )
        --------------------------------------------
    )

    on btn_rt pressed do
    (
        if isValidNode bipbody57 then
        (
            if YX_distance.count > 1 do
            (

                --------------------------------------------
                --设置根骨骼动画
                undo "biped57_yxz02" on
                (
                    --处理Y轴
                    if is_do_y.state do
                    (
                        for i=1 to YX_distance.count do
                        (
                            tt = YX_distance[i].time
                            at time tt,with animate on, in coordsys world
                            (
                                bipRootBone.pos.y = YX_distance[i].Ydist
                            )
                        )
                    )
                    --处理X轴
                    if is_do_X.state do
                    (
                        for i=1 to YX_distance.count do
                        (
                            tt = YX_distance[i].time
                            at time tt,with animate on, in coordsys world
                            (
                                bipRootBone.pos.x = YX_distance[i].Xdist
                            )
                        )
                    )
                    --处理Z轴
                    if is_do_Z.state do
                    (
                        for i=1 to YX_distance.count do
                        (
                            tt = YX_distance[i].time
                            at time tt,with animate on, in coordsys world
                            (
                                if YX_distance[i].Zdist < 0 then (
                                    bipRootBone.pos.z = 0
                                )else(
                                    bipRootBone.pos.z = YX_distance[i].Zdist
                                )
                            )
                        )
                    )
                )
                --------------------------------------------
                undo "xxxx02" on
                (

                    keyCount = bipbody57.controller.horizontal.controller.keys.count
	    	        for i = start_index to keyCount do
		    	    (
		    	    	local tempKey = biped.getKey bipbody57.controller.horizontal.controller i

		    	        at time tempKey.time, with animate on, in coordsys world
		    	        (
		    	        	tempKey.x = temp_point.pos.x
		    	        	tempKey.y = temp_point.pos.y
		    	        )

		    	    )
		    	    keyCount = bipbody57.controller.vertical.controller.keys.count
	    	        for i = start_index to keyCount do
		    	    (
		    	    	local tempKey = biped.getKey bipbody57.controller.vertical.controller i

		    	        at time tempKey.time, with animate on, in coordsys world
		    	        (
		    	        	tempKey.z = temp_point.pos.z
		    	        )

		    	    )
                )
            )

        )else(
            btn_01.text = "bip";btn_02.text = "root" ; sel_stop.value = 0
            is_do_X.checked = false;is_do_Z.checked = false;
            btn_rt.enabled = false
            messageBox "请重新设置！"
        )
    )
    --------------------------------------------------------
    on btn_do_rotationpart pressed do
    (
    	if isValidNode bipbody57 then
    	(
    	    --拿到停止帧序号 旋转
    	    YX_distance = #()
    	    stop_index = getKeyIndex bipbody57.controller.turning.controller StopItFrames

    	    if stop_index == 0 do (
    	        biped.addNewkey bipbody57.controller.turning.controller StopItFrames
    	        stop_index = getKeyIndex bipbody57.controller.turning.controller StopItFrames
    	    )
    	    bipEndFrames = biped.getKey bipbody57.controller.turning.controller stop_index
    	    --拿到起始帧序号 旋转
    	    start_index = getKeyIndex bipbody57.controller.turning.controller StartItFrames

    	    bipStratFrames  = biped.getKey bipbody57.controller.turning.controller start_index

    	    if start_index == 0 do
    	    (
    	    	biped.addNewkey bipbody57.controller.turning.controller StartItFrames
    	    	start_index = getKeyIndex bipbody57.controller.turning.controller StartItFrames
    	    )


    	    format "start_index::% stop_index::% \n " start_index stop_index
    	    for i = start_index to stop_index do
    	    (
    	        temps = moveData()
    	        tempKey = biped.getKey bipbody57.controller.turning.controller i
    	        --sliderTime = tempKey.time
    	        --和第一帧的角度差
    	        temps.rotationpart = bipStratFrames.rotation * inverse tempKey.rotation
    	    	--temps.tm = bipbody57.transform

    	        temps.time = tempKey.time

    	        --append YX_distance temps
    	        YX_distance[i] = temps
    	        temps = undefined
    	    )
    	    --保存质心动画
    	    hori_keys = for i in bipbody57.controller.turning.controller.keys collect i.time
    	    temp_point = point name: (bipbody57.name + "_tempBipedAnima_rotationpart")
    	    for tt in hori_keys do
    	    (
    	        at time tt, with animate on, in coordsys world
    	        (
    	            temp_point.transform = bipbody57.transform
    	        )

    	    )
    	    --设置根骨骼动画
    	    undo "biped57_rotationpart" on
    	    (
    	        --处理Y轴
    	        if is_do_Z.state do
    	        (
    	            --for i=2 to YX_distance.count do
    	            for i = start_index to stop_index do
    	            (
    	            	local offsetTm = quatToEuler YX_distance[i].rotationpart
    	            	local tempKey = biped.getKey bipbody57.controller.turning.controller i
    	                local tt = YX_distance[i].time
    	                at time tt,with animate on, in coordsys world
    	                (
    	                	tempKey.rotation -= (eulerToQuat (eulerAngles 0 0 (offsetTm.z * - 1)))
    	                	--format "time::% offsetTm::% \n" tt offsetTm.z

    	                )
    	            )
    	            --------
    	            --处理停止帧后面的帧
    	            local keyCount = bipbody57.controller.turning.controller.keys.count
    	            local next_stop_keyindex = stop_index + 1
    	            if keyCount > stop_index do (
    	            	local offsetTm = quatToEuler YX_distance[stop_index].rotationpart
	    	            for i = next_stop_keyindex to keyCount do
	    	            (
	    	            	local tempKey = biped.getKey bipbody57.controller.turning.controller i
	    	            	at time tempKey.time,with animate on, in coordsys world
	    	                (
	    	                	tempKey.rotation -= (eulerToQuat (eulerAngles 0 0 (offsetTm.z * - 1)))
	    	                )
	    	            )
    	            )
    	        )
    	        --处理X轴
    	        if is_do_X.state do
    	        (

    	        )
    	        --处理Z轴
    	        if is_do_Z.state do
    	        (

    	        )
    	    )
    	    --还原动画效果
    	    undo "bipRootBone.rotation" on
    	    (
    	        for i = start_index to stop_index do
    	        (
    	        	local tt = YX_distance[i].time
    	            local offsetTm =quatToEuler YX_distance[i].rotationpart

    	            at time tt, with animate on, in coordsys world
    	            (
    	            	bipRootBone.rotation = eulerToQuat (eulerAngles 0 0 offsetTm.z)
    	            )
    	        )
    	        --还原质心位移动画
    	    )
    	    	/*
    	        keyCount = bipbody57.controller.horizontal.controller.keys.count
    	        for i = start_index to keyCount do
	    	    (
	    	    	local tempKey = biped.getKey bipbody57.controller.horizontal.controller i

	    	        at time tempKey.time, with animate on, in coordsys world
	    	        (
	    	        	tempKey.x = temp_point.pos.x
	    	        	tempKey.y = temp_point.pos.y
	    	        )

	    	    )*/


    	)

    )
    --------------------------------------------------------

)

createDialog  bipedRootTs 270 260