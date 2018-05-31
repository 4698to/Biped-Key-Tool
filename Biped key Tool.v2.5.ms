rollout Biped_transform "Biped key Tool.v2.5"
(
    global bip_t
    struct bip_test
    (
        biped_obj,
        biped_b,
        root,--根root
        keys_z_num,
        keys_x_num,
        keys_y_num,
        Ground_height,
        end_key_num,
        --biped_les = #(),
        --b_h_strat = undefined,
        --b_h_xy =undefined,
        biped_l_leg,
        biped_r_leg,
        biped_l_arm,
        biped_r_arm,
        biped_tg,
        do_end,
        do_start,
        -------------------------------------------------------------

        -------------------------------------------------------------
        fn biped_add_freekey biped_node_controller biped_node = -- 设置IK
        (
            for i=1 to bip_t.end_key_num do
            (
                try
                (
                    the_key = biped.getKey biped_node_controller i
                    the_key_time = (the_key.time.frame as integer)
                )
                catch (continue)
                t=the_key_time
                sliderTime= t
                biped.setFreeKey biped_node

            )
        ),
    -----------------------------------------------------
        fn biped_add_slidkey biped_node_controller = --设置FK
        (
            bip_t.end_key_num = Biped_transform.end_key.value - Biped_transform.start_key.value
            for i=1 to (bip_t.end_key_num + 1) do (
                try (
                    the_key = biped.getKey biped_node_controller i
                    next_key = biped.getkey biped_node_controller (i+1)
                )
                catch (continue)

                the_key_time = (the_key.time.frame as integer)+1
                next_key_time = (next_key.time.frame as integer)-1
                if next_key.time - the_key.time ==1f do (continue)

                if the_key.ikspace == 1 and next_key.ikspace == 1 do(
                    for t in the_key_time to next_key_time do (
                        --print(t)
                        biped.addNewkey biped_node_controller t
                    )
                )
            )
        ),

    -------------------------------------------
        fn cT_root = --检查Root
        (
            try(
                if Biped_transform.create_root.checked == true then (
                    if bip_t.biped_obj.parent == undefined then(
                        bip_t.root = point()
                        bip_t.root.name = "root_" + bip_t.biped_obj.name
                        bip_t.biped_obj.parent = bip_t.root
                        return true

                    )
                    else(return true)
                )
                else (
                    if bip_t.biped_obj.parent == undefined then (
                        if queryBox "选择的Biped没有Root，是否创建？" then (
                            bip_t.root = point()
                            bip_t.root.name = "root_" + bip_t.biped_obj.name
                            bip_t.biped_obj.parent = bip_t.root
                            return true
                        )
                        else (return false)
                    )
                    else (return true)
                )
            )
            catch(return false)
        ),

        fn cT_biped = --检查biped是否选取正常
        (
            try
            (
                bip_t.end_key_num = (animationRange.end.frame as integer)-(animationRange.start.frame as integer)

                if (not IsValidNode bip_t.biped_obj) do (
                    try
                    (
                        bip_t.biped_obj = execute("$"+ "'"+Biped_transform.pick_biped.text+"'")
                    )catch("没有biped")
                )
                bip_t.biped_b = bip_t.biped_obj.transform.controller
                bip_t.biped_l_leg = biped.getNode bip_t.biped_obj #lleg link:3
                bip_t.biped_r_leg = biped.getNode bip_t.biped_obj #rleg link:3
                bip_t.biped_l_arm = biped.getNode bip_t.biped_obj #larm link:4
                bip_t.biped_r_arm = biped.getNode bip_t.biped_obj #rarm link:4
                bip_t.biped_tg = #(bip_t.biped_l_leg,bip_t.biped_r_leg,bip_t.biped_l_arm,bip_t.biped_r_arm)

                return true
            )
            catch
            (
                messageBox "重新 Biped 和 Root 试试！"
                return false
            )
        )
    )
    ---------------------------------------------------------------
    GroupBox grp_01 "Select" pos:[1,8] width:184 height:76
    --pickbutton pick_biped "Biped" pos:[8,24] width:50 height:21
    button pick_biped "拾取Biped" pos:[8,24] width:170 height:21 tooltip:"拾取biped"
    --button btn_biped "" pos:[64,24] width:110 height:21
    --pickbutton pick_root "Root" pos:[8,56] width:50 height:21
    button pick_root "拾取根节点" pos:[8,56] width:170 height:21 tooltip:"拾取根节点"
    --button btn_root "" pos:[64,56] width:110 height:21
    -------------------------------------------------------------
    GroupBox grp_02 "Biped" pos:[1,96] width:184 height:159
    checkbox sel_vertical "Z" pos:[8,112] width:24 height:15


    button btn_Bake "Do" pos:[101,218] width:74 height:21
    button btn_bake_Ik "Sliding Key" pos:[10,189] width:72 height:21


    checkbox sel_horizontal_Y "Y" pos:[68,112] width:24 height:15 checked:true
    checkbox sel_horizontal_X "X" pos:[38,112] width:24 height:15
    checkbox create_root "Root" pos:[98,112] width:50 height:15 checked:true tooltip:"自动检查设置Root"
    spinner Ground_floor "" pos:[38,136] width:48 height:16 range:[-9999,9999,0] type:#float


    label lbl1 "Floor" pos:[8,136] width:24 height:16
    spinner sel_xy "" pos:[127,136] width:48 height:16 range:[0,300,20] type:#float tooltip:"位移阈值，角色肩宽"--enabled:false
    label lbl2 "X Y" pos:[101,136] width:20 height:16 --enabled:false
    spinner end_key "" range:[-99999,99999,(animationRange.end.frame as integer)] type:#integer pos:[128,160] width:48 height:16 enabled:false --设置从哪帧开始处理
    spinner start_key "" range:[-99999,99999,(animationRange.start.frame as integer)] type:#integer pos:[38,160] width:48 height:16 enabled:false--range:[0,100,0] --设置到哪帧为止结束处理
    label lbl4 "Start" pos:[8,160] width:24 height:16 enabled:false
    label lbl5 "End" pos:[101,160] width:20 height:16 enabled:false
    button btn_bake_Fk "Free Key" pos:[10,218] width:72 height:21
    -------------------------------------UI pressed

    on pick_biped pressed do --拾取Biped
    (
        if (selection.count != 0) and (classOf selection[1] == Biped_Object )do
        (
            bip_t.biped_obj = (selection[1].transform.controller).rootNode

            bip_t.biped_b = bip_t.biped_obj.transform.controller

            pick_biped.text = bip_t.biped_obj.name
        )
    )


    on pick_root pressed do --拾取根节点
    (
        if selection.count != 0 do
        (
            try(
                bip_t.root = selection[1]
                bip_t.root.pos.controller = tcb_position ()
                pick_root.text = bip_t.root.name
                if bip_t.biped_obj.parent != bip_t.root do
                (
                    if queryBox "Root和Biped好像没连接！是否连接？" then (bip_t.biped_obj.parent = bip_t.root ) else pick_root.text = ""
                )

            )catch()
        )
    )

    on start_key changed val do
    (
        if start_key.value != end_key.value then (
            bip_t.end_key_num = end_key.value - start_key.value
        )
        else (
            end_key.value = start_key.value +1
            bip_t.end_key_num = end_key.value - start_key.value
            )
    )

    on end_key changed val do
    (
        if start_key.value != end_key.value then (
            bip_t.end_key_num = end_key.value - start_key.value
        )
        else (
            end_key.value = start_key.value +1
            bip_t.end_key_num = end_key.value - start_key.value
            )
    )

    on btn_bake_Fk pressed do
    (
        try (
            bip_t.cT_biped()
            for i in bip_t.biped_tg do (
                local biped_fr=i.transform.controller
                bip_t.biped_add_freekey biped_fr i
            )
        )
        catch(print"FK_bug")
    )

    on btn_bake_Ik pressed do
    (
        try (

            bip_t.cT_biped()
            for i in bip_t.biped_tg do (
                --print i
                local biped_fr=i.transform.controller
                bip_t.biped_add_slidkey biped_fr
           )
        )
        catch(print"Ik_bug")
    )
----------------------------------------------------------------------

    --biped_b.vertical.controller  --biped垂直

    --biped_b.horizontal.controller  -- biped水平
    --biped_b.turning.controller
    --root= execute("$"+ "Root_Bip002")
    -----------------------------------biped垂直数值
    on btn_Bake pressed do
    (
        --xx = cT_root()
        if  bip_t.cT_biped() and bip_t.cT_root() then
        (
            --try
            --(
                undo "biped_move" on
                (
                    if Biped_transform.sel_vertical.Checked == true do --垂直
                    (
                        try
                        (
                            bip_t.biped_b =bip_t.biped_obj.transform.controller
                            bip_t.keys_z_num = bip_t.biped_b.vertical.controller.keys.count  --biped质心 上下轴动画帧数

                            bip_t.Ground_height = Biped_transform.Ground_floor.value --地板

                            local biped_z_strat=biped.getKey bip_t.biped_b.vertical.controller 1

                            for i=2 to bip_t.keys_z_num do --i = 2 开始 是因为第一帧不用处理
                            (
                                local biped_z_next_key = biped.getKey bip_t.biped_b.vertical.controller i

                                local next_key_time_z = (biped_z_next_key.time.frame) as integer
                                if biped_z_strat.z > 0 do
                                (
                                    if biped_z_next_key.z > biped_z_strat.z do
                                    (  --跳起来
                                        animate on
                                        (
                                            at time next_key_time_z
                                            (
                                                bip_t.root.pos.z = 0
                                                root_move_data_z = (biped_z_next_key.z) - (biped_z_strat.z)

                                                biped_z_next_key.z = biped_z_strat.z
                                                bip_t.root.pos.z = root_move_data_z
                                            )
                                        )
                                    )
                                    --------------------------------------
                                    if biped_z_next_key.z < biped_z_strat.z and biped_z_next_key.z > bip_t.Ground_height do
                                    ( --只是下蹲
                                        animate on
                                        (
                                            at time next_key_time_z(bip_t.root.pos.z = 0)
                                        )
                                    )
                                    ---------------------------------------
                                    if biped_z_next_key.z < bip_t.Ground_height do
                                    ( ---穿地板向下跳？
                                        animate on
                                        (
                                            at time next_key_time_z
                                            (
                                                bip_t.root.pos.z = 0
                                                root_move_data_z = (biped_z_next_key.z)-(biped_z_strat.z)
                                                biped_z_next_key.z = biped_z_strat.z
                                                bip_t.root.pos.z = root_move_data_z
                                            )
                                        )
                                    )
                                )
                            )
                        )catch(print "vertical 有问题")
                    )
                    ------------------------------------vertical.end
                    if Biped_transform.sel_horizontal_X.checked == true do
                    (

                        bip_t.keys_x_num = bip_t.biped_b.horizontal.controller.keys.count

                        local b_x_strat = biped.getKey bip_t.biped_b.horizontal.controller 1--bip_t.key_x[1]

                        for x=2 to bip_t.keys_x_num do
                        (
                            local b_x_up = biped.getKey bip_t.biped_b.horizontal.controller (x-1)

                            local b_x = biped.getKey bip_t.biped_b.horizontal.controller x

                            key_time = (b_x.time.frame) as integer
                            --if abs(b_x.x) > abs(b_h_strat.x + sel_xy.value) then (

                                    animate on
                                    (
                                        at time key_time
                                        (
                                            bip_t.root.pos.x = 0
                                            root_move_data_x = (b_x.x)-(b_x_strat.x)
                                            b_x.x = b_x_strat.x
                                            bip_t.root.pos.x = root_move_data
                                        )
                                    )

                            --)
                            --else (at time key_time root.pos.x = 0 )
                        )
                    )
                    ---------------------------------------------horizontal .x .end
                    if Biped_transform.sel_horizontal_Y.checked ==true do
                    (
                        try
                        (
                            bip_t.keys_y_num = bip_t.biped_b.horizontal.controller.keys.count --Y轴动画帧数
                            local b_y_strat = biped.getKey bip_t.biped_b.horizontal.controller 1 --获取第一帧
                            for i=2 to bip_t.keys_y_num do
                            (
                                local b_y = biped.getKey bip_t.biped_b.horizontal.controller i
                                key_time = (b_y.time.frame) as integer
                                --if abs(b_y.y) > abs(b_y_strat.y + sel_xy.value) then(
                                --if key_time < bip_t.do_end do (
                                    animate on
                                    (
                                        at time key_time
                                        (
                                            bip_t.root.pos.y = 0
                                            root_move_data_y = (b_y.y)-(b_y_strat.y)
                                            b_y.y = b_y_strat.y
                                            bip_t.root.pos.y = root_move_data_y
                                        )
                                    )
                                --)
                                --)
                                --else(at time key_time root.pos.y=0 )
                            )
                        )catch(print "horizontal_Y 有问题！！")
                    )
                )
            --)
           -- catch(print "BUG_btn_bake_001")
        )
        else (print "root 有问题！！")  ------------------------------------------ sel_horizontal_Y -- end
    )
) --rollout End
------------------------------------------------------------

