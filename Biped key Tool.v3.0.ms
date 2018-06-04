/*
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
*/
rollout Bone_type "其他 v_3.0"
(
    button pick_v_hub "" width:170 height:21
    button pick_v_root "" width:170 height:21
    /*checkbox pick_x "X" across:4
    checkbox pick_y "Y"
    checkbox pick_z "Z"
    */
    label a_line "——————————————————————" enabled:false
    radiobuttons pick_xyz "" labels:#("X",  "Y",  "Z") columns:3 across:3 offset:[12,0]
    checkbox pick_mod "L" checked:true offset:[37,0] tooltip:"模式切换"
    checkbox create_root "R" checked:true tooltip:"自动检查设置Root" offset:[16,0]
    label b_line "——————————————————————" enabled:false
    spinner Ground_floor "Floor" width:60 height:16 range:[-9999,9999,0] type:#float offset:[-65,0]

    button btn_ik_fk "IK FK" width:72 height:21 across:2
    button do_simple "Do" width:72 height:21 enabled:true tooltip:"操作前先存档"
    label c_line "——————————————————————" enabled:false
    --spinner sel_start "头"  width:60 height:16 range:[-999999,999999,0] type:#integer tooltip:"" across:3 offset:[-10,0] enabled:false
    --spinner sel_end "尾"  width:60 height:16 range:[-999999,999999,100] type:#integer tooltip:"" enabled:false


    --spinner app_start "头"  width:60 height:16 range:[-999999,999999,0] type:#integer tooltip:"" across:3 offset:[-10,0]
    --spinner app_end "尾"  width:60 height:16 range:[-999999,999999,100] type:#integer tooltip:""
    button app_start ""width:72 height:21 across:2 enabled:false tooltip:"设置作用域开始帧"
    button app_end ""width:72 height:21 enabled:false tooltip:"设置作用域结束帧"
    label d_line "——————————————————————" enabled:false
    button do_leng  "doo" width:72 height:21 enabled:false tooltip:"操作前先存档"--offset:[12,0] enabled:false


    global hub_t
    struct hub_ver
    (
        v_hub,
        v_root,
        move_leng_x,
        move_leng_y,
        move_leng_z,
        start_key_time,
        end_key_time,
        end_key_index,
        start_key_index,
        move_data = #(),
        move_data_b=#(),
        key_index_list,
        key_count,
        key_o,-- 计数
        keys_z_num,
        keys_x_num,
        keys_y_num,
        Ground_height,
        end_key_num,
        biped_l_leg,
        biped_r_leg,
        biped_l_arm,
        biped_r_arm,
        biped_tg,
        do_end,
        do_start,
        fn cT_root = --检查Root
        (
            try(
                if Bone_type.create_root.state then
                (
                    if hub_t.v_hub.parent == undefined then(
                        hub_t.v_root = point()
                        hub_t.v_root.name = "root_" + hub_t.v_hub.name
                        hub_t.v_hub.parent = hub_t.v_root
                        return true

                    )
                    else(return true)
                )
                else (
                    if hub_t.v_hub.parent == undefined then (
                        if queryBox "选择的Biped没有Root，是否创建？" then (
                            hub_t.v_root = point()
                            hub_t.v_root.name = "root_" + hub_t.v_root.name
                            hub_t.v_hub.parent = hub_t.v_root
                            return true
                        )
                        else (return false)
                    )
                    else (return true)
                )
            )
            catch(return false)
        ),
        fn cT_hub = --检查biped是否选取正常
        (
            try
            (
                hub_t.end_key_num = (animationRange.end.frame as integer)-(animationRange.start.frame as integer)

                if (not IsValidNode hub_t.v_hub) do (
                    try
                    (
                        hub_t.v_hub = execute("$"+Bone_type.pick_v_hub.text)
                    )catch(hub_t.v_hub = execute("$"+ "'"+Bone_type.pick_v_hub.text+"'"))
                )
                if (IsValidNode hub_t.v_hub) then (
                    if classOf hub_t.v_hub == Biped_Object do
                    (
                       -- biped_b = hub_t.v_hub.transform.controller
                        hub_t.biped_l_leg = biped.getNode hub_t.v_hub #lleg link:3
                        hub_t.biped_r_leg = biped.getNode hub_t.v_hub #rleg link:3
                        hub_t.biped_l_arm = biped.getNode hub_t.v_hub #larm link:4
                        hub_t.biped_r_arm = biped.getNode hub_t.v_hub #rarm link:4
                        hub_t.biped_tg = #(hub_t.biped_l_leg,hub_t.biped_r_leg,hub_t.biped_l_arm,hub_t.biped_r_arm)
                    )
                    return true
                )
                else(return false)
            )
            catch
            (
                messageBox "重新 Biped 和 Root 试试！"
                return false
            )
        )
    )
        fn biped_add_freekey biped_node_controller biped_node = -- 设置IK
        (
            for i=1 to hub_t.end_key_num do
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
        )
    -----------------------------------------------------
        fn biped_add_slidkey biped_node_controller = --设置FK
        (
            --hub_t.end_key_num = Biped_transform.end_key.value - Biped_transform.start_key.value
            for i=1 to (hub_t.end_key_num + 1) do (
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
        )


    -------------------------------------------------
    fn bip_do_simple =
    (
        if  hub_t.cT_hub() and hub_t.cT_root() then
        (
            --try
            --(
                --undo "biped_move" on

                    if Bone_type.pick_xyz.state ==3 do --垂直
                    (
                        try
                        (
                            --bip_t.biped_b = hub_t.v_hub.transform.controller
                            hub_t.keys_z_num = hub_t.v_hub.transform.controller.vertical.controller.keys.count  --biped质心 上下轴动画帧数

                            hub_t.Ground_height = Bone_type.Ground_floor.value --地板

                            local biped_z_strat=biped.getKey hub_t.v_hub.transform.controller.vertical.controller 1
                            undo "bip_vertical" on
                            (
                                for i=2 to hub_t.keys_z_num do --i = 2 开始 是因为第一帧不用处理
                                (
                                    local biped_z_next_key = biped.getKey hub_t.v_hub.transform.controller.vertical.controller i

                                    local next_key_time_z = (biped_z_next_key.time.frame) as integer
                                    if biped_z_strat.z > 0 do
                                    (
                                        if biped_z_next_key.z > biped_z_strat.z do
                                        (  --跳起来
                                            animate on
                                            (
                                                at time next_key_time_z
                                                (
                                                    hub_t.v_root.pos.z = 0
                                                    root_move_data_z = (biped_z_next_key.z) - (biped_z_strat.z)

                                                    biped_z_next_key.z = biped_z_strat.z
                                                    hub_t.v_root.pos.z = root_move_data_z
                                                )
                                            )
                                        )
                                        --------------------------------------
                                        if biped_z_next_key.z < biped_z_strat.z and biped_z_next_key.z > hub_t.Ground_height do
                                        ( --只是下蹲
                                            animate on
                                            (
                                                at time next_key_time_z(hub_t.v_root.pos.z = 0)
                                            )
                                        )
                                        ---------------------------------------
                                        if biped_z_next_key.z < hub_t.Ground_height do
                                        ( ---穿地板向下跳？
                                            animate on
                                            (
                                                at time next_key_time_z
                                                (
                                                    hub_t.v_root.pos.z = 0
                                                    root_move_data_z = (biped_z_next_key.z)-(biped_z_strat.z)
                                                    biped_z_next_key.z = biped_z_strat.z
                                                    hub_t.v_root.pos.z = root_move_data_z
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )catch(print "vertical 有问题")
                    )
                    ------------------------------------vertical.end
                    if Bone_type.pick_xyz.state ==1 do
                    (

                        hub_t.keys_x_num = hub_t.v_hub.transform.controller.horizontal.controller.keys.count

                        local b_x_strat = biped.getKey bhub_t.v_hub.transform.controller.horizontal.controller 1--bip_t.key_x[1]
                        undo "bip_horizontal_x" on
                        (
                            for x=2 to hub_t.keys_x_num do
                            (
                                local b_x_up = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller (x-1)

                                local b_x = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller x

                                key_time = (b_x.time.frame) as integer
                                --if abs(b_x.x) > abs(b_h_strat.x + sel_xy.value) then (

                                        animate on
                                        (
                                            at time key_time
                                            (
                                                hub_t.v_root.pos.x = 0
                                                root_move_data_x = (b_x.x)-(b_x_strat.x)
                                                b_x.x = b_x_strat.x
                                                hub_t.v_root.pos.x = root_move_data
                                            )
                                        )

                                --)
                                --else (at time key_time root.pos.x = 0 )
                            )
                        )
                    )
                    ---------------------------------------------horizontal .x .end
                    if Bone_type.pick_xyz.state ==2 do
                    (
                        try
                        (
                            hub_t.keys_y_num = hub_t.v_hub.transform.controller.horizontal.controller.keys.count --Y轴动画帧数
                            local b_y_strat = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller 1 --获取第一帧
                            undo "bip_horizontal_y" on
                            (
                                for i=2 to hub_t.keys_y_num do
                                (
                                    local b_y = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller i
                                    key_time = (b_y.time.frame) as integer
                                    animate on
                                    (
                                        at time key_time
                                        (
                                            hub_t.v_root.pos.y = 0
                                            root_move_data_y = (b_y.y)-(b_y_strat.y)
                                            b_y.y = b_y_strat.y
                                            hub_t.v_root.pos.y = root_move_data_y
                                        )
                                    )
                                )
                            )
                        )catch(print "horizontal_Y 有问题！！")
                    )

            --)
           -- catch(print "BUG_btn_bake_001")
        )
        else (print "root 有问题！！")  ------------------------------------------ sel_horizontal_Y -- end
    )
    -------------------------------------------------
    fn chk_UI =
    (
        --Bone_type.sel_start.enabled = not (Bone_type.pick_mod.state)
        --Bone_type.sel_end.enabled = not (Bone_type.pick_mod.state)
        --Bone_type.btn_leng.enabled = not (Bone_type.pick_mod.state)
        if Bone_type.pick_mod.state then
        (
            Bone_type.do_simple.enabled = true
            Bone_type.do_leng.enabled = false
            Bone_type.app_start.enabled = false
            Bone_type.app_end.enabled = false
        )
        else(
            Bone_type.do_simple.enabled =  false
            Bone_type.do_leng.enabled = true
            Bone_type.app_start.enabled = true
            Bone_type.app_end.enabled = true
        )
        case of
        (
            (Bone_type.pick_xyz.state ==1 and Bone_type.pick_mod.state == false):(Bone_type.do_leng.enabled = true)
            (Bone_type.pick_xyz.state ==2 and Bone_type.pick_mod.state == false):(Bone_type.do_leng.enabled = true)
            (Bone_type.pick_xyz.state ==3 and Bone_type.pick_mod.state == false):(Bone_type.do_leng.enabled = true)
        )



    )
    fn ad_mod =
    (
        if Bone_type.pick_mod.checked do
        (
            if classOf hub_t.v_hub == Biped_Object then
            (
                if Bone_type.pick_xyz.state ==3 then
                (
                    hub_t.key_count = hub_t.v_hub.transform.controller.vertical.controller.keys.count
                    key_start = biped.getKey hub_t.v_hub.transform.controller.vertical.controller 1
                    key_end = biped.getKey hub_t.v_hub.transform.controller.vertical.controller (hub_t.key_count)

                    --hub_t.bip_end_key_index = getKeyIndex hub_t.v_hub.transform.controller.vertical.controller sliderTime
                )
                else
                (
                    hub_t.key_count = hub_t.v_hub.transform.controller.horizontal.controller.keys.count
                    key_start = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller 1
                    key_end = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller (hub_t.key_count)
                    hub_t.move_leng_x = key_end.x - key_start.x
                    hub_t.move_leng_y = key_end.y - key_start.y
                )
            )
            else
            (
                hub_t.v_hub.pos.controller = tcb_position ()
                hub_t.key_count = hub_t.v_hub[3][1].controller.keys.count
                key_start = hub_t.v_hub[3][1].controller.keys[1]
                key_end = hub_t.v_hub[3][1].controller.keys[hub_t.key_count]

                hub_t.move_leng_x = key_end.value.x - key_start.value.x
                hub_t.move_leng_y = key_end.value.y - key_start.value.y
                hub_t.move_leng_z = key_end.value.z - key_start.value.z
                Bone_type.btn_leng.text = abs(hub_t.move_leng_x) as string
            )
        )
    )
    ----------------------------------------------
    fn add_move_width =
    (
        struct move_leng_width (
            time,
            index,
            width,
            hub_x,
            root_x,
            hub_y,
            root_y,
            hub_z,
            root_z
        )
        hub_t.move_data = #()
        hub_t.key_index_list = #{hub_t.start_key_index..hub_t.end_key_index} -- 作用域 帧
        --hub_t.key_index_list = #{0..hub_t.end_key_index}
        move_value_x = 0.0
        move_value_y = 0.0
        move_value_z = 0.0
        for i in hub_t.key_index_list do --计算作用域部分
        (
            tem_move_data = move_leng_width()
            if i == hub_t.end_key_index do exit --continue
            key_start = hub_t.v_hub[3][1].controller.keys[i]
            key_next = hub_t.v_hub[3][1].controller.keys[i+1]
            tem_move_data.index = i+1
            tem_move_data.time = key_next.time

            if Bone_type.pick_xyz.state == 1 do  --X 轴
            (
               --tem_move_data.width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)  --平均分配位移
               --move_value_x += tem_move_data.width * hub_t.move_leng_x /100.0
                width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)
                move_value_x += width * hub_t.move_leng_x /100.0

                tem_move_data.hub_x = key_next.value.x - move_value_x
                tem_move_data.root_x = move_value_x
               --tem_move_data.width = (key_next.value.x - key_start.value.x)/hub_t.move_leng_x
            )
            if Bone_type.pick_xyz.state == 2 do
            (
                width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)
                move_value_y += width * hub_t.move_leng_y /100.0
                tem_move_data.hub_y = key_next.value.y - move_value_y
                tem_move_data.root_y = move_value_y
            )
            if Bone_type.pick_xyz.state == 3 do
            (
                width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)
                move_value_z += width * hub_t.move_leng_z /100.0
                tem_move_data.hub_z = key_next.value.z - move_value_z
                tem_move_data.root_z = move_value_z
            )
            append hub_t.move_data tem_move_data
        )
        hub_t.move_data_b = #()
        for y = (hub_t.end_key_index+1) to hub_t.key_count do
        (
            tem_move_data = move_leng_width()
            --if y == hub_t.key_count do exit --continue
            the_key = hub_t.v_hub[3][1].controller.keys[y]
            --key_next = hub_t.v_hub[3][1].controller.keys[i+1]
            tem_move_data.index = y
            tem_move_data.time = the_key.time

            if Bone_type.pick_xyz.state == 1 do
            (
                tem_move_data.hub_x = the_key.value.x - move_value_x
                tem_move_data.root_x = move_value_x
            )
            if Bone_type.pick_xyz.state == 2 do
            (
                tem_move_data.hub_y = the_key.value.y - move_value_y
                tem_move_data.root_y = move_value_y
            )
            if Bone_type.pick_xyz.state == 3 do
            (
                tem_move_data.hub_z = the_key.value.z - move_value_z
                tem_move_data.root_z = move_value_z
            )
            append hub_t.move_data_b tem_move_data

        )

    )
    -------------------------------------------
    fn bip_add_move_width_vertical =
    (
        struct move_leng_width (
            time,
            index,
            hub_z,
            root_z
            --width,
            --hub_x,
            --root_x,
            --hub_y,
            --root_y,
        )
        hub_t.move_data = #()
        hub_t.key_index_list = #{hub_t.start_key_index..hub_t.end_key_index} -- 作用域 帧
        --hub_t.key_index_list = #{0..hub_t.end_key_index}
        --move_value_x = 0.0
        --move_value_y = 0.0
        move_value_z = 0.0
        move_height = 0
        -----------------------------------------------------------------------------------
        vertical_z = #()
        for b in hub_t.key_index_list do
        (
            the_key = biped.getKey hub_t.v_hub.transform.controller.vertical.controller b
            append vertical_z the_key.z--(abs(the_key.z))
        )
        move_height = amax vertical_z --最高点
        ----------------------------------------------------------------------------------------
        for i in hub_t.key_index_list do --计算作用域部分
        (
            tem_move_data = move_leng_width()
            if i == hub_t.end_key_index do exit--continue

            key_start = biped.getKey hub_t.v_hub.transform.controller.vertical.controller hub_t.start_key_index
            key_next = biped.getKey hub_t.v_hub.transform.controller.vertical.controller (i+1)
            tem_move_data.index = i+1
            tem_move_data.time = key_next.time
            if key_next.z > key_start.z do tem_move_data.hub_z = key_start.z;tem_move_data.root_z = key_next.z - key_start.z

            if key_next.z < key_start.z do tem_move_data.hub_z = key_next.z

            --print (move_value_z as string)
            --width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)

            --move_value_x += width * hub_t.move_leng_x /100.0
            --move_value_y += width * hub_t.move_leng_y /100.0
            --tem_move_data.hub_z = move_value_z
            --tem_move_data.root_z = key_next.z - move_value_z

            append hub_t.move_data tem_move_data
        )
        /*
        hub_t.move_data_b = #()
        for y = (hub_t.end_key_index+1) to hub_t.key_count do  --计算作用域后部分
        (
            tem_move_data = move_leng_width()
            --if y == hub_t.key_count do exit --continue
            the_key = biped.getKey hub_t.v_hub.transform.controller.vertical.controller y
            tem_move_data.index = y
            tem_move_data.time = the_key.time
            tem_move_data.hub_z = the_key.z - move_value_z
            tem_move_data.root_z = move_value_z
            append hub_t.move_data_b tem_move_data
        )
        */

    )
    -------------------------------------------
    fn bip_app_frame_value_vertical =
    (
        hub_t.key_o = 0
        /*
        for p=1 to hub_t.start_key_index do --作用域前部分
        (

            --the_key = biped.getKey hub_t.v_hub.transform.controller.vertical.controller p
            --addNewKey hub_t.v_root.pos.controller the_key.time

        )
        */
        for i in hub_t.key_index_list do --作用域部分
        (
            hub_t.key_o+=1
            if hub_t.key_o == (hub_t.end_key_index - hub_t.start_key_index ) do exit --continue
            if i ==  hub_t.end_key_index do exit

            key_next = biped.getKey hub_t.v_hub.transform.controller.vertical.controller (i+1)
            animate On (
                at time key_next.time
                (
                    key_next.z = hub_t.move_data[hub_t.key_o].hub_z

                    --try (hub_t.v_root.pos.z = hub_t.move_data[hub_t.key_o].root_z)catch()

                )
            )
        )
        --hub_t.key_o = 0
        --key_count = hub_t.v_hub[3][1].controller.keys.count
        /*
        for y = (hub_t.end_key_index+1) to hub_t.key_count do  --作用域后部分
        (
            the_key = biped.getKey hub_t.v_hub.transform.controller.vertical.controller y
            hub_t.key_o += 1
            animate On (
                at time the_key.time
                (
                    --the_key.y = hub_t.move_data_b[hub_t.key_o].hub_y
                    --hub_t.v_root.pos.y = hub_t.move_data_b[hub_t.key_o].root_y
                )
            )
        )
        */
    )
    -------------------------------------------
    fn bip_add_move_width_horizontal =
    (
        struct move_leng_width (
            time,
            index,
            width,
            hub_x,
            root_x,
            hub_y,
            root_y
            --hub_z,
            --root_z
        )
        hub_t.move_data = #()
        hub_t.key_index_list = #{hub_t.start_key_index..hub_t.end_key_index} -- 作用域 帧
        --hub_t.key_index_list = #{0..hub_t.end_key_index}
        move_value_x = 0.0
        move_value_y = 0.0
        --move_value_z = 0.0
        for i in hub_t.key_index_list do --计算作用域部分
        (
            tem_move_data = move_leng_width()
            if i == hub_t.end_key_index do exit--continue

            key_start = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller i
            key_next = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller (i+1)
            tem_move_data.index = i+1
            tem_move_data.time = key_next.time

            width = 100.0 /((hub_t.end_key_index - hub_t.start_key_index ) as float)

            move_value_x += width * hub_t.move_leng_x /100.0
            move_value_y += width * hub_t.move_leng_y /100.0
            print move_value_x as string
            tem_move_data.hub_x = key_next.x - move_value_x
            tem_move_data.root_x = move_value_x

            tem_move_data.hub_y = key_next.y - move_value_y
            tem_move_data.root_y = move_value_y

            append hub_t.move_data tem_move_data
        )

        hub_t.move_data_b = #()
        for y = (hub_t.end_key_index+1) to hub_t.key_count do  --计算作用域后部分
        (
            tem_move_data = move_leng_width()
            --if y == hub_t.key_count do exit --continue
            the_key = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller y
            tem_move_data.index = y
            tem_move_data.time = the_key.time
            tem_move_data.hub_x = the_key.x - move_value_x
            tem_move_data.root_x = move_value_x
            tem_move_data.hub_y = the_key.y - move_value_y
            tem_move_data.root_y = move_value_y

            append hub_t.move_data_b tem_move_data
        )

    )
    ----------------------------------------------
    fn bip_app_frame_value_horizontal =
    (
        hub_t.key_o = 0
        for p=1 to hub_t.start_key_index do --作用域前部分
        (

            the_key = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller p
            --addNewKey hub_t.v_root.pos.controller the_key.time

        )
        for i in hub_t.key_index_list do --作用域部分
        (
            hub_t.key_o+=1
            if hub_t.key_o > (hub_t.end_key_index - hub_t.start_key_index ) do exit --continue
            if i ==  hub_t.end_key_index do exit

            key_next = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller (i+1)
            animate On (
                at time key_next.time
                (
                    if Bone_type.pick_xyz.state == 1 do
                    (
                        key_next.x = hub_t.move_data[hub_t.key_o].hub_x
                        --hub_t.v_root.pos.x = hub_t.move_data[hub_t.key_o].root_x
                    )
                    if Bone_type.pick_xyz.state == 2 do
                    (
                        key_next.y = hub_t.move_data[hub_t.key_o].hub_y
                        --hub_t.v_root.pos.y = hub_t.move_data[hub_t.key_o].root_y
                    )
                    /*
                    if Bone_type.pick_xyz.state == 3 do
                    (
                        key_next.value.z = hub_t.move_data[hub_t.key_o].hub_z
                        hub_t.v_root.pos.z = hub_t.move_data[hub_t.key_o].root_z
                    )
                    */
                )
            )
        )
        hub_t.key_o = 0
        --key_count = hub_t.v_hub[3][1].controller.keys.count
        for y = (hub_t.end_key_index+1) to hub_t.key_count do  --作用域后部分
        (
            the_key = biped.getKey hub_t.v_hub.transform.controller.horizontal.controller y
            hub_t.key_o += 1
            animate On (
                at time the_key.time
                (
                    if Bone_type.pick_xyz.state ==1 do
                    (   try (
                            the_key.x = hub_t.move_data_b[hub_t.key_o].hub_x
                            --hub_t.v_root.pos.x = hub_t.move_data_b[hub_t.key_o].root_x
                            --addNewKey hub_t.v_root.pos.controller the_key.time
                        )catch()
                    )
                    if Bone_type.pick_xyz.state ==2 do
                    (
                        the_key.y = hub_t.move_data_b[hub_t.key_o].hub_y
                        --hub_t.v_root.pos.y = hub_t.move_data_b[hub_t.key_o].root_y
                    )
                    /*
                    if Bone_type.pick_xyz.state ==3 do
                    (
                        the_key.value.z = hub_t.move_data_b[hub_t.key_o].hub_z
                        hub_t.v_root.pos.z = hub_t.move_data_b[hub_t.key_o].root_z
                    )
                    */
                )
            )
        )
    )
    ----------------------------------------------
    fn app_frame_value =
    (
        hub_t.key_o = 0
        for p=1 to hub_t.start_key_index do --作用域前部分
        (
            the_key = hub_t.v_hub[3][1].controller.keys[p]
            addNewKey hub_t.v_root.pos.controller the_key.time
        )
        for i in hub_t.key_index_list do --作用域部分
        (
            hub_t.key_o+=1
            if hub_t.key_o > (hub_t.end_key_index - hub_t.start_key_index ) do exit --continue
            if i ==  hub_t.end_key_index do exit
            key_next = hub_t.v_hub[3][1].controller.keys[i+1]
            animate On (
                at time key_next.time(
                    if Bone_type.pick_xyz.state == 1 do
                    (
                        key_next.value.x = hub_t.move_data[hub_t.key_o].hub_x
                        hub_t.v_root.pos.x = hub_t.move_data[hub_t.key_o].root_x
                    )
                    if Bone_type.pick_xyz.state == 2 do
                    (
                        key_next.value.y = hub_t.move_data[hub_t.key_o].hub_y
                        hub_t.v_root.pos.y = hub_t.move_data[hub_t.key_o].root_y
                    )
                    if Bone_type.pick_xyz.state == 3 do
                    (
                        key_next.value.z = hub_t.move_data[hub_t.key_o].hub_z
                        hub_t.v_root.pos.z = hub_t.move_data[hub_t.key_o].root_z
                    )
                )
            )
        )
        hub_t.key_o = 0
        --key_count = hub_t.v_hub[3][1].controller.keys.count
        for y = (hub_t.end_key_index+1) to hub_t.key_count do  --作用域后部分
        (
            the_key = hub_t.v_hub[3][1].controller.keys[y]
            hub_t.key_o += 1
            animate On (
                at time the_key.time
                (
                    if Bone_type.pick_xyz.state ==1 do
                    (   try (
                            the_key.value.x = hub_t.move_data_b[hub_t.key_o].hub_x
                            hub_t.v_root.pos.x = hub_t.move_data_b[hub_t.key_o].root_x
                            --addNewKey hub_t.v_root.pos.controller the_key.time
                        )catch()
                    )
                    if Bone_type.pick_xyz.state ==2 do
                    (
                        the_key.value.y = hub_t.move_data_b[hub_t.key_o].hub_y
                        hub_t.v_root.pos.y = hub_t.move_data_b[hub_t.key_o].root_y
                    )
                    if Bone_type.pick_xyz.state ==3 do
                    (
                        the_key.value.z = hub_t.move_data_b[hub_t.key_o].hub_z
                        hub_t.v_root.pos.z = hub_t.move_data_b[hub_t.key_o].root_z
                    )
                )
            )
        )
    )
    ----------------------------------------------
    ----------------------------------------------
    on btn_ik_fk pressed do
    (
        if hub_t.cT_hub() do
        (
            for i in hub_t.biped_tg do
            (
                local biped_fr = i.transform.controller
                biped_add_slidkey biped_fr
            )

            for o in hub_t.biped_tg do (
                local biped_fr = i.transform.controller
                biped_add_freekey biped_fr o
            )
        )
    )
    ----------------------------------------------
    on do_leng pressed do
    (
        if hub_t.cT_hub() and hub_t.cT_root() do
        (
            if classOf hub_t.v_hub == Biped_Object then
            (
                if Bone_type.pick_xyz.state ==3 then
                (
                    bip_add_move_width_vertical();bip_app_frame_value_vertical()
                )
                else(
                    bip_add_move_width_horizontal();bip_app_frame_value_horizontal()
                )
            )
            else(
                add_move_width();app_frame_value()
            )
        )
    )
    ----------------------------------------------
    on app_end pressed do
    (
        if hub_t.cT_hub() and hub_t.cT_root() do
        (
            ad_mod()
            if classOf hub_t.v_hub == Biped_Object then
            (
                if Bone_type.pick_xyz.state ==3 then
                (
                    --biped_b = hub_t.v_hub.transform.controller
                    --keys_z_num = hub_t.v_hub.transform.controller.vertical.controller.keys.count

                    hub_t.end_key_index = getKeyIndex hub_t.v_hub.transform.controller.vertical.controller sliderTime
                    if hub_t.end_key_index != 0 do
                    (
                        Bone_type.app_end.text = (hub_t.end_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                    )
                )
                else
                (
                    hub_t.end_key_index = getKeyIndex hub_t.v_hub.transform.controller.horizontal.controller sliderTime
                    if hub_t.end_key_index != 0 do
                    (
                        Bone_type.app_end.text = (hub_t.end_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                    )
                )
            )
            else
            (
                hub_t.end_key_index = getKeyIndex hub_t.v_hub[3][1].controller sliderTime
                if hub_t.end_key_index != 0 do
                (
                    Bone_type.app_end.text = (hub_t.end_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                )
            )
        )
    )
    ----------------------------------------------
    on app_start pressed do
    (
        if hub_t.cT_hub() and hub_t.cT_root()  do
        (
            ad_mod()
            if classOf hub_t.v_hub == Biped_Object then
            (
                if Bone_type.pick_xyz.state == 3 then
                (
                    hub_t.start_key_index = getKeyIndex hub_t.v_hub.transform.controller.vertical.controller sliderTime
                    if hub_t.start_key_index != 0 do
                    (
                        Bone_type.app_start.text = (hub_t.start_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                    )
                )
                else(
                    hub_t.start_key_index = getKeyIndex hub_t.v_hub.transform.controller.horizontal.controller sliderTime
                    if hub_t.start_key_index != 0 do
                    (
                        Bone_type.app_start.text = (hub_t.start_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                    )
                )
            )
            else(
                hub_t.v_hub.pos.controller = tcb_position ()
                hub_t.start_key_index = getKeyIndex hub_t.v_hub[3][1].controller sliderTime
                if hub_t.start_key_index != 0 do
                (
                    Bone_type.app_start.text = (hub_t.start_key_index as string) + ":"+ ((sliderTime.frame as integer) as string)
                )
            )
        )
    )
    ----------------------------------------------
    on pick_mod changed state do
    (
        chk_UI()
        if hub_t.cT_hub() and hub_t.cT_root() do(ad_mod())
    )
    on pick_xyz changed state do
    (
        chk_UI()
        if hub_t.cT_hub() and hub_t.cT_root() do(ad_mod())
    )

    ----------------------------------------------

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
    on do_simple pressed do
    (
       -- Bone_type.sel_xyz.value
        if hub_t.cT_hub() and hub_t.cT_root() do
        (
            if classOf hub_t.v_hub == Biped_Object then
            (
                bip_do_simple()
            )
            else
            (
                hub_t.v_hub.pos.controller = tcb_position ()
                if Bone_type.pick_xyz.state ==2 do
                (
                    if classOf hub_t.v_hub == Biped_Object then
                    (

                    )
                    else
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
                )

                if Bone_type.pick_xyz.state == 1 do
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
        )

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
thenewfloater = newRolloutFloater "Biped key Tool.v_3.0" 200 320
--addRollout Biped_transform thenewfloater
addRollout Bone_type thenewfloater
addRollout about_inf thenewfloater

hub_t = Bone_type.hub_ver()
bip_t = Biped_transform.bip_test()

about_inf.open = false
--createDialog Biped_transform