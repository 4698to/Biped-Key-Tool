rollout Biped_transform "Biped key Tool.v1.1"
(
    global biped_obj = undefined
    local biped_b = undefined
    global root = undefined
    local keys_num = undefined
    local end_key_num = undefined
    local biped_les = #()
    local b_h_strat = undefined
    local b_h_xy =undefined
    local biped_tg = undefined


    GroupBox grp_01 "Select" pos:[1,8] width:184 height:76
    pickbutton pick_biped "Biped" pos:[8,24] width:50 height:21
    button btn_biped "" pos:[64,24] width:110 height:21
    pickbutton pick_root "Root" pos:[8,56] width:50 height:21
    button btn_root "" pos:[64,56] width:110 height:21
    -------------------------------------------------------------
    GroupBox grp_02 "Biped" pos:[1,96] width:184 height:159
    checkbox sel_vertical "Z" pos:[8,112] width:24 height:15


    button btn_Bake "Do" pos:[101,218] width:74 height:21
    button btn_bake_Ik "Sliding Key" pos:[10,189] width:72 height:21


    checkbox sel_horizontal_Y "Y" pos:[68,112] width:24 height:15 checked:true
    checkbox sel_horizontal_X "X" pos:[38,112] width:24 height:15
    checkbox create_root "Root" pos:[98,112] width:50 height:15 checked:true
    spinner Ground_floor "" pos:[38,136] width:48 height:16 range:[-9999,9999,0] type:#float


    label lbl1 "Floor" pos:[8,136] width:24 height:16
    spinner sel_xy "" pos:[127,136] width:48 height:16 enabled:false
    label lbl2 "X Y" pos:[101,136] width:20 height:16 enabled:false
    spinner end_key "" range:[-99999,99999,(animationRange.end.frame as integer)] type:#integer pos:[128,160] width:48 height:16 enabled:false
    spinner start_key "" range:[-99999,99999,(animationRange.start.frame as integer)] type:#integer pos:[38,160] width:48 height:16 enabled:false--range:[0,100,0]
    label lbl4 "Start" pos:[8,160] width:24 height:16
    label lbl5 "End" pos:[101,160] width:20 height:16
    button btn_bake_Fk "Free Key" pos:[10,218] width:72 height:21





    ---------------------------------------------------------------
    fn biped_add_freekey biped_node_controller biped_node =
    (
        for i=1 to end_key_num do(
            try(
                the_key = biped.getKey biped_node_controller i
                the_key_time = (the_key.time.frame as integer)
            )
            catch (continue)
            t=the_key_time
            sliderTime= t
            biped.setFreeKey biped_node

        )
    )
    /*
    biped_add_freekey  biped_fr biped_l_leg
     */
    -----------------------------------------------------
    fn biped_add_slidkey biped_node_controller =
    (
        end_key_num = end_key.value - start_key.value
        for i=1 to (end_key_num + 1) do (
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
    /*

    biped_l_leg = biped.getNode biped_obj #rleg  link:3

    biped_fr=biped_l_leg.transform.controller

    biped_add_slidkey biped_fr
     */
    -------------------------------------------
    fn cT_root =
    (
        try(
            if Biped_transform.create_root.checked == true then (
                if biped_obj.parent == undefined then(
                    root = point()
                    root.name = "root_" + biped_obj.name
                    biped_obj.parent = root
                    return true

                )
                else(return true)
            )
            else (
                if biped_obj.parent == undefined then (
                    if queryBox "选择的Biped没有Root，是否创建？" then (
                        root = point()
                        root.name = "root_" + biped_obj.name
                        biped_obj.parent = root
                        return true
                    )
                    else (return false)
                )
                else (return true)
            )
        )
        catch(return false)
    )

    fn cT_biped = (
        try(
            end_key_num = (animationRange.end.frame as integer)-(animationRange.start.frame as integer)
            biped_obj = execute("$"+btn_biped.text)
            biped_b =biped_obj.transform.controller
            biped_l_leg = biped.getNode biped_obj #lleg link:3
            biped_r_leg = biped.getNode biped_obj #rleg link:3
            biped_l_arm = biped.getNode biped_obj #larm link:4
            biped_r_arm = biped.getNode biped_obj #rarm link:4
            biped_tg = #(biped_l_leg,biped_r_leg,biped_l_arm,biped_r_arm)

            root = execute("$"+btn_root.text)
            return true
        )
        catch (
            messageBox "重新 Biped 和 Root 试试！"
            return false
            )


    )
    -------------------------------------UI pressed
    on pick_biped picked obj do (
        biped_obj = obj
        biped_b =biped_obj.transform.controller
        btn_biped.text = biped_obj.name
    )

    on btn_biped pressed do (
        try (
            select biped_obj
        )
        catch(
            biped_obj = execute("$"+btn_biped.text)
            select biped_obj
        )
    )

    on pick_root picked obj do (
        root = obj
        btn_root.text = root.name
        root.pos.controller = tcb_position ()
        if biped_obj.parent != root do (
            if queryBox "Root和Biped好像没连接！是否连接？" do (biped_obj.parent = root )
        )
    )

    on btn_root pressed do (
        try (
            select root
        )
        catch (
            root = execute("$"+btn_root.text)
            select root
        )

    )

    on start_key changed val do (
        if start_key.value != end_key.value then (
            end_key_num = end_key.value - start_key.value
        )
        else (
            end_key.value = start_key.value +1
            end_key_num = end_key.value - start_key.value
            )
    )

    on end_key changed val do (
        if start_key.value != end_key.value then (
            end_key_num = end_key.value - start_key.value
        )
        else (
            end_key.value = start_key.value +1
            end_key_num = end_key.value - start_key.value
            )
    )

    on btn_bake_Fk pressed do (

        try (
            cT_biped()
            for i in biped_tg do (
                biped_fr=i.transform.controller
                biped_add_freekey biped_fr i
            )
        )
        catch(print"FK_bug")
    )

    on btn_bake_Ik pressed do (
        try (

            cT_biped()
            for i in biped_tg do (
                print i
                biped_fr=i.transform.controller

                biped_add_slidkey biped_fr
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
    on btn_Bake pressed do (
        --xx = cT_root()
        if cT_root() then (
            try (

                biped_obj = execute("$"+btn_biped.text)
                root = execute("$"+btn_root.text)

                if sel_vertical.Checked == true do(
                    biped_b =biped_obj.transform.controller
                    keys_num = biped_b.vertical.controller.keys.count
                    Ground_height = Ground_floor.value --地板
                    for i=2 to keys_num do(

                        biped_z_strat=biped.getKey biped_b.vertical.controller 1

                        biped_z_next_key = biped.getKey biped_b.vertical.controller i

                        next_key_time_z = (biped_z_next_key.time.frame) as integer
                        if biped_z_strat.z > 0 do (
                            if biped_z_next_key.z > biped_z_strat.z do (  --跳起来
                                animate on
                                (
                                    at time next_key_time_z
                                    (
                                        root.pos.z = 0
                                        root_move_data_z = (biped_z_next_key.z) - (biped_z_strat.z)

                                        biped_z_next_key.z = biped_z_strat.z
                                        root.pos.z = root_move_data_z
                                    )
                                )
                            )
                            --------------------------------------
                            if biped_z_next_key.z < biped_z_strat.z and biped_z_next_key.z > Ground_height do ( --只是下蹲
                                animate on
                                (
                                    at time next_key_time_z(root.pos.z = 0)
                                )
                            )
                            ---------------------------------------
                            if biped_z_next_key.z < Ground_height do ( ---穿地板向下跳？
                                animate on
                                (
                                    at time next_key_time_z
                                    (
                                        root.pos.z = 0
                                        root_move_data_z = (biped_z_next_key.z)-(biped_z_strat.z)
                                        biped_z_next_key.z = biped_z_strat.z
                                        root.pos.z = root_move_data_z
                                    )
                                )
                            )
                        )
                    )
                )
                ------------------------------------vertical.end
                if sel_horizontal_X.checked == true do (
                    keys_h_num = biped_b.horizontal.controller.keys.count
                    b_h_strat = biped.getKey biped_b.horizontal.controller 1
                    for x=2 to keys_h_num do (

                        b_h_xy = biped.getKey biped_b.horizontal.controller x
                        key_time = (b_h_xy.time.frame) as integer

                        --if abs(b_h_xy.x) > abs(b_h_strat.x + sel_xy.value) then (
                                animate on (
                                    at time key_time(
                                        root.pos.x = 0
                                        root_move_data_x = (b_h_xy.x)-(b_h_strat.x)
                                        b_h_xy.x = b_h_strat.x
                                        root.pos.x = root_move_data_x
                                    )
                                )
                        --)
                        --else (at time key_time root.pos.x = 0 )
                    )
                )
                ---------------------------------------------horizontal .x .end
                if sel_horizontal_Y.checked ==true do(
                    keys_h_num = biped_b.horizontal.controller.keys.count
                    b_h_strat = biped.getKey biped_b.horizontal.controller 1
                    for i=2 to keys_h_num do (
                        b_h_xy = biped.getKey biped_b.horizontal.controller i
                        key_time = (b_h_xy.time.frame) as integer
                        --if abs(b_h_xy.y) > abs(b_h_strat.y + sel_xy.value) then(
                            animate on (
                                at time key_time (
                                    root.pos.y = 0
                                    root_move_data_y = (b_h_xy.y)-(b_h_strat.y)

                                    b_h_xy.y = b_h_strat.y

                                    root.pos.y = root_move_data_y
                                )
                            )
                        --)
                        --else(at time key_time root.pos.y=0 )
                    )
                )
            )
            catch(print "肯定是有问题的！！")
        )
        else (print "root 有问题！！")  ------------------------------------------ sel_horizontal_Y -- end
    )
)
------------------------------------------------------------
rollout about_inf "About"
(
    label lb_txt "请确保Biped，Root坐标" align:#center
    label lb_txt2 "和世界坐标朝向一致" align:#center
    label lb_txt4 "反馈：99U-199505"
    label lb_txt3 "Mail:738746223@qq.com" align:#center
    button btn_baout "?"
    on btn_baout pressed do (
        messageBox (
                "Floor：地面，默认为 0 ，Sliding Key：将四肢的 IK 帧补满。Free Key:将四肢的IK帧转为 FK 帧 。"
            )
    )
)
thenewfloater = newRolloutFloater "Biped key Tool.v1" 200 320
addRollout Biped_transform thenewfloater
addRollout about_inf thenewfloater
about_inf.open = false
--createDialog Biped_transform