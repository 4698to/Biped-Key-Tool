key_x =#()
fn get_biped_move x_y_z =
( --biped_obj biped对象;x_y_z 分别为 1,2,3
    case of (
        (x_y_z == 1):(
            bip_t.keys_x_num = bip_t.biped_b.horizontal.controller.keys.count
            for x=2 to bip_t.keys_x_num do
            (
                local b_x_up = biped.getKey bip_t.biped_b.horizontal.controller (x-1)

                local b_x = biped.getKey bip_t.biped_b.horizontal.controller x

                key_time = (b_x.time.frame) as integer

                if abs(b_x.x - b_x_up.x) > Biped_transform.sel_xy.value do
                (
                    append key_x x
                )
            )
        )
        (x_y_z == 2):()
        (x_y_z == 3):()
    )
)

fn get_biped_move_max_X =
(
    if key_x.count != 0 do
    (
        local b_x_a = biped.getKey bip_t.biped_b.horizontal.controller key_b[1]
        local b_x_b = biped.getKey bip_t.biped_b.horizontal.controller key_b[(key_b.count)]

    )
)