rollout Bone_type "其他骨骼"
(
    button pick_v_hub "" width:170 height:21
    button pick_v_root "" width:170 height:21
    checkbox pick_x "X" across:4
    checkbox pick_y "Y"
    checkbox pick_z "Z"
    checkbox pick_mod "L" checked:true

    button do_win "Do" width:72 height:21

    spinner sel_start "头"  width:60 height:16 range:[-999999,999999,0] type:#integer tooltip:"" across:3 offset:[-10,0] enabled:false
    spinner sel_end "尾"  width:60 height:16 range:[-999999,999999,100] type:#integer tooltip:"" enabled:false
    button btn_leng  "距离"   width:40 height:21 offset:[12,0]


    --spinner app_start "头"  width:60 height:16 range:[-999999,999999,0] type:#integer tooltip:"" across:3 offset:[-10,0]
    --spinner app_end "尾"  width:60 height:16 range:[-999999,999999,100] type:#integer tooltip:""
    button app_start ""width:72 height:21 across:2
    button app_end ""width:72 height:21
    button do_leng  "" width:72 height:21 --offset:[12,0]


    global hub_t
    struct hub_ver
    (
        v_hub,
        v_root,
        move_leng,
        start_key_time,
        end_key_time,
        end_key_index,
        start_key_index
    )
    ----------------------------------------------
    fn add =
    (

        for i= 1 to (hub_t.end_key_index - hub_t.start_key_index) do
        (
            key_start = hub_t.v_hub[3][1].controller.keys[hub_t.start_key_index]
             hub_t.v_hub[3][1].controller.keys[hub_t.start_key_index+1]
        )
    )
    ----------------------------------------------
    ----------------------------------------------
    ----------------------------------------------
    fn hub_to_root a_hub b_root x_x =
    ( --a_hub ;b_root ; x_x xyz三轴之一
        if (a_hub[3][1].keys.count != 0) do --位移帧数不为 0
        (
            for i=2 to a_hub[3][1].keys.count do
            (
                local start_key = a_hub[3][1].keys[1]

                animate On
                (
                    t = (a_hub[3][1].keys[i].time.frame as integer)
                    (
                        at time t
                        (

                        )
                    )
                )
            )
        )
    )
    ----------------------------------------------

    ----------------------------------------------
    on app_end pressed do
    (
        hub_t.end_key_index = getKeyIndex hub_t.v_hub[3][1].controller sliderTime
        if hub_t.start_key_index != 0 do
        (
            Bone_type.app_end.text = (hub_t.end_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
        )
    )
    ----------------------------------------------
    on app_start pressed do
    (
        hub_t.start_key_index = getKeyIndex hub_t.v_hub[3][1].controller sliderTime
        if hub_t.start_key_index != 0 do
        (
            Bone_type.app_start.text = (hub_t.start_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
        )
    )
    ----------------------------------------------
    on pick_mod changed state do
    (
        Bone_type.sel_start.enabled = not (Bone_type.pick_mod.state)
        Bone_type.sel_end.enabled = not (Bone_type.pick_mod.state)
    )
    ----------------------------------------------
    on btn_leng pressed do
    (
        if Bone_type.pick_mod.checked do
        (
            hub_t.v_hub.pos.controller = tcb_position ()
            key_count = hub_t.v_hub[3][1].controller.keys.count
            key_start = hub_t.v_hub[3][1].controller.keys[1]
            key_end = hub_t.v_hub[3][1].controller.keys[key_count]


            hub_t.move_leng = key_end.value.x - key_start.value.x
            Bone_type.btn_leng.text = abs(hub_t.move_leng) as string
        )
    )
    ----------------------------------------------
    on pick_v_hub pressed do
    (
        if selection.count !=0 do
        (
             hub_t.v_hub = selection[1]
             pick_v_hub.text = hub_t.v_hub.name
        )
    )
    ----------------------------------------------
    on pick_v_root pressed do
    (
        if selection.count !=0 do
        (
             hub_t.v_root = selection[1]
             pick_v_root.text = hub_t.v_root.name
        )
    )
    ----------------------------------------------
    on do_win pressed do
    (
       -- Bone_type.sel_xyz.value
        hub_t.v_hub.pos.controller = tcb_position ()
        if Bone_type.pick_y.Checked == true do
        (
            key_count = hub_t.v_hub[3][1].controller.keys.count
            key_start = hub_t.v_hub[3][1].controller.keys[1]
            for i=2 to key_count do
            (
                up_key = hub_t.v_hub[3][1].controller.keys[i-1]
                the_key = hub_t.v_hub[3][1].controller.keys[i]
                animate on(
                    at time the_key.time
                    (
                        if abs(the_key.value.y - up_key.value.y) > Bone_type.sel_xyz.value then
                        (
                            hub_t.v_root.pos.y = the_key.value.y
                            the_key.value.y = key_start.value.y
                        )
                        else(
                            addNewKey hub_t.v_root[3][1] the_key.time
                            the_key.value.y = the_key.value.y - hub_t.v_root.pos.y
                        )
                    )
                )

            )

        )

        if Bone_type.pick_x.Checked == true do
        (
            key_count = hub_t.v_hub.pos.controller.keys.count
            key_start = hub_t.v_hub.pos.controller.keys[1]
            for i=2 to key_count do
            (
                up_key = hub_t.v_hub.pos.controller.keys[i-1]
                the_key = hub_t.v_hub.pos.controller.keys[i]
                animate on(
                    at time the_key.time
                    (
                        if abs(the_key.value.x - up_key.value.x) > Bone_type.sel_xyz.value then
                        (
                            hub_t.v_root.pos.x = the_key.value.x - key_start.value.x
                            the_key.value.x = key_start.value.x
                        )
                        else(
                            addNewKey hub_t.v_root.pos.controller the_key.time
                            the_key.value.x = the_key.value.x - hub_t.v_root.pos.x
                        )
                    )
                )

            )

        )
        hub_t.v_hub.pos.controller = Position_XYZ ()

    )
    ----------------------------------------------
    ----------------------------------------------
    ----------------------------------------------
    ----------------------------------------------
    ----------------------------------------------
)

------------------------------------------------------------
rollout about_inf "About"
(
    label lb_txt "请确保Biped，Root坐标" align:#center
    label lb_txt2 "和世界坐标朝向一致" align:#center
    label lab_dw "V1.1 by Joe -2017/10/9"
    hyperlink lbl_01 "更新" address:"https://github.com/4698to/Biped-Key-Tool" align:#Center
    button btn_about "?"
    on btn_about pressed do (
        messageBox (
                "Floor：地面，默认为 0 ，Sliding Key：将四肢的 IK 帧补满。Free Key:将四肢的IK帧转为 FK 帧 。"
            )
    )
)
thenewfloater = newRolloutFloater "Biped key Tool.v1.2" 200 320
addRollout Biped_transform thenewfloater
addRollout Bone_type thenewfloater
addRollout about_inf thenewfloater

hub_t = Bone_type.hub_ver()
bip_t = Biped_transform.bip_test()

about_inf.open = false
--createDialog Biped_transform