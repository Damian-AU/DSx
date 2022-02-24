package provide DSx_functions $::DSx_settings(version)

package require lambda


# Check if adjustment should be made for the 2020-03 changes to core
# Once a reasonable transitional period elapses, this could be replaced
# by a set of `package require` statements and catch/try with messaging
# that upgrading the de1app is needed.
# These versions should not need to be updated, unless newer features are used.

namespace eval ::skin::dsx {

	if { [catch { package require de1_logging }] } {

		rename ::msg ::skin::dsx::msg_orig
		proc ::msg {args} {

			::skin::dsx::msg_orig [join $args]
		}
	}

	variable use_event_system [ package vsatisfies [package version de1app] 1.34.26- ]

	if { $use_event_system } {

		msg -INFO "DSx: use_event_system: True"

	} else {

		msg "NOTICE: DSx: use_event_system: False (prerequisites not found)"

	}
}

proc DSx_startup {} {
    load_DSx_settings
    check_DSx_variables
    check_settings_for_DSx_added_variables
    set_other_variables
    DSx_pages
    load_theme
    source "[homedir]/skins/default/standard_includes.tcl"
    set ::skindebug $::DSx_skindebug
    check_DSx_User_Set_exists
    check_MySaver_exists
    join_DSx_plugins
    no_machine_prep
    history_vars
    save_DSx_settings
    save_settings
}

proc DSx_final_prep {} {
    #preload_history_page
    set space { }
    set ::settings(skin_version) $::DSx_home_page_version[package version DSx]$space$space[DSx_active_plugins]
    delete_old_variables
    startup_fav_check
    saw_switch
    DSx_graph_restore
    focus .can
    bind Canvas <KeyPress> {handle_keypress %k}
    plugins_run_after_startup
    refresh_DSx_temperature
    DSx_reset_graphs
}

proc preload_history_page {} {
    after 1 {
        borg spinner on
        page_show DSx_past
        after 100 page_show off
        borg spinner off
        borg systemui $::android_full_screen_flags
    }
}

proc check_DSx_User_Set_exists {} {
    if {[info exists [skin_directory]/DSx_User_Set] != 1} {
        set path [skin_directory]/DSx_User_Set
        file mkdir $path
        file attributes $path
    }
}

proc plugins_run_after_startup {} {
    foreach k $::run_after_startup {
	$k
    }
}

proc DSx_active_plugins {} {
	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/skins/DSx/DSx_Plugins/" *.dsx]]
    set files [lsearch -inline -all -not -exact $files DSx_admin.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_backup.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_cal.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_coffee.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_theme.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_workflow.dsx]

	set dd {}
	set space { }
	set u {_}
	foreach f $files {
	    set fn "[homedir]skins/DSx/DSx_Plugins/$f"
	    set name [file rootname $f]
		append list $name$u[package versions $name]$space$space
	}
	return $list
}

proc list_all_package_versions {} {
    set list {}
    foreach pn [package names] {
        set pnv [package versions $pn]
        append list $pn$pnv\r
    }
    return $list
}

proc join_DSx_plugins {} {
    set plugin_file [lsort -dictionary [glob -nocomplain -tails -directory "./skins/DSx/DSx_Plugins/" *.dsx]]
    foreach pf $plugin_file {
        set pf [file rootname $pf]
        unset -nocomplain version
        source  [file join "./skins/DSx/DSx_Plugins/" $pf.dsx]
        if {[info exists version] != 1} {
            set version {1.0}
        }
        package forget $pf
        package provide $pf $version
        package ifneeded $pf $version [list source [file join "./skins/DSx/DSx_Plugins/" $pf]]
        package require $pf
    }
    set ::DSx_other_pages $::DSx_page_name
}

proc no_machine_prep {} {
    if {$::android == 0} {
		start_idle
	}
}

proc add_DSx_background {pages} {
    foreach context $pages {
        set ::DSx_bg($context) [.can create rect 0 0 $::settings(screen_size_width) $::settings(screen_size_height) -outline $::DSx_settings(bg_colour) -fill $::DSx_settings(bg_colour)]
        add_visual_item_to_context $context $::DSx_bg($context)
    }
}

proc add_DSx_button {pages code x1 y1 x2 y2 {options {}}} {
    add_de1_button "$pages" "$code" $x1 $y1 $x2 $y2 ""

    set arc_offset 32
    set colour $::DSx_settings(font_colour)
    set width 3

    set x1 [rescale_x_skin $x1]
    set y1 [rescale_y_skin $y1]
    set x2 [rescale_x_skin $x2]
    set y2 [rescale_y_skin $y2]
    if { [info exists ::_rect_id] != 1 } { set ::_rect_id 0 }
    set tag "rect_$::_rect_id"
    .can create arc [expr $x1] [expr $y1+$arc_offset] [expr $x1+$arc_offset] [expr $y1] -style arc -outline $colour -width [expr $width-1] -tag $tag -start 90
    .can create arc [expr $x1] [expr $y2-$arc_offset] [expr $x1+$arc_offset] [expr $y2] -style arc -outline $colour -width [expr $width-1] -tag $tag -start 180
    .can create arc [expr $x2-$arc_offset] [expr $y1] [expr $x2] [expr $y1+$arc_offset] -style arc -outline $colour -width [expr $width-1] -tag $tag -start 0
    .can create arc [expr $x2-$arc_offset] [expr $y2] [expr $x2] [expr $y2-$arc_offset] -style arc -outline $colour -width [expr $width-1] -tag $tag -start -90
    .can create line [expr $x1+$arc_offset/2] [expr $y1] [expr $x2-$arc_offset/2] [expr $y1] -fill $colour -width $width -tag $tag
    .can create line [expr $x2] [expr $y1+$arc_offset/2] [expr $x2] [expr $y2-$arc_offset/2] -fill $colour -width $width -tag $tag
    .can create line [expr $x1+$arc_offset/2] [expr $y2] [expr $x2-$arc_offset/2] [expr $y2] -fill $colour -width $width -tag $tag
    .can create line [expr $x1] [expr $y1+$arc_offset/2] [expr $x1] [expr $y2-$arc_offset/2] -fill $colour -width $width -tag $tag
    foreach context $pages {
        add_visual_item_to_context $context $tag
    }
    incr ::_rect_id
    return $tag
}

proc DSx_plugin_page_name {page_name} {
    lappend ::DSx_page_name $page_name
}

proc delete_old_variables {} {
    if {[info exists ::settings(DSx_bean_weight)] == 1} {
        unset -nocomplain ::settings(DSx_bean_weight)
        save_settings
    }
    if {[info exists ::settings(dsv4_jug_size)] == 1} {
        unset -nocomplain ::settings(dsv4_jug_size)
        unset -nocomplain ::settings(dsv4_volume)
        unset -nocomplain ::settings(dsv4_wsaw)
        unset -nocomplain ::settings(dsv4_bean_weight)
        save_settings
    }
}

proc check_DSx_variables {} {
    if {[info exists ::DSx_settings(DSx_home)] == 0} {
        set ::DSx_settings(DSx_home) "dial"
    }
    if {[info exists ::DSx_settings(past_clock)] == 0} {
        set ::DSx_settings(past_clock) {}
    }
    if {[info exists ::DSx_settings(past_clock2)] == 0} {
        set ::DSx_settings(past_clock2) {}
    }
    if {[info exists ::settings(history_icon_screen_saver)] == 0} {
        set ::settings(history_icon_screen_saver) 1
    }

    if {[info exists ::DSx_settings(save_DSx_steam_history)] == 0} {
        set ::DSx_settings(save_DSx_steam_history) 1
    }
    if {[info exists ::DSx_settings(DSx_past2_steam_pressure)] == 0} {
        set ::DSx_settings(DSx_past2_steam_pressure) {0.0}
        set ::DSx_settings(DSx_past2_steam_flow) {0.0}
        set ::DSx_settings(DSx_past2_steam_temperature) {0.0}
        set ::DSx_settings(DSx_past2_steaming_count_setting) {}
        set ::DSx_settings(DSx_past2_steam_timeout_setting) {}
        set ::DSx_settings(DSx_past2_steam_temperature_setting) {}
        set ::DSx_settings(DSx_past2_steam_flow_setting) {}
        set ::DSx_settings(DSx_past2_steam_highflow_start_setting) {}
    }
    if {[info exists ::DSx_settings(glt1)] == 0} {
        set ::DSx_settings(glt1) 4
        set ::DSx_settings(glt2) 4
        set ::DSx_settings(glt3) 4
        set ::DSx_settings(glt4) 4
        set ::DSx_settings(glt5) 4
        set ::DSx_settings(glb1) 2
        set ::DSx_settings(glb2) 2
        set ::DSx_settings(glb3) 2
        set ::DSx_settings(glb4) 2
        set ::DSx_settings(glb5) 2
    }
    if {[info exists ::DSx_skindebug] == 0} {
        set ::DSx_skindebug 0
    }
    if {[info exists ::DSx_settings(original_clock_font)] == 0} {
        set ::DSx_settings(original_clock_font) 1
        set ::DSx_settings(clock_font) {Comic Sans MS}
    }
    if {[info exists ::DSx_settings(bean_nett_range)] == 0} {
        set ::DSx_settings(bean_nett_range) 30
    }
    if {[info exists ::DSx_settings(bean_offset)] == 0} {
        set ::DSx_settings(bean_offset) 0
    }
    if {[info exists ::DSx_settings(activated)] == 0} {
        set ::DSx_settings(activated) 1
        set ::DSx_settings(heading) {- DSx -}
        set ::DSx_settings(font_colour) #ddd
        set ::DSx_settings(bg_name) bg2.jpg
        set ::DSx_settings(bg_colour) #1e1e1e
        set ::DSx_settings(green) #00dd00
        set ::DSx_settings(pink) #f198e6
        set ::DSx_settings(blue) #73ced8
        set ::DSx_settings(orange) #ff9421
        set ::DSx_settings(grey) #eee
        set ::DSx_settings(grid_colour) #555
        set ::DSx_settings(x_axis_colour) #ddd
        set ::DSx_settings(saw) 45
        set ::DSx_settings(graph_weight_total) 0
        set ::DSx_settings(past_bean_weight) 1
        set ::DSx_settings(font_size) [expr {100 * $::settings(default_font_calibration)}]
        set ::DSx_settings(bean_weight) 0
        set ::DSx_settings(steam_calc) 1
        set ::DSx_settings(jug_g) 0
        set ::DSx_settings(jug_s) 0
        set ::DSx_settings(jug_m) 0
        set ::DSx_settings(jug_l) 0
        set ::DSx_settings(milk_g) 0
        set ::DSx_settings(milk_s) 0
        set ::DSx_settings(jug_size) { }
        set ::DSx_settings(blue_cup_indicator) { }
        set ::DSx_settings(pink_cup_indicator) { }
        set ::DSx_settings(orange_cup_indicator) { }
        set ::DSx_settings(zoomed_y_axis_scale_default) 12
        set ::DSx_settings(zoomed_y_axis_max) 12
        set ::DSx_settings(zoomed_y_axis_min) 0
        set ::DSx_settings(zoomed_y2_axis_max) 6
        set ::DSx_settings(zoomed_y2_axis_min) 0
        set ::settings(tare_only_on_espresso_start) 1
        set ::DSx_settings(bezel) 2
        set ::DSx_settings(icons) 1
        set ::DSx_settings(wsaw) 0
        set ::DSx_settings(wsaw_cal) 1.4
        set ::DSx_settings(no_scale) 0
        set ::DSx_settings(dial) 3
        if {$::settings(steam_temperature) > 129} {
            set ::DSx_settings(steam_temperature_backup) $::settings(steam_temperature)
        } else {
            set ::DSx_settings(steam_temperature_backup) 160
        }
        set ::settings(DSx_volume) 0
        set ::DSx_settings(past_volume1) 0
        set ::DSx_settings(past_volume2) 0
        set ::DSx_settings(font_name) "Roboto-Regular"
        set ::DSx_settings(clock_hide) 0
        set ::DSx_settings(clock_hide_ss) 0
    }
    if {[info exists ::DSx_settings(heading_colour)] == 0} {
            set ::DSx_settings(heading_colour) $::DSx_settings(font_colour)
    }
    if {[info exists ::DSx_settings(font_dir)] == 0 } {
            set ::DSx_settings(font_dir) [skin_directory]/DSx_Font_Files
    }
    if {[file exists "$::DSx_settings(font_dir)/$::DSx_settings(font_name).ttf"] == 0 && [file exists "$::DSx_settings(font_dir)/$::DSx_settings(font_name).otf"] == 0 } {
        set ::DSx_settings(font_dir) [skin_directory]/DSx_Font_Files
        if {[file exists "$::DSx_settings(font_dir)/Roboto-Regular.ttf"] == 1} {
            set ::DSx_settings(font_name) "Roboto-Regular"
        } else {
            set ::DSx_settings(font_name) "Comic Sans MS"
            #set ::DSx_settings(font_name) "Handlee-Regular"
        }
    }
    if {$::settings(steam_temperature) > 130} {
            set ::DSx_settings(steam_temperature_backup) $::settings(steam_temperature)
    }
    if {[info exists ::DSx_settings(flush_time)] == 0 } {
        set ::DSx_settings(flush_time) $::settings(preheat_volume)
    }
    if {[info exists ::DSx_settings(flush_time2)] == 0 } {
        set ::DSx_settings(flush_time2) 0
    }
    if {[info exists ::DSx_settings(first_page_from_saver)] == 0 } {
        set ::DSx_settings(first_page_from_saver) {off}
    }

	### added by Enrique ###
	if {[info exists ::DSx_settings(extra_past_shot_fields)] == 0 } {
		set ::DSx_settings(extra_past_shot_fields) {bean_brand bean_type roast_date roast_level bean_notes grinder_model grinder_setting drink_tds drink_ey espresso_enjoyment espresso_notes my_name scentone skin beverage_type}
	}
	### end of addition ###	
}

proc check_settings_for_DSx_added_variables {} {
        if {[info exists ::settings(DSx_jug_size)] == 0} {
            set ::settings(DSx_jug_size) { }
        }
        if {[info exists ::settings(DSx_wsaw)] == 0} {
            set ::settings(DSx_wsaw) 0
        }
        if {[info exists ::settings(DSx_flush_time)] == 0} {
            set ::settings(DSx_flush_time) $::DSx_settings(flush_time)
        }
}

proc DSx_pages {} {
    set ::DSx_admin_pages {DSx_5_admin DSx_admin_saver DSx_units DSx_admin_skin}
    set ::DSx_standby_pages {off steam_1 flush_1 water_1}
    set ::DSx_active_pages {espresso steam preheat_2 water}
    set ::DSx_zoomed_pages {off_zoomed steam_1_zoomed flush_1_zoomed water_1_zoomed espresso_zoomed}
    set ::DSx_steam_zoomed_pages {off_steam_zoomed steam_1_steam_zoomed flush_1_steam_zoomed water_1_steam_zoomed steam_steam_zoomed}
    set ::DSx_other_pages2 {3}
    set ::DSx_blank_pages {DSx_demo_graph message DSx_past DSx_h2g DSx_past_zoomed DSx_past2_zoomed DSx_past3_zoomed}
    set ::DSx_home_pages "$::DSx_standby_pages $::DSx_active_pages"
    set ::DSx_all_pages "$::DSx_admin_pages $::DSx_standby_pages $::DSx_active_pages $::DSx_other_pages2 $::DSx_blank_pages $::DSx_zoomed_pages $::DSx_steam_zoomed_pages"
    add_de1_page "DSx_power" "poweroff.png"
    add_de1_page "DSx_travel_prepare" "travel_prepare.jpg" "default"
    add_de1_page "DSx_descale_prepare" "descale_prepare.jpg" "default"
}
set_next_page "hotwaterrinse" "preheat_2"

proc load_theme {} {
	borg spinner on
	if {$::DSx_settings(bg_name) == "bg1.jpg"} {
        set ::DSx_settings(bg_colour) #000000
    } elseif {$::DSx_settings(bg_name) == "bg2.jpg"} {
        set ::DSx_settings(bg_colour) #1e1e1e
    } elseif {$::DSx_settings(bg_name) == "bg3.jpg"} {
        set ::DSx_settings(bg_colour) #242424
    } elseif {$::DSx_settings(bg_name) == "bg4.jpg"} {
        set ::DSx_settings(bg_colour) #333
    } else {
        set ::DSx_settings(bg_colour) #3d3c36
    }
    .can configure -bg $::DSx_settings(bg_colour)
	borg spinner off
	borg systemui $::android_full_screen_flags
}

proc DSx_home_page_theme_update {} {
}

proc set_colour {} {
    DSx_home_page_theme_update
    $::DSx_heading_entry configure -bg $::DSx_settings(bg_colour) -font "[DSx_font font 30]"
    $::DSx_home_espresso_graph_1 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
	$::DSx_home_espresso_graph_2 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
	$::DSx_home_espresso_graph_3 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
	$::DSx_espresso_zoomed_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
	$::DSx_home_steam_graph_1 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_home_steam_graph_2 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_home_steam_graph_3 configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_home_steam_zoomed_graph  configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_6_theme_home1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour)
    $::DSx_6_theme_home2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour)
    $::DSx_6_theme_radiobutton1 configure -bg $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_radiobutton2 configure -bg $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_radiobutton3 configure -bg $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_radiobutton4 configure -bg $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_radiobutton5 configure -bg $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_bezel_radiobutton1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_bezel_radiobutton2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_bezel_radiobutton3 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_dial_radiobutton1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_dial_radiobutton2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_dial_radiobutton3 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_icons_radiobutton1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_icons_radiobutton2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_5_admin_version_radiobutton1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_5_admin_version_radiobutton2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_5_admin_version_radiobutton3 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_checkbutton_1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_6_theme_checkbutton_2 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font "$::DSx_settings(clock_font)" 8]"
    $::DSx_6_theme_checkbutton_3 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_2_cal_checkbutton_1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    $::DSx_5_admin_checkbutton_1 configure -bg $::DSx_settings(bg_colour) -activebackground $::DSx_settings(bg_colour) -font "[DSx_font font 8]"
    .can itemconfigure $::DSx_clock_font_var_1 -font "[DSx_font "$::DSx_settings(clock_font)" 14.5]"
    .can itemconfigure $::DSx_clock_font_var_2 -font "[DSx_font "$::DSx_settings(clock_font)" 6.4]"
    .can itemconfigure $::DSx_clock_font_var_3 -font "[DSx_font "$::DSx_settings(clock_font)" 8]"
    .can itemconfigure $::DSx_clock_font_var_4 -font "[DSx_font "$::DSx_settings(clock_font)" 6]"
    .can itemconfigure $::DSx_6_theme_var_10_1 -font "[DSx_font font 10]"
    .can itemconfigure $::DSx_6_theme_var_10_2 -font "[DSx_font font 10]"
    .can itemconfigure $::DSx_6_theme_var_10_3 -font "[DSx_font font 10]"
    .can itemconfigure $::DSx_6_theme_var_12_1 -font "[DSx_font font 12]"
    .can itemconfigure $::DSx_6_theme_var_8_1 -font "[DSx_font font 8]"
    .can itemconfigure $::DSx_6_theme_var_8_2 -font "[DSx_font font 8]"
    .can itemconfigure $::DSx_6_theme_var_8_3 -font "[DSx_font font 8]"
    .can itemconfigure $::DSx_6_theme_var_18_1 -font "[DSx_font font 18]"
    .can itemconfigure $::DSx_6_theme_var_7_1 -font "[DSx_font font 7]"
    .can itemconfigure $::DSx_6_theme_var_7_2 -font "[DSx_font font 7]"
    .can itemconfigure $::DSx_6_theme_var_7_3 -font "[DSx_font font 7]"
    .can itemconfigure $::DSx_6_theme_var_9_1 -font "[DSx_font font 9]"
    $::globals(DSx_past_shots_widget) configure -background $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -selectbackground $::DSx_settings(font_colour)
    $::globals(DSx_past2_shots_widget) configure -background $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -selectbackground $::DSx_settings(font_colour)
    $::DSx_history_left_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_history_right_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_history_icon_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_history_left_zoomed_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_history_right_zoomed_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)
    $::DSx_history_icon_zoomed_graph configure -plotbackground $::DSx_settings(bg_colour) -background $::DSx_settings(bg_colour)

    $::globals(DSx_active_plugin_widget) configure -background $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -selectbackground $::DSx_settings(font_colour)
    $::globals(DSx_inactive_plugin_widget) configure -background $::DSx_settings(bg_colour) -foreground $::DSx_settings(font_colour) -selectbackground $::DSx_settings(font_colour)
    $::DSx_active_plugin_scrollbar configure -troughcolor $::DSx_settings(bg_colour) -background $::DSx_settings(font_colour)
    $::DSx_inactive_plugin_scrollbar configure -troughcolor $::DSx_settings(bg_colour) -background $::DSx_settings(font_colour)

}

proc theme_change {} {
    load_theme
    set_colour
    dial_config_start
}

proc set_other_variables {} {
    set ::wsaw_run 0
    set ::flush_run 0
    set ::restart 0
    set ::DSx_settings(font_colour) #ddd
    set ::DSx_settings(red) #ff574a
    set ::DSx_workflow_to_settings_1 0
    set ::DSx_coffee_to_settings_1 0
    set ::fave_saved { }
    set ::DSx_saved_2 {}
    set ::current_espresso_page off
    set ::DSx_steam_state 0
    set ::steam_off_message ""
    set ::de1(scale_weight) 0
    set ::DSxv 0
    set ::DSx_steam_purge_state 0
    set ::DSx_steam_state_text "Steaming"
    set ::Dsx_temperature_shift_amount 0
    if {$::settings(enable_fahrenheit) == 1} {
        set ::c_f_adjust 0.05
        } else {
        set ::c_f_adjust 0.1
    }
}

proc check_MySaver_exists {} {
    set dir "[homedir]/MySaver"
    set file_list [glob -nocomplain "$dir/*"]
    if {[llength $file_list] != 0} {
        set_de1_screen_saver_directory "[homedir]/MySaver"
    }
}


### Saving DSx settings file
proc DSx_filename {} {
    set fn "[skin_directory]/DSx_User_Set/DSx_settings.tdb"
    return $fn
}

proc save_DSx_array_to_file {arrname fn} {
    upvar $arrname item
    set DSx_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append DSx_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $DSx_data
}

proc save_DSx_settings {} {
    msg "saving DSx settings"
    save_DSx_array_to_file ::DSx_settings [DSx_filename]

}

proc load_DSx_settings {} {
    set version $::DSx_settings(version)
    array set ::DSx_settings [encoding convertfrom utf-8 [read_binary_file [DSx_filename]]]
    set ::DSx_settings(version) $version
    set ::DSx_flush_time2 [ifexists ::DSx_settings(flush_time2)]
    blt::vector create espresso_elapsed1 espresso_elapsed2  DSx_past_espresso_resistance DSx_past_espresso_elapsed DSx_past_espresso_pressure DSx_past_espresso_flow DSx_past_espresso_flow_weight DSx_past_espresso_flow_weight_2x DSx_past_espresso_flow_2x DSx_past_espresso_temperature_basket DSx_past_espresso_temperature_mix  DSx_past_espresso_flow_goal DSx_past_espresso_flow_goal_2x DSx_past_espresso_pressure_goal DSx_past_espresso_temperature_goal DSx_past_espresso_temperature_goal_01 DSx_past_espresso_temperature_basket_01
    blt::vector create espresso_elapsed1 espresso_elapsed2  DSx_past2_espresso_resistance DSx_past2_espresso_elapsed DSx_past2_espresso_pressure DSx_past2_espresso_flow DSx_past2_espresso_flow_weight DSx_past2_espresso_flow_weight_2x DSx_past2_espresso_flow_2x DSx_past2_espresso_temperature_basket  DSx_past2_espresso_temperature_mix  DSx_past2_espresso_flow_goal DSx_past2_espresso_flow_goal_2x DSx_past2_espresso_pressure_goal DSx_past2_espresso_temperature_goal DSx_past2_espresso_temperature_goal_01 DSx_past2_espresso_temperature_basket_01
    blt::vector create espresso_elapsed1 espresso_elapsed2  DSx_last_espresso_resistance DSx_last_espresso_elapsed DSx_last_espresso_pressure DSx_last_espresso_flow DSx_last_espresso_flow_weight DSx_last_espresso_flow_weight_2x DSx_last_espresso_flow_2x DSx_last_espresso_temperature_basket DSx_last_espresso_temperature_mix  DSx_last_espresso_flow_goal DSx_last_espresso_flow_goal_2x DSx_last_espresso_pressure_goal DSx_last_espresso_temperature_goal DSx_last_espresso_temperature_goal_01 DSx_last_espresso_temperature_basket_01
    blt::vector create DSx_espresso_temperature_basket DSx_espresso_temperature_mix DSx_espresso_temperature_goal
    blt::vector create espresso_elapsed_preview espresso_pressure_preview espresso_flow_preview espresso_flow_weight_preview espresso_flow_preview_2x espresso_flow_weight_preview_2x
    blt::vector create DSx_explanation_temp DSx_espresso_elapsed_preview DSx_espresso_pressure_preview DSx_espresso_flow_preview DSx_espresso_flow_weight_preview DSx_espresso_flow_preview_2x DSx_espresso_flow_weight_preview_2x
    blt::vector create DSx_past_espresso_state_change DSx_past2_espresso_state_change
    blt::vector create DSx_past2_steam_pressure DSx_past2_steam_flow DSx_past2_steam_temperature
}

proc off_timer {} {
    set_next_page off DSx_power;
    page_show DSx_power;
    #after 3000 {set_next_page off off; set ::current_espresso_page "off"; start_sleep}
    ### Allow canceling sleep by clicking the background on power off page - by Cheesy
    set ::DSx_sleep_timer [ after 3000 {set_next_page off off; set ::current_espresso_page "off"; start_sleep} ]
}

proc window_expand {} {
    set width_small [expr {$::settings(screen_size_width)}]
    set height_small [expr {$::settings(screen_size_height)}]
    wm maxsize . $width_small $height_small
    wm minsize . $width_small $height_small
    wm attributes . -fullscreen 1
}

proc first_page_from_saver {} {
    load_test
    if {[lsearch -exact $::DSx_page_name $::DSx_settings(first_page_from_saver)] >= 0} {
        page_show $::DSx_settings(first_page_from_saver)
    } else {
       set_next_page off off
       start_idle
    }
}

proc power_off {} {
    after cancel {start_sleep}
    app_exit
}

proc load_test {} {
   set ::DSx_settings(graph_weight_total_b) $::DSx_settings(graph_weight_total)
   set ::DSx_settings(tare_off_b) $::settings(tare_only_on_espresso_start)
   set ::DSx_settings(font_size_b) $::settings(default_font_calibration)
   check_skin_backup
   backup_settings
}

proc check_backup {} {
    if {[file exists [homedir]BackUpCopy] != 1} {
        set ::no_backup "You do not have a backup file"
        } else {
        set ::no_backup ""
    }
}

proc check_skin_backup {} {
    if {[file exists [homedir]BackUpCopy/skins/DSx/DSx_User_Set] != 1} {
        set ::skin_backup_button "No Backup \rAvailable"
        } else {
        set ::skin_backup_button "Restore\rDSx Setup"
    }
}

proc DSx_backup {} {
    borg spinner on
    file delete -force [homedir]BackUpCopy
    file copy -force [homedir] [homedir]BackUpCopy
    borg spinner off
    borg systemui $::android_full_screen_flags
    done_message
}

proc clearshit {} {
    set cnt 0
    set debugcnt 0
    set ::debuglog {}
}

proc start_button_ready {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" && $::de1(device_handle) != 0} {
		if {$::settings(steam_timeout) > 0 && [steamtemp] > [expr {$::settings(steam_temperature) - 11}]} {
		    return [translate "READY"]
		} elseif {$::settings(steam_timeout) == 0} {
		    return [translate "READY"]
		}
	}
	return [translate "WAIT"]
}

proc de1_substate_text_DSx {} {
	set num $::de1(substate)
	set substate_txt $::de1_substate_types($num)
	if {$substate_txt == "ready" || $substate_txt == "wait"} {
		return [translate " "]
	}
	return [translate $substate_txt]
}

proc DSx_steam_time_text {} {
    if {$::settings(steam_timeout) > 0} {
        return [round_to_integer $::settings(steam_timeout)][translate "s"]
    } else {
        return "off"
    }
}

proc DSx_sav {} {
    if {$::settings(scale_bluetooth_address) == "" && $::settings(final_desired_shot_volume) > 0 && ($::settings(settings_profile_type) == "settings_2a" || $::settings(settings_profile_type) == "settings_2b")} {
        return "SAV - [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume)]]"
    } elseif {$::settings(final_desired_shot_volume_advanced) > 0 && ($::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2")} {
        return "SAV Step $::settings(final_desired_shot_volume_advanced_count_start) - [return_liquid_measurement [round_to_integer $::settings(final_desired_shot_volume_advanced)]]"
    } else {
        return "SAV - off"
    }
}
proc DSx_profile_type {} {
    if {$::settings(settings_profile_type) == "settings_2a"} {
        return "Pressure"
    } elseif {$::settings(settings_profile_type) == "settings_2b"} {
        return "Flow"
    } else {
        return "Adv."
    }
}
proc DSx_preheat_status {} {
    if {$::settings(tank_desired_water_temperature) > 1} {
        return "[return_temperature_measurement $::settings(tank_desired_water_temperature)]"
    } else {
        return ""
    }
}

proc check_steam_on {} {
    if {$::settings(steam_temperature) > 130} {
        set ::DSx_settings(steam_temperature_backup) $::settings(steam_temperature)
    }
    if {$::settings(steam_timeout) > 0} {
        set ::settings(steam_temperature) $::DSx_settings(steam_temperature_backup)
    } else {
        set ::settings(steam_temperature) 0
    }
    save_settings
    de1_send_steam_hotwater_settings
    clear_steam_font
}

proc DSx_steam_time {} {
    if {[expr "\[round_to_integer $::settings(steam_timeout)] - \[steam_pour_timer]"] >= 0} {
        set ::DSx_steam_timing_text [expr "\[round_to_integer $::settings(steam_timeout)] - \[steam_pour_timer]"]
    } else {
        set ::DSx_steam_timing_text ""
    }
    return $::DSx_steam_timing_text
}

proc DSx_steam_state_off {} {
    #set ::DSx_steam_state 0
    set ::DSx_steam_state 3
    set ::DSx_purging_text_hold_time [clock seconds]
}

proc DSx_steam_info {} {
    if {$::DSx_steam_purge_state != 1} {
        set ::DSx_steam_state_text "Steaming"
    }
    if {[expr "\[round_to_integer $::settings(steam_timeout)] - \[steam_pour_timer]"] < 0 && [expr "\[round_to_integer $::settings(steam_timeout)] - \[steam_pour_timer]" + 2] > 0} {
        set ::DSx_steam_purge_state 1
        set ::DSx_steam_state_text "Start steam purge"
    }
    if {$::DSx_steam_state == 3 && $::DSx_purging_text_hold_time < [expr [clock seconds] - 5]} {
        set ::DSx_steam_state 0
    }
    if {$::DSx_steam_state == 3} {
        set ::DSx_steam_state_text "purging"
    }
    return $::DSx_steam_state_text
}

proc de1_connected_state_DSx {} {
    if {[de1_connected_state] == "Wait"} {
    return ""
    }
    return [de1_connected_state]
}
set ::DSx_blink 1

proc DSx_scale_disconnected {} {
	if {$::android == 1 && [ifexists ::settings(scale_bluetooth_address)] == ""} {
		return ""
	}
	if {$::de1(scale_device_handle) == "0" && $::DSx_settings(no_scale) != 1 && $::android == 1} {
		if {$::DSx_blink == 1} {
		    after 300 {set ::DSx_blink 0}
		    return "reconnect"
		} else {
		    set ::DSx_blink 1
		    return ""
		}
	}
	return ""
}

proc done_message {} {
    set ::done "All Done!"
    after 4000 {set ::done ""}
}

proc wait-message {} {
        set ::no_backup ""
        set ::done "Please wait..."
}

proc skin_wait_message {} {
    if {[file exists [homedir]BackUpCopy/skins/DSx/DSx_User_Set] == 1} {
        set ::skin_backup_button "Please \rWait..."
    }
}

proc restore_DSx_User_set {} {
    if {[file exists [homedir]BackUpCopy/skins/DSx/DSx_User_Set] == 1} {
        file delete -force [homedir]/skins/DSx/DSx_User_Set
        file copy [homedir]BackUpCopy/skins/DSx/DSx_User_Set [homedir]/skins/DSx/DSx_User_Set
        .can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."] -fill #dddddd
        after 2000 {set_next_page off message; page_show message}
        }
}

proc DSx_current_listbox_item {widget} {
	set found_one 0
	for {set x 0} {$x < [$widget index end]} {incr x} {
		if {$x == [$widget curselection]} {
				$widget itemconfigure $x -foreground $::DSx_settings(bg_colour) -selectforeground $::DSx_settings(bg_colour) -background $::DSx_settings(font_colour)
				set found_one 1
		} else {
			$widget itemconfigure $x -foreground $::DSx_settings(font_colour) -background $::DSx_settings(bg_colour)
		}
	}
	if {$found_one != 1} {
		# handle the case where nothing has been selected
		$widget selection set 0
		$widget itemconfigure 0 -foreground $::DSx_settings(font_colour) -selectforeground #000000  -background $::DSx_settings(bg_colour)
	}
}

proc DSx_font_cal {} {
    set fn [expr {$::DSx_settings(font_size)/100}]
    if {$fn <0.25} {
        set ::settings(default_font_calibration) 0.25
        set ::DSx_settings(font_size) 25
    } elseif {$fn > 1.2} {
        set ::settings(default_font_calibration) 1
        set ::DSx_settings(font_size) 100
    } else {
        set ::settings(default_font_calibration) $fn
    }
    save_settings
    save_DSx_settings
}

proc horizontal_clicker_int {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1} {

	set x [translate_coordinates_finger_down_x $x]
	set y [translate_coordinates_finger_down_y $y]
	set xrange [expr {$x1 - $x0}]
	set xoffset [expr {$x - $x0}]
	set midpoint [expr {$x0 + ($xrange / 2)}]
	set onequarterpoint [expr {$x0 + ($xrange / 5)}]
	set threequarterpoint [expr {$x1 - ($xrange / 5)}]
	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval
	if {$x < $onequarterpoint} {
		set newval [expr "1.0 * \$$varname - $bigincrement"]
	} elseif {$x < $midpoint} {
		set newval [expr "1.0 * \$$varname - $smallincrement"]
	} elseif {$x < $threequarterpoint} {
		set newval [expr "1.0 * \$$varname + $smallincrement"]
	} else {
		set newval [expr "1.0 * \$$varname + $bigincrement"]
	}
	set newval [round_to_integer $newval]
	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_to_integer $newval]
	}
	update_onscreen_variables
	return
}

proc horizontal_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1} {
	set x [translate_coordinates_finger_down_x $x]
	set y [translate_coordinates_finger_down_y $y]
	set xrange [expr {$x1 - $x0}]
	set xoffset [expr {$x - $x0}]
	set midpoint [expr {$x0 + ($xrange / 2)}]
	set onequarterpoint [expr {$x0 + ($xrange / 5)}]
	set threequarterpoint [expr {$x1 - ($xrange / 5)}]
	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initiialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval
	if {$x < $onequarterpoint} {
		set newval [expr "1.0 * \$$varname - $bigincrement"]
	} elseif {$x < $midpoint} {
		set newval [expr "1.0 * \$$varname - $smallincrement"]
	} elseif {$x < $threequarterpoint} {
		set newval [expr "1.0 * \$$varname + $smallincrement"]
	} else {
		set newval [expr "1.0 * \$$varname + $bigincrement"]
	}
	set newval [round_to_two_digits $newval]

	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_to_two_digits $newval]
	}
	update_onscreen_variables
	return
}


set ::DSx_tap_multiplier {- 0.1 +}

proc horizontal_clicker_fast_tap {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1 {b 0} } {
	set x [translate_coordinates_finger_down_x $x]
	set y [translate_coordinates_finger_down_y $y]
	set xrange [expr {$x1 - $x0}]
	set xoffset [expr {$x - $x0}]
	set midpoint [expr {$x0 + ($xrange / 2)}]
	set onequarterpoint [expr {$x0 + ($xrange / 4)}]
	set threequarterpoint [expr {$x1 - ($xrange / 4)}]
	set onethirdpoint [expr {$x0 + ($xrange / 3)}]
	set twothirdpoint [expr {$x1 - ($xrange / 3)}]
	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval
	# check for a fast double tap
	set b 0
	if {[is_fast_double_tap $varname] == 1 || $::DSx_tap_multiplier == {- 1.0 +}} {
		set b 3
	}
	if {$x < $onethirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname - $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname - $smallincrement"]
		}
	} elseif {$x > $twothirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname + $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname + $smallincrement"]
		}
	}
	set newval [round_to_two_digits $newval]
	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_to_two_digits $newval]
	}
	update_onscreen_variables
	return
}



proc horizontal_clicker_fast_tap_int {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1 {b 0} } {
	set x [translate_coordinates_finger_down_x $x]
	set y [translate_coordinates_finger_down_y $y]
	set xrange [expr {$x1 - $x0}]
	set xoffset [expr {$x - $x0}]
	set midpoint [expr {$x0 + ($xrange / 2)}]
	set onequarterpoint [expr {$x0 + ($xrange / 4)}]
	set threequarterpoint [expr {$x1 - ($xrange / 4)}]
	set onethirdpoint [expr {$x0 + ($xrange / 3)}]
	set twothirdpoint [expr {$x1 - ($xrange / 3)}]
	if {[info exists $varname] != 1} {
		# if the variable doesn't yet exist, initialize it with a zero value
		set $varname 0
	}
	set currentval [subst \$$varname]
	set newval $currentval
	# check for a fast double tap
	set b 0
	if {[is_fast_double_tap $varname] == 1 || $::DSx_tap_multiplier == {x1}} {
		set b 3
	}
	if {$x < $onethirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname - $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname - $smallincrement"]
		}
	} elseif {$x > $twothirdpoint} {
		if {$b == 3} {
			set newval [expr "1.0 * \$$varname + $bigincrement"]
		} else {
			set newval [expr "1.0 * \$$varname + $smallincrement"]
		}
	}
	set newval [round_to_integer $newval]
	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_to_integer $newval]
	}
	update_onscreen_variables
	return
}




proc DSx_update_saw {} {
    set ::settings(final_desired_shot_weight_advanced) $::DSx_settings(saw)
    set ::settings(final_desired_shot_weight) $::DSx_settings(saw)
    save_settings
    save_DSx_settings

}
proc DSx_volume {} {
    set ::settings(DSx_volume) [expr {[round_to_integer $::de1(preinfusion_volume)] + [round_to_integer $::de1(pour_volume)]}]]
    set a [watervolume_text]
    return $a
}

proc save_DSx_flush_time_to_settings {} {
    set ::settings(DSx_flush_time) $::DSx_settings(flush_time)
    save_settings
    save_DSx_settings
}

proc save_dose {unused_old_state unused_new_state} {
    set ::settings(grinder_dose_weight) [round_to_one_digits $::DSx_settings(bean_weight)]
}

proc DSx_set_dose {} {
    if {$::de1(scale_sensor_weight) < 0} {
        return
    }
    if {($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset)) >= 0 && $::DSx_settings(bean_offset) > 0 && ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset)) < $::DSx_settings(bean_nett_range)} {
        set ::DSx_settings(bean_weight) [expr ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset))]
    } else {
       set ::DSx_settings(bean_weight) $::de1(scale_sensor_weight)
    }
    save_DSx_settings
}

proc jug_toggle {} {
    if {$::DSx_settings(pre_tare) != 1} {
        if {$::DSx_settings(jug_size) == "S"} {
            if {$::DSx_settings(jug_m) > 0} {
                set ::DSx_settings(jug_size) M
                set ::DSx_settings(jug_g) $::DSx_settings(jug_m)
                clear_jug_font
                off_cup
            } elseif {$::DSx_settings(jug_l) > 0} {
                set ::DSx_settings(jug_size) L
                set ::DSx_settings(jug_g) $::DSx_settings(jug_l)
                clear_jug_font
                off_cup
            }
        } elseif {$::DSx_settings(jug_size) == "M"} {
            if {$::DSx_settings(jug_l) > 0} {
                set ::DSx_settings(jug_size) L
                set ::DSx_settings(jug_g) $::DSx_settings(jug_l)
                clear_jug_font
                off_cup
            } elseif {$::DSx_settings(jug_s) > 0} {
                set ::DSx_settings(jug_size) S
                set ::DSx_settings(jug_g) $::DSx_settings(jug_s)
                clear_jug_font
                off_cup
            }
        } elseif {$::DSx_settings(jug_size) == "L"} {
            if {$::DSx_settings(jug_s) > 0} {
                set ::DSx_settings(jug_size) S
                set ::DSx_settings(jug_g) $::DSx_settings(jug_s)
                clear_jug_font
                off_cup
            } elseif {$::DSx_settings(jug_m) > 0} {
                set ::DSx_settings(jug_size) M
                set ::DSx_settings(jug_g) $::DSx_settings(jug_m)
                clear_jug_font
                off_cup
            }
        } else {
            load_test
            page_show DSx_2_cal
        }
        set ::settings(DSx_jug_size) $::DSx_settings(jug_size)
        save_DSx_settings
    }
}

proc set_jug {} {
    if {$::DSx_settings(jug_size) == { }} {
        if {$::DSx_settings(jug_s) > 20} {
            set ::DSx_settings(jug_size) S
            set ::DSx_settings(jug_g) $::DSx_settings(jug_s)
            clear_jug_font
            off_cup
        } elseif {$::DSx_settings(jug_m) > 20} {
            set ::DSx_settings(jug_size) M
            set ::DSx_settings(jug_g) $::DSx_settings(jug_m)
            clear_jug_font
            off_cup
        } elseif {$::DSx_settings(jug_l) > 20} {
            set ::DSx_settings(jug_size) L
            set ::DSx_settings(jug_g) $::DSx_settings(jug_l)
            clear_jug_font
            off_cup
        }
    }
    if {$::DSx_settings(jug_size) == "S"} {
        set ::DSx_settings(jug_g) $::DSx_settings(jug_s)
    } elseif {$::DSx_settings(jug_size) == "M"} {
        set ::DSx_settings(jug_g) $::DSx_settings(jug_m)
    } else {
        set ::DSx_settings(jug_g) $::DSx_settings(jug_l)
    }
    set ::settings(DSx_jug_size) $::DSx_settings(jug_size)
    save_DSx_settings
}

proc jug_s_cal_text {} {
    if {$::DSx_settings(pre_tare) == 1} {
        return "off"
    } elseif {$::DSx_settings(jug_s) > 0} {
        return "[round_to_integer $::DSx_settings(jug_s)]g"
    } else {
        return "off"
    }
}
proc jug_m_cal_text {} {
    if {$::DSx_settings(pre_tare) == 1} {
        return "off"
    } elseif {$::DSx_settings(jug_m) > 0} {
        return "[round_to_integer $::DSx_settings(jug_m)]g"
    } else {
        return "off"
    }
}
proc jug_l_cal_text {} {
    if {$::DSx_settings(pre_tare) == 1} {
        return "off"
    } elseif {$::DSx_settings(jug_l) > 0} {
        return "[round_to_integer $::DSx_settings(jug_l)]g"
    } else {
        return "off"
    }
}
proc bean_offset_text {} {
    if {$::DSx_settings(bean_offset) > 0} {
        return "[round_to_one_digits $::DSx_settings(bean_offset)]g"
    } else {
        return "off"
    }
}

proc steam_time_calc {} {
    if {$::DSx_settings(pre_tare) != 1} {
        if {$::DSx_settings(jug_g) == { } || $::DSx_settings(jug_g) < 2 || $::DSx_settings(milk_g) < 2 || $::DSx_settings(milk_g) == { } || $::DSx_settings(milk_s) < 2 || $::DSx_settings(milk_s) == { }} {
            load_test
            page_show DSx_2_cal
        } else {
            set t [expr {$::DSx_settings(milk_s)*1000}]
            set m $::DSx_settings(milk_g)
            set j $::DSx_settings(jug_g)
            set s $::de1(scale_sensor_weight)
            set a [expr {($t/$m*($s-$j))/1000}]
            set ::DSx_settings(steam_calc) [round_to_integer $a]
            if {[expr ($::DSx_settings(steam_calc) > 0)]} {
                if {$::settings(steam_temperature) < 130} {
                    set ::settings(steam_temperature) $::DSx_settings(steam_temperature_backup)
                }
                set ::settings(steam_timeout) $::DSx_settings(steam_calc)
                save_settings
                de1_send_steam_hotwater_settings
            }
        }
    } else {
    set t [expr {$::DSx_settings(milk_s)*1000}]
        set m $::DSx_settings(milk_g)
        set j 0
        set s $::de1(scale_sensor_weight)
        set a [expr {($t/$m*($s-$j))/1000}]
        set ::DSx_settings(steam_calc) [round_to_integer $a]
        if {[expr ($::DSx_settings(steam_calc) > 0)]} {
            if {$::settings(steam_temperature) < 130} {
                set ::settings(steam_temperature) $::DSx_settings(steam_temperature_backup)
            }
            set ::settings(steam_timeout) $::DSx_settings(steam_calc)
            save_settings
            de1_send_steam_hotwater_settings
        }
    }
}

proc DSx_jug_label {} {
    if {$::DSx_settings(pre_tare) == 1} {
        return ""
    } else {
        return $::DSx_settings(jug_size)
    }
}

proc set_jug_s {} {
    set ::DSx_settings(jug_s) [round_to_one_digits $::de1(scale_sensor_weight)]
    if {$::DSx_settings(jug_s) > 20} {
        set ::DSx_settings(jug_size) S
        set ::DSx_settings(jug_g) $::DSx_settings(jug_s)
        clear_jug_font
        off_cup
    }
    save_DSx_settings
}
proc clear_jug_s {} {
    set ::DSx_settings(jug_s) 0
    jug_toggle
}
proc set_jug_m {} {
    set ::DSx_settings(jug_m) [round_to_one_digits $::de1(scale_sensor_weight)]
    if {$::DSx_settings(jug_s) > 20} {
        set ::DSx_settings(jug_size) M
        set ::DSx_settings(jug_g) $::DSx_settings(jug_m)
        clear_jug_font
        off_cup
    }
}
proc clear_jug_m {} {
    set ::DSx_settings(jug_m) 0
    jug_toggle
}
proc set_jug_l {} {
    set ::DSx_settings(jug_l) [round_to_one_digits $::de1(scale_sensor_weight)]
    if {$::DSx_settings(jug_s) > 20} {
        set ::DSx_settings(jug_size) L
        set ::DSx_settings(jug_g) $::DSx_settings(jug_l)
        clear_jug_font
        off_cup
    }
}
proc clear_jug_l {} {
    set ::DSx_settings(jug_l) 0
    jug_toggle
}
proc set_bean_offset {} {
    set ::DSx_settings(bean_offset) [round_to_one_digits $::de1(scale_sensor_weight)]
}
proc clear_bean_offset {} {
    set ::DSx_settings(bean_offset) 0
}

proc round_to_milk {in} {
	if {[expr ($::de1(scale_sensor_weight) > $::DSx_settings(jug_g))] && $::DSx_settings(jug_g) > 20 && $::DSx_settings(pre_tare) != 1} {
        set g g
        set x 0
        catch {
            set x [expr {round($in)}]
        }
        return $x$g
    } else {
        return ""
    }
}
proc round_to_bean {in} {
	if {[expr ($::de1(scale_sensor_weight) > ($::DSx_settings(bean_offset) - 0.1)) && $::DSx_settings(bean_offset) > 0 && ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset)) < $::DSx_settings(bean_nett_range)]} {
        set g g
        set x 0
        catch {
            set x [round_to_one_digits [expr {($in)}]]
        }
        return $x$g
    } elseif {$::DSx_settings(bean_offset) > 0} {
        return "on"
    } else {
        return ""
    }
}


##### Favourite save and load processes

proc startup_fav_check {} {
    if {$::DSx_settings(pink_cup_indicator) == "."} {
        pink_font_set
    } elseif {$::DSx_settings(blue_cup_indicator) == "."} {
        blue_font_set
    } elseif {$::DSx_settings(orange_cup_indicator) == "."} {
        orange_font_set
    }
}



proc DSx_filename {} {
    set fn "[skin_directory]/DSx_User_Set/DSx_settings.tdb"
    return $fn
}

proc save_DSx_array_to_file {arrname fn} {
    upvar $arrname item
    set DSx_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append DSx_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $DSx_data
}

proc save_DSx_settings {} {
    msg "saving DSx settings"
    save_DSx_array_to_file ::DSx_settings [DSx_filename]

}




########
proc favourites_settings_vars {} {
    set favourites_settings_vars {DSx_flush_time final_desired_shot_volume_advanced_count_start final_desired_shot_volume final_desired_shot_volume_advanced tank_desired_water_temperature DSx_wsaw DSx_jug_size advanced_shot espresso_chart_over espresso_chart_under espresso_decline_time espresso_hold_time espresso_max_time espresso_notes espresso_pressure espresso_step_1 espresso_step_2 espresso_step_3 espresso_temperature espresso_typical_volume final_desired_shot_weight final_desired_shot_weight_advanced flow_decline_stop_volumetric flow_hold_stop_volumetric flow_profile_decline flow_profile_decline_time flow_profile_hold flow_profile_hold_time flow_profile_minimum_pressure flow_profile_preinfusion flow_profile_preinfusion_time flow_rate_transition flow_rise_timeout flying goal_is_basket_temp minimum_water_temperature original_profile_title preheat_temperature preinfusion_enabled preinfusion_flow_rate preinfusion_flow_rate2 preinfusion_stop_flow_rate preinfusion_stop_pressure preinfusion_stop_timeout preinfusion_stop_volumetric preinfusion_temperature preinfusion_time pressure_decline_stop_volumetric pressure_end pressure_hold_stop_volumetric pressure_hold_time pressure_rampup_stop_volumetric pressure_rampup_timeout profile profile_filename profile_has_changed profile_notes profile_step profile_title profile_to_save settings_1_page settings_profile_type steam_timeout temperature_target water_temperature water_volume}
}
proc favourites_DSx_settings_vars {} {
    set favourites_DSx_settings_vars {
        saturating_weight_rate
        saturating_weight
        pressurising_weight_rate
        pressurising_weight
        extracting_weight_rate
        extracting_weight
        bean_weight
    }
}

proc save_pinkcup {} {
    set pinkcup_data {}
    append pinkcup_data "settings {\n"
    set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
		if {[info exists ::settings($k)] == 1} {
			set v $::settings($k)
			append pinkcup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append pinkcup_data "}\n"

    append pinkcup_data "DSx_settings {\n"
    set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k $DSx_settings_vars {
		if {[info exists ::DSx_settings($k)] == 1} {
			set v $::DSx_settings($k)
			append pinkcup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append pinkcup_data "}\n"

    set fn "[skin_directory]/DSx_User_set/pink_cup.fav"
	write_file $fn $pinkcup_data
	update_de1_explanation_chart
	set ::DSx_settings(pink_cup_indicator) "."
    set ::DSx_settings(blue_cup_indicator) { }
    set ::DSx_settings(orange_cup_indicator) { }
    pink_font_set
}

proc save_bluecup {} {
    set bluecup_data {}
    append bluecup_data "settings {\n"
    set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
		if {[info exists ::settings($k)] == 1} {
			set v $::settings($k)
			append bluecup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append bluecup_data "}\n"

    append bluecup_data "DSx_settings {\n"
    set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k $DSx_settings_vars {
		if {[info exists ::DSx_settings($k)] == 1} {
			set v $::DSx_settings($k)
			append bluecup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append bluecup_data "}\n"

    set fn "[skin_directory]/DSx_User_set/blue_cup.fav"
	write_file $fn $bluecup_data
	update_de1_explanation_chart
	set ::DSx_settings(pink_cup_indicator) { }
    set ::DSx_settings(blue_cup_indicator) "."
    set ::DSx_settings(orange_cup_indicator) { }
    blue_font_set
}

proc save_orangecup {} {
    set orangecup_data {}
    append orangecup_data "settings {\n"
    set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
		if {[info exists ::settings($k)] == 1} {
			set v $::settings($k)
			append orangecup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append orangecup_data "}\n"

    append orangecup_data "DSx_settings {\n"
    set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k $DSx_settings_vars {
		if {[info exists ::DSx_settings($k)] == 1} {
			set v $::DSx_settings($k)
			append orangecup_data [subst {\t[list $k] [list $v]\n}]
		}
	}
    append orangecup_data "}\n"

    set fn "[skin_directory]/DSx_User_set/orange_cup.fav"
	write_file $fn $orangecup_data
	update_de1_explanation_chart
	set ::DSx_settings(pink_cup_indicator) { }
    set ::DSx_settings(blue_cup_indicator) { }
    set ::DSx_settings(orange_cup_indicator) "."
    orange_font_set
}

proc load_pinkcup {} {
    if {[file exists [skin_directory]/DSx_User_set/pink_cup.fav] != 1} {
        load_test
        page_show DSx_4_workflow
        } else {
        array unset -nocomplain pinkcup_props
        array set pinkcup_props [encoding convertfrom utf-8 [read_binary_file "[skin_directory]/DSx_User_set/pink_cup.fav"]]

        array set settings $pinkcup_props(settings)
        set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
            set ::settings($k) $settings($k)
        }


        array set DSx_settings $pinkcup_props(DSx_settings)
        set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k [favourites_DSx_settings_vars] {
            set ::DSx_settings($k) $DSx_settings($k)
        }

        set ::DSx_settings(wsaw) $::settings(DSx_wsaw)
        set ::DSx_settings(jug_size) $::settings(DSx_jug_size)
        set ::DSx_settings(flush_time) $::settings(DSx_flush_time)
        set_jug
        check_steam_on
        set ::DSx_settings(pink_cup_indicator) "."
        set ::DSx_settings(blue_cup_indicator) { }
        set ::DSx_settings(orange_cup_indicator) { }
        saw_switch
        save_DSx_settings
        save_settings
        save_settings_to_de1
        profile_has_changed_set_colors
        update_de1_explanation_chart
        fill_profiles_listbox
        pink_font_set
        LRv2_preview
        DSx_graph_restore
        refresh_DSx_temperature
    }
}

proc load_bluecup {} {
    if {[file exists [skin_directory]/DSx_User_set/blue_cup.fav] != 1} {
        load_test
        page_show DSx_4_workflow
        } else {
        array unset -nocomplain bluecup_props
        array set bluecup_props [encoding convertfrom utf-8 [read_binary_file "[skin_directory]/DSx_User_set/blue_cup.fav"]]

        array set settings $bluecup_props(settings)
        set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
            set ::settings($k) $settings($k)
        }

        array set DSx_settings $bluecup_props(DSx_settings)
        set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k [favourites_DSx_settings_vars] {
            set ::DSx_settings($k) $DSx_settings($k)
        }

        set ::DSx_settings(wsaw) $::settings(DSx_wsaw)
        set ::DSx_settings(jug_size) $::settings(DSx_jug_size)
        set ::DSx_settings(flush_time) $::settings(DSx_flush_time)
        set_jug
        check_steam_on
        set ::DSx_settings(pink_cup_indicator) { }
        set ::DSx_settings(blue_cup_indicator) "."
        set ::DSx_settings(orange_cup_indicator) { }
        saw_switch
        save_DSx_settings
        save_settings
        save_settings_to_de1
        profile_has_changed_set_colors
        update_de1_explanation_chart
        fill_profiles_listbox
        blue_font_set
        LRv2_preview
        DSx_graph_restore
        refresh_DSx_temperature
    }
}

proc load_orangecup {} {
    if {[file exists [skin_directory]/DSx_User_set/orange_cup.fav] != 1} {
        load_test
        page_show DSx_4_workflow
        } else {
        array unset -nocomplain orangecup_props
        array set orangecup_props [encoding convertfrom utf-8 [read_binary_file "[skin_directory]/DSx_User_set/orange_cup.fav"]]

        array set settings $orangecup_props(settings)
        set settings_vars [favourites_settings_vars]
        foreach k $settings_vars {
            set ::settings($k) $settings($k)
        }

        array set DSx_settings $orangecup_props(DSx_settings)
        set DSx_settings_vars [favourites_DSx_settings_vars]
        foreach k [favourites_DSx_settings_vars] {
            set ::DSx_settings($k) $DSx_settings($k)
        }

        set ::DSx_settings(wsaw) $::settings(DSx_wsaw)
        set ::DSx_settings(jug_size) $::settings(DSx_jug_size)
        set ::DSx_settings(flush_time) $::settings(DSx_flush_time)
        set_jug
        check_steam_on
        set ::DSx_settings(pink_cup_indicator) { }
        set ::DSx_settings(blue_cup_indicator) { }
        set ::DSx_settings(orange_cup_indicator) "."
        saw_switch
        save_DSx_settings
        save_settings
        save_settings_to_de1
        profile_has_changed_set_colors
        update_de1_explanation_chart
        fill_profiles_listbox
        orange_font_set
        LRv2_preview
        DSx_graph_restore
        refresh_DSx_temperature
    }
}

proc off_cup {} {
	set ::DSx_settings(blue_cup_indicator) { }
    set ::DSx_settings(pink_cup_indicator) { }
    set ::DSx_settings(orange_cup_indicator) { }
    save_DSx_settings
}


############################

proc saw_switch {} {
    if {$::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2"} {
        set ::DSx_settings(saw) $::settings(final_desired_shot_weight_advanced)
    } else {
        set ::DSx_settings(saw) $::settings(final_desired_shot_weight)
    }
}
############################

proc dial_config {} {
    if {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/cdsvdsv.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/rdsvdsv.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/odedsv.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/cdedsv.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/rdedsv.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/odsvclb.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/cdsvclb.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/rdsvclb.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/odeclb.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/cdeclb.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/rdeclb.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/odsvde.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/cdsvde.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/rdsvde.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/odede.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/cdede.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/rdede.png"
    } else {
        $::dial read "[skin_directory_graphics]/dial/odsvdsv.png"
    }
    restart_set
}

proc dial_config_start {} {
    if {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/cdsvdsv.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/rdsvdsv.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/odedsv.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/cdedsv.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 1} {
        $::dial read "[skin_directory_graphics]/dial/rdedsv.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/odsvclb.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/cdsvclb.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/rdsvclb.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/odeclb.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/cdeclb.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 2} {
        $::dial read "[skin_directory_graphics]/dial/rdeclb.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/odsvde.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/cdsvde.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 1 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/rdsvde.png"
    } elseif {$::DSx_settings(bezel) == 1 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/odede.png"
    } elseif {$::DSx_settings(bezel) == 2 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/cdede.png"
    } elseif {$::DSx_settings(bezel) == 3 && $::DSx_settings(icons) == 2 && $::DSx_settings(dial) == 3} {
        $::dial read "[skin_directory_graphics]/dial/rdede.png"
    } else {
        $::dial read "[skin_directory_graphics]/dial/odsvdsv.png"
    }
}
proc DSx_bean_set_on {} {
    if {$::DSx_settings(bean_weight) >= 0 && $::DSx_settings(bean_weight) < 34} {
        set ::DSx_saved_2 Loaded
    } else {
        set ::DSx_saved_2 {WARNING - please check your settings!}
    }
}

proc DSx_set_on {} {
    set ::DSx_saved_2 Loaded
}
proc DSx_set_off {} {
    set ::DSx_saved_2 {}
}
proc fav_saved_on {} {
    set ::fave_saved {Saved}
}
proc fav_saved_off {} {
    set ::fave_saved { }
}


proc clear_profile_font {} {
    if {$::settings(profile_has_changed) == 1} {
		.can itemconfigure $::DSx_profile_name -fill $::DSx_settings(red)
		} else {
        .can itemconfigure $::DSx_profile_name -fill $::DSx_settings(font_colour)
    }
    clear_sav_font
}
proc clear_bean_font {} {
    .can itemconfigure $::DSx_bean_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_saw_font {} {
    .can itemconfigure $::DSx_saw_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_sav_font {} {
    .can itemconfigure $::DSx_sav_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_flush_font {} {
    .can itemconfigure $::DSx_flush_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_steam_font {} {
    .can itemconfigure $::DSx_steam_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_water_font {} {
    .can itemconfigure $::DSx_water_name -fill $::DSx_settings(font_colour)
    off_cup
}
proc clear_wsaw_font {} {
    .can itemconfigure $::DSx_wsaw_name -fill $::DSx_settings(font_colour)
    off_cup
}

proc clear_jug_font {} {
    .can itemconfigure $::DSx_jug_name -fill $::DSx_settings(font_colour)
    off_cup
}

proc blue_font_set {} {
    .can itemconfigure $::DSx_profile_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_bean_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_saw_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_sav_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_flush_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_steam_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_water_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_wsaw_name -fill $::DSx_settings(blue)
    .can itemconfigure $::DSx_jug_name -fill $::DSx_settings(blue)
}

proc pink_font_set {} {
    .can itemconfigure $::DSx_profile_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_bean_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_saw_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_sav_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_flush_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_steam_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_water_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_wsaw_name -fill $::DSx_settings(pink)
    .can itemconfigure $::DSx_jug_name -fill $::DSx_settings(pink)
}

proc orange_font_set {} {
    .can itemconfigure $::DSx_profile_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_bean_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_saw_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_sav_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_flush_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_steam_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_water_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_wsaw_name -fill $::DSx_settings(orange)
    .can itemconfigure $::DSx_jug_name -fill $::DSx_settings(orange)
}

######################
### Graph zoom and pan
proc DSx_reset_graphs {} {
    set ::DSxv 0;
    set ::DSx_settings(zoomed_y_axis_max) $::DSx_settings(zoomed_y_axis_scale_default);
    set ::DSx_settings(zoomed_y_axis_min) 0
    set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
    set ::DSx_settings(zoomed_y2_axis_min) [expr {$::DSx_settings(zoomed_y_axis_min)*0.5}]
    $::DSx_espresso_zoomed_graph axis configure y -color #008c4c -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
    $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}
    $::DSx_history_left_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
    $::DSx_history_left_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}
    $::DSx_history_right_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min) -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
    $::DSx_history_right_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}
    DSx_past2_config
}

proc DSx_zoom_in {} {
    if {($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min) > 1)} {
        incr ::DSx_settings(zoomed_y_axis_max) -1
        set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max)
    }
    if {($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min) < 6)} {
        $::DSx_espresso_zoomed_graph axis configure y -majorticks {0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4 4.2 4.4 4.6 4.8 5 5.2 5.4 5.6 5.8 6 6.2 6.4 6.6 6.8 7 7.2 7.4 7.6 7.8 8 8.2 8.4 8.6 8.8 9 9.2 9.4 9.6 9.8 10 10.2 10.4 10.6 10.8 11 11.2 11.4 11.6 11.8 12 12.2 12.4 12.6 12.8 13 13.2 13.4 13.6 13.8 14 14.2 14.4 14.6 14.8 15}
        $::DSx_espresso_zoomed_graph axis configure y2 -majorticks {0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 0.1 0.2 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7 7.1 7.2 7.3 7.4 7.5}

    }
}

proc DSx_zoom_out {} {
    if {($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min) < 15)} {
        # 15 is the max Y axis allowed
        if {$::DSx_settings(zoomed_y_axis_max) > 14} {
            incr ::DSx_settings(zoomed_y_axis_min) -1
            set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
            } else {
            incr ::DSx_settings(zoomed_y_axis_max)
            set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
        }
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
    if {($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min) > 5)} {
        $::DSx_espresso_zoomed_graph axis configure y -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
        $::DSx_espresso_zoomed_graph axis configure y2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}
    }
}

proc DSx_scroll_up {} {
    if {$::DSx_settings(zoomed_y_axis_min) < 14 && $::DSx_settings(zoomed_y_axis_max) < 15 && ($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min)) >= 1} {
        # 15 is the max Y axis allowed
        incr ::DSx_settings(zoomed_y_axis_min) 1
        incr ::DSx_settings(zoomed_y_axis_max) 1
        set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
        set ::DSx_settings(zoomed_y2_axis_min) [expr {$::DSx_settings(zoomed_y_axis_min)*0.5}]
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}

proc DSx_scroll_down {} {
    if {$::DSx_settings(zoomed_y_axis_min) > 0 && $::DSx_settings(zoomed_y_axis_max) > 1 && ($::DSx_settings(zoomed_y_axis_max) - $::DSx_settings(zoomed_y_axis_min)) >= 1} {
        incr ::DSx_settings(zoomed_y_axis_min) -1
        incr ::DSx_settings(zoomed_y_axis_max) -1
        set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
        set ::DSx_settings(zoomed_y2_axis_min) [expr {$::DSx_settings(zoomed_y_axis_min)*0.5}]
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}

proc DSx_R {} {
    if {$::de1(flow) == 0} {
    return 0.0LΩ
    } else {
    return [round_to_one_digits [expr ($::de1(pressure)/$::de1(flow))]]LΩ
    }
}


################
### Graph buttons
proc DSx_graph_reset_button_text {} {
    if {$::DSx_settings(zoomed_y_axis_max) == $::DSx_settings(zoomed_y_axis_scale_default) && $::DSx_settings(zoomed_y_axis_min) == 0 && $::DSx_settings(glt2) > 0} {
        .can itemconfigure $::DSx_graph_reset_button_text -fill #e73249
        return "Zoom Temp."
    } else {
        .can itemconfigure $::DSx_graph_reset_button_text -fill $::DSx_settings(font_colour)
        return "RESET"
    }
}

proc DSx_graph_reset_button {} {
    if {$::DSx_settings(zoomed_y_axis_max) == $::DSx_settings(zoomed_y_axis_scale_default) && $::DSx_settings(zoomed_y_axis_min) == 0 && $::DSx_settings(glt2) > 0} {
    set ::DSx_settings(zoomed_y_axis_max) 10
    set ::DSx_settings(zoomed_y_axis_min) 8
    set ::DSx_settings(zoomed_y2_axis_max) [expr {$::DSx_settings(zoomed_y_axis_max)*0.5}]
    set ::DSx_settings(zoomed_y2_axis_min) [expr {$::DSx_settings(zoomed_y_axis_min)*0.5}]
    $::DSx_espresso_zoomed_graph axis configure y -color #e73249 -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min) -majorticks {7 7.2 7.4 7.6 7.8 8 8.2 8.4 8.6 8.8 9 9.2 9.4 9.6 9.8 10}
    $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min) -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}


    } else {
        DSx_reset_graphs;
    }
}

proc DSx_graph_temp_units_text {} {
    if {$::DSx_settings(glt2) == 0} {
        return ""
    } else {
        if {$::settings(enable_fahrenheit) == 1} {
            return "(x20)°F"
        } else {
            return "(x10)°C"
        }
    }
}


proc push_t1 {} {
    if {$::DSx_settings(glt1) > 0} {
        set ::DSx_settings(glt1) 0
        $::DSx_espresso_zoomed_graph element configure line2_espresso_pressure -linewidth $::DSx_settings(glt1)
    } else {
        set ::DSx_settings(glt1) 4
        $::DSx_espresso_zoomed_graph element configure line2_espresso_pressure -linewidth $::DSx_settings(glt1)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_t2 {} {
    if {$::DSx_settings(glt2) > 0} {
        set ::DSx_settings(glt2) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_basket -linewidth $::DSx_settings(glt2)
    } else {
        set ::DSx_settings(glt2) 4
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_basket -linewidth $::DSx_settings(glt2)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_t3 {} {
    if {$::DSx_settings(glt3) > 0} {
        set ::DSx_settings(glt3) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_state_change_1 -linewidth $::DSx_settings(glt3)
    } else {
        set ::DSx_settings(glt3) 4
        $::DSx_espresso_zoomed_graph element configure line_espresso_state_change_1 -linewidth $::DSx_settings(glt3)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_t4 {} {
    if {$::DSx_settings(glt4) > 0} {
        set ::DSx_settings(glt4) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_weight_2x -linewidth $::DSx_settings(glt4)
    } else {
        set ::DSx_settings(glt4) 4
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_weight_2x -linewidth $::DSx_settings(glt4)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_t5 {} {
    if {$::DSx_settings(glt5) > 0} {
        set ::DSx_settings(glt5) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_2x -linewidth $::DSx_settings(glt5)
    } else {
        set ::DSx_settings(glt5) 4
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_2x -linewidth $::DSx_settings(glt5)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}

proc push_b1 {} {
    if {$::DSx_settings(glb1) > 0} {
        set ::DSx_settings(glb1) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_resistance -linewidth $::DSx_settings(glb1)
    } else {
        set ::DSx_settings(glb1) 2
        $::DSx_espresso_zoomed_graph element configure line_espresso_resistance -linewidth $::DSx_settings(glb1)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}

proc push_b2 {} {
    if {$::DSx_settings(glb2) > 0} {
        set ::DSx_settings(glb2) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_mix -linewidth $::DSx_settings(glb2)
    } else {
        set ::DSx_settings(glb2) 2
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_mix -linewidth $::DSx_settings(glb2)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_b3 {} {
    if {$::DSx_settings(glb3) > 0} {
        set ::DSx_settings(glb3) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_goal_2x -linewidth $::DSx_settings(glb3)
        $::DSx_espresso_zoomed_graph element configure line_espresso_pressure_goal -linewidth $::DSx_settings(glb3)
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_goal -linewidth $::DSx_settings(glb3)
    } else {
        set ::DSx_settings(glb3) 2
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_goal_2x -linewidth $::DSx_settings(glb3)
        $::DSx_espresso_zoomed_graph element configure line_espresso_pressure_goal -linewidth $::DSx_settings(glb3)
        $::DSx_espresso_zoomed_graph element configure line_espresso_temperature_goal -linewidth $::DSx_settings(glb3)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_b4 {} {
    if {$::DSx_settings(glb4) > 0} {
        set ::DSx_settings(glb4) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_weight_2x -linewidth $::DSx_settings(glb4)
    } else {
        set ::DSx_settings(glb4) 2
        $::DSx_espresso_zoomed_graph element configure line_espresso_weight_2x -linewidth $::DSx_settings(glb4)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
proc push_b5 {} {
    if {$::DSx_settings(glb5) > 0} {
        set ::DSx_settings(glb5) 0
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_delta_1 -linewidth $::DSx_settings(glb5)
    } else {
        set ::DSx_settings(glb5) 2
        $::DSx_espresso_zoomed_graph element configure line_espresso_flow_delta_1 -linewidth $::DSx_settings(glb5)
        $::DSx_espresso_zoomed_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min $::DSx_settings(zoomed_y_axis_min)
        $::DSx_espresso_zoomed_graph axis configure y2 -max $::DSx_settings(zoomed_y2_axis_max) -min $::DSx_settings(zoomed_y2_axis_min)
    }
}
#########
proc graph_weight_key {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history" } {
        return {Weight (g/s)}
    } else {
        return {}
    }
}
proc graph_flow_key_espresso {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history" } {
        return {Flow (mL/s)}
    } else {
        return {}
    }
}
proc graph_flow_key_steam {} {
    if {$::DSx_settings(history_godshots) == "DSx_steam_history" } {
        return {Flow (mL/s)}
    } else {
        return {}
    }
}
proc graph_temp_key_espresso {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history"} {
        return $::DSx_settings(hist_temp_key)
    } else {
        return {}
    }
}
proc graph_temp_key_steam {} {
    if {$::DSx_settings(history_godshots) == "DSx_steam_history" } {
        if {$::settings(enable_fahrenheit) == 1} {
            return {Temperature °F}
        } else {
            return {Temperature °C}
        }
    } else {
        return {}
    }
}
proc past_profile_title_right {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history"} {
        return "$::DSx_settings(past_profile_title2)"
    } else {
        return ""
    }
}
proc past_steam_settings_data {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history"} {
        return ""
    } else {
        return "Counter $::DSx_settings(DSx_past2_steaming_count_setting)      Calibration:  [return_steam_heater_calibration $::DSx_settings(DSx_past2_steam_temperature_setting)]   [return_steam_flow_calibration $::DSx_settings(DSx_past2_steam_flow_setting)]\rOff timer $::DSx_settings(DSx_past2_steam_timeout_setting)s     Run time $::DSx_settings(DSx_right_shot_time)"
    }
}
proc past_shot_data_right {} {
    if {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
        return ""
    } else {
        return "$::DSx_settings(DSx_right_shot_time)    $::DSx_settings(past_bean_weight2)g : $::DSx_settings(drink_weight2)g (1:[round_to_one_digits [expr (0.01 + $::DSx_settings(drink_weight2))/$::DSx_settings(past_bean_weight2)]])"
    }
}
proc past_shot_volume_right {} {
    if {$::DSx_settings(history_godshots) != "DSx_steam_history"} {
        return "[round_to_integer $::DSx_settings(past_volume2)]mL"
    } else {
        return ""
    }
}

proc history_prep {} {
    borg spinner on
    fill_DSx_past_shots_listbox
    fill_DSx_past2_shots_listbox
    page_show DSx_past
    DSx_reset_graphs
    borg spinner off
    borg systemui $::android_full_screen_flags
}

proc DSx_past_shot_reference_reset {} {
	DSx_past_espresso_pressure length 0
	DSx_past_espresso_temperature_basket length 0
	DSx_past_espresso_temperature_mix length 0
	DSx_past_espresso_flow length 0
	DSx_past_espresso_flow_weight length 0
	DSx_past_espresso_flow_2x length 0
	DSx_past_espresso_flow_weight_2x length 0
    DSx_past_espresso_resistance length 0

    DSx_past_espresso_state_change length 0

    if {$::settings(enable_fahrenheit) == 1} {
        set ::c_f_adjust 0.05
        } else {
        set ::c_f_adjust 0.1
    }
	if {[info exists ::DSx_settings(DSx_past_espresso_elapsed)] == 1} {
		espresso_elapsed1 length 0
		espresso_elapsed1 append $::DSx_settings(DSx_past_espresso_elapsed)
	    append st [espresso_elapsed1 range end end]
		set ::DSx_settings(DSx_left_shot_time) "[round_to_one_digits [expr ($st+0.05)]] sec"
	}
	DSx_past_espresso_pressure append $::DSx_settings(DSx_past_espresso_pressure)
	DSx_past_espresso_temperature_basket append  $::DSx_settings(DSx_past_espresso_temperature_basket)
	DSx_past_espresso_temperature_mix append  $::DSx_settings(DSx_past_espresso_temperature_mix)
	if {$::DSx_settings(DSx_past_espresso_flow) != {} } {
		DSx_past_espresso_flow append $::DSx_settings(DSx_past_espresso_flow)
		foreach flow $::DSx_settings(DSx_past_espresso_flow) pressure1 $::DSx_settings(DSx_past_espresso_pressure) {
			DSx_past_espresso_flow_2x append [expr {2.0 * $flow}]
		}
	}
    foreach a $::DSx_settings(DSx_past_espresso_pressure) b $::DSx_settings(DSx_past_espresso_weight) c $::DSx_settings(DSx_past_espresso_flow) {
        set y 0
        catch {
            #set y [expr {$a/($c*$c)}]
            set y [expr {$a/$c}]
        }
        DSx_past_espresso_resistance append $y
    }
	if {$::DSx_settings(DSx_past_espresso_flow_weight) != {} } {
		DSx_past_espresso_flow_weight append $::DSx_settings(DSx_past_espresso_flow_weight)
		foreach flow_weight $::DSx_settings(DSx_past_espresso_flow_weight) {
			DSx_past_espresso_flow_weight_2x append [expr {2.0 * $flow_weight}]
		}
	}
    if {[info exists ::DSx_settings(DSx_past_espresso_pressure_goal)] == 1} {
        DSx_past_espresso_pressure_goal length 0
        DSx_past_espresso_pressure_goal append $::DSx_settings(DSx_past_espresso_pressure_goal)
    }
    if {[info exists ::DSx_settings(DSx_past_espresso_flow_goal)] == 1} {
        DSx_past_espresso_flow_goal length 0
        DSx_past_espresso_flow_goal_2x length 0
        DSx_past_espresso_flow_goal append $::DSx_settings(DSx_past_espresso_flow_goal)
        foreach flow_goal $::DSx_settings(DSx_past_espresso_flow_goal) {
            DSx_past_espresso_flow_goal_2x append [expr {2.0 * $flow_goal}]
        }
    }
    if {[info exists ::DSx_settings(DSx_past_espresso_temperature_goal)] == 1} {
        DSx_past_espresso_temperature_goal length 0
        DSx_past_espresso_temperature_goal_01 length 0
        DSx_past_espresso_temperature_goal append $::DSx_settings(DSx_past_espresso_temperature_goal)
        foreach temperature_goal $::DSx_settings(DSx_past_espresso_temperature_goal) {
            DSx_past_espresso_temperature_goal_01 append [expr {$::c_f_adjust * $temperature_goal}]
        }
    }
    if {[info exists ::DSx_settings(DSx_past_espresso_temperature_basket)] == 1} {
        DSx_past_espresso_temperature_basket length 0
        DSx_past_espresso_temperature_basket_01 length 0
        DSx_past_espresso_temperature_basket append $::DSx_settings(DSx_past_espresso_temperature_basket)
        foreach temperature_basket $::DSx_settings(DSx_past_espresso_temperature_basket) {
            DSx_past_espresso_temperature_basket_01 append [expr {$::c_f_adjust * $temperature_basket}]
        }
	}
	if {[info exists ::DSx_settings(DSx_past_espresso_state_change)] == 1} {
		DSx_past_espresso_state_change length 0
        DSx_past_espresso_state_change append $::DSx_settings(DSx_past_espresso_state_change)
	}
}

proc DSx_past2_shot_reference_reset {} {
	DSx_past2_espresso_pressure length 0
	DSx_past2_espresso_temperature_basket length 0
	DSx_past2_espresso_temperature_mix length 0
	DSx_past2_espresso_flow length 0
	DSx_past2_espresso_flow_weight length 0
	DSx_past2_espresso_flow_2x length 0
	DSx_past2_espresso_flow_weight_2x length 0
    DSx_past2_espresso_resistance length 0
    DSx_past2_espresso_state_change length 0
    DSx_past2_steam_pressure length 0
    DSx_past2_steam_flow length 0
    DSx_past2_steam_temperature length 0

    if {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
        DSx_past2_steam_pressure append $::DSx_settings(DSx_past2_steam_pressure)
        DSx_past2_steam_flow append $::DSx_settings(DSx_past2_steam_flow)
        foreach temp $::DSx_settings(DSx_past2_steam_temperature) {
            if {$::settings(enable_fahrenheit) == 1} {
                DSx_past2_steam_temperature append [expr {((($temp  - 32)/ 1.8) - 130)/10}]
            } else {
                DSx_past2_steam_temperature append [expr {($temp - 130)/10}]
            }
        }
    }


	if {[info exists ::DSx_settings(DSx_past2_espresso_elapsed)] == 1} {
		espresso_elapsed2 length 0
		espresso_elapsed2 append $::DSx_settings(DSx_past2_espresso_elapsed)
	    append st [espresso_elapsed2 range end end]
		set ::DSx_settings(DSx_right_shot_time) "[round_to_one_digits [expr ($st+0.05)]]s"
	}
	DSx_past2_espresso_pressure append $::DSx_settings(DSx_past2_espresso_pressure)
	DSx_past2_espresso_temperature_basket append $::DSx_settings(DSx_past2_espresso_temperature_basket)
	DSx_past2_espresso_temperature_mix append $::DSx_settings(DSx_past2_espresso_temperature_mix)
	if {$::DSx_settings(DSx_past2_espresso_flow) != {} } {
		DSx_past2_espresso_flow append $::DSx_settings(DSx_past2_espresso_flow)
		foreach flow $::DSx_settings(DSx_past2_espresso_flow) pressure1 $::DSx_settings(DSx_past2_espresso_pressure) {
		    DSx_past2_espresso_flow_2x append [expr {2.0 * $flow}]
		}
	}
    foreach a $::DSx_settings(DSx_past2_espresso_pressure) b $::DSx_settings(DSx_past2_espresso_weight) c $::DSx_settings(DSx_past2_espresso_flow) {
        set y 0
        catch {
            #set y [expr {$a/($c*$c)}]
            set y [expr {$a/$c}]
        }
        DSx_past2_espresso_resistance append $y
    }
	if {$::DSx_settings(DSx_past2_espresso_flow_weight) != {} } {
		DSx_past2_espresso_flow_weight append $::DSx_settings(DSx_past2_espresso_flow_weight)
		foreach flow_weight $::DSx_settings(DSx_past2_espresso_flow_weight) {
			DSx_past2_espresso_flow_weight_2x append [expr {2.0 * $flow_weight}]
		}
	}
    if {[info exists ::DSx_settings(DSx_past2_espresso_pressure_goal)] == 1} {
        DSx_past2_espresso_pressure_goal length 0
        DSx_past2_espresso_pressure_goal append $::DSx_settings(DSx_past2_espresso_pressure_goal)
    }
    if {[info exists ::DSx_settings(DSx_past2_espresso_flow_goal)] == 1} {
        DSx_past2_espresso_flow_goal length 0
        DSx_past2_espresso_flow_goal_2x length 0
        DSx_past2_espresso_flow_goal append $::DSx_settings(DSx_past2_espresso_flow_goal)
        foreach flow_goal2 $::DSx_settings(DSx_past2_espresso_flow_goal) {
            DSx_past2_espresso_flow_goal_2x append [expr {2.0 * $flow_goal2}]
        }
    }
    if {[info exists ::DSx_settings(DSx_past2_espresso_temperature_goal)] == 1} {
        DSx_past2_espresso_temperature_goal length 0
        DSx_past2_espresso_temperature_goal_01 length 0
        DSx_past2_espresso_temperature_goal append $::DSx_settings(DSx_past2_espresso_temperature_goal)
        foreach temperature_goal2 $::DSx_settings(DSx_past2_espresso_temperature_goal) {
            DSx_past2_espresso_temperature_goal_01 append [expr {$::c_f_adjust * $temperature_goal2}]
        }
    }
    if {[info exists ::DSx_settings(DSx_past2_espresso_temperature_basket)] == 1} {
        DSx_past2_espresso_temperature_basket length 0
        DSx_past2_espresso_temperature_basket_01 length 0
        DSx_past2_espresso_temperature_basket append $::DSx_settings(DSx_past2_espresso_temperature_basket)
        foreach temperature_basket2 $::DSx_settings(DSx_past2_espresso_temperature_basket) {
            DSx_past2_espresso_temperature_basket_01 append [expr {$::c_f_adjust * $temperature_basket2}]
        }
	}
	if {[info exists ::DSx_settings(DSx_past2_espresso_state_change)] == 1} {
		DSx_past2_espresso_state_change length 0
        DSx_past2_espresso_state_change append $::DSx_settings(DSx_past2_espresso_state_change)
	}
}

proc history_godshots_switch {} {
    if {$::DSx_settings(history_godshots) == "godshots"} {
    set ::DSx_settings(history_godshots) history
    clear_graph
    DSx_past2_config
    } elseif {$::DSx_settings(history_godshots) == "history"} {
    set ::DSx_settings(history_godshots) DSx_steam_history
    clear_graph
    DSx_past2_config
    } elseif {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
    set ::DSx_settings(history_godshots) godshots
    clear_graph
    DSx_past2_config
    }
}
proc history_godshot_steam {} {
    if {$::DSx_settings(history_godshots) == "godshots"} {
        set lbl godshot
    } elseif {$::DSx_settings(history_godshots) == "history"} {
        set lbl history
    } elseif {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
        set lbl steam

    }
    return $lbl
}

proc DSx_past2_config {} {
    if {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
        if {$::settings(enable_fahrenheit) == 1} {
            $::DSx_history_right_graph axis configure y2 -color #e73249 -tickfont [DSx_font font 6] -min 266 -max 356 -majorticks {266 275 284 293 302 311 320 329 338 347 356};
            $::DSx_history_right_zoomed_graph axis configure y2 -color #e73249 -tickfont [DSx_font font 6] -min 266 -max 356 -majorticks {266 275 284 293 302 311 320 329 338 347 356};
        } else {
            $::DSx_history_right_graph axis configure y2 -color #e73249 -min 130 -max 180 -majorticks {130 135 140 145 150 155 160 165 170 175 180};
            $::DSx_history_right_zoomed_graph axis configure y2 -color #e73249 -min 130 -max 180 -majorticks {130 135 140 145 150 155 160 165 170 175 180};
        }
        $::DSx_history_right_graph axis configure y -max 5 -min 0.0 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5}
        $::DSx_history_right_zoomed_graph axis configure y -max 5 -min 0.0 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5}
    } else {
        $::DSx_history_right_graph axis configure y -max $::DSx_settings(zoomed_y_axis_max) -min 0.0 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
        $::DSx_history_right_graph axis configure y2 -color #4e85f4 -max $::DSx_settings(zoomed_y2_axis_max) -min 0.0 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}

        $::DSx_history_right_zoomed_graph axis configure y -max 17 -min 0.0 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}
        $::DSx_history_right_zoomed_graph axis configure y2 -color #4e85f4 -max 8.5 -min 0.0 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8}
    }
}

proc history_graph_temperature {} {
    if {$::DSx_settings(show_history_temperature) == "on"} {
        set ::DSx_settings(show_history_temperature)  off
        set ::DSx_settings(hist_temp_key) ""
        set ::DSx_settings(hist_temp_curve) 0
        set ::DSx_settings(hist_temp_goal_curve) 0
    } else {
        set ::DSx_settings(show_history_temperature) on
        if {$::settings(enable_fahrenheit) == 1} {
            set ::DSx_settings(hist_temp_key) {Temperature (x20)°F}
            } else {
            set ::DSx_settings(hist_temp_key) {Temperature (x10)°C}
        }
        set ::DSx_settings(hist_temp_curve) 3
        if {$::DSx_settings(show_history_goal) == "on"} {
            set ::DSx_settings(hist_temp_goal_curve) 3
        }
    }
    $::DSx_history_left_graph element configure DSx_past_line_espresso_temperature_basket_01 -linewidth $::DSx_settings(hist_temp_curve)
    $::DSx_history_left_graph element configure DSx_past_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_temperature_basket_01 -linewidth $::DSx_settings(hist_temp_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_temperature_basket_01 -linewidth $::DSx_settings(hist_temp_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_temperature_basket_01 -linewidth $::DSx_settings(hist_temp_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_left_graph axis configure y -min 0.0
    $::DSx_history_right_graph axis configure y -min 0.0
    $::DSx_history_left_zoomed_graph axis configure y -min 0.0
    $::DSx_history_right_zoomed_graph axis configure y -min 0.0
}

proc history_graph_goal {} {
    if {$::DSx_settings(show_history_goal) == "on"} {
        set ::DSx_settings(show_history_goal)  off
        set ::DSx_settings(hist_goal_curve) 0
        set ::DSx_settings(hist_temp_goal_curve) 0
    } else {
        set ::DSx_settings(show_history_goal) on
        set ::DSx_settings(hist_goal_curve) 3
        if {$::DSx_settings(show_history_temperature) == "on"} {
            set ::DSx_settings(hist_temp_goal_curve) 3
        }
    }
    $::DSx_history_left_graph element configure DSx_past_line_espresso_pressure_goal -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_graph element configure DSx_past_line_espresso_flow_goal_2x -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_graph element configure DSx_past_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_left_graph element configure DSx_past_line_espresso_state_change_1 -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_pressure_goal -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_flow_goal_2x -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_state_change_1 -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_pressure_goal -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_flow_goal_2x -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_state_change_1 -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_pressure_goal -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_flow_goal_2x -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_temperature_goal_01 -linewidth $::DSx_settings(hist_temp_goal_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_state_change_1 -linewidth $::DSx_settings(hist_goal_curve)
    $::DSx_history_left_graph axis configure y -min 0.0
    $::DSx_history_right_graph axis configure y -min 0.0
    $::DSx_history_left_zoomed_graph axis configure y -min 0.0
    $::DSx_history_right_zoomed_graph axis configure y -min 0.0
}

proc history_graph_resistance {} {
    if {$::DSx_settings(show_history_resistance) == "on"} {
        set ::DSx_settings(show_history_resistance)  off
        set ::DSx_settings(hist_resistance_key) ""
        set ::DSx_settings(hist_resistance_curve) 0
    } else {
        set ::DSx_settings(show_history_resistance) on
        set ::DSx_settings(hist_resistance_key) "Resistance"
        set ::DSx_settings(hist_resistance_curve) 2
    }
    $::DSx_history_left_graph element configure DSx_past_line_espresso_resistance -linewidth $::DSx_settings(hist_resistance_curve)
    $::DSx_history_right_graph element configure DSx_past2_line_espresso_resistance -linewidth $::DSx_settings(hist_resistance_curve)
    $::DSx_history_left_zoomed_graph element configure DSx_past_line_espresso_resistance -linewidth $::DSx_settings(hist_resistance_curve)
    $::DSx_history_right_zoomed_graph element configure DSx_past2_line_espresso_resistance -linewidth $::DSx_settings(hist_resistance_curve)
    $::DSx_history_left_graph axis configure y -min 0.0
    $::DSx_history_right_graph axis configure y -min 0.0
    $::DSx_history_left_zoomed_graph axis configure y -min 0.0
    $::DSx_history_right_zoomed_graph axis configure y -min 0.0
}

proc clear_graph {} {
    set ::DSx_settings(DSx_past2_espresso_pressure) {0.0}
    set ::DSx_settings(DSx_past2_espresso_temperature_basket) {0.0}
    set ::DSx_settings(DSx_past2_espresso_temperature_mix) {0.0}
    set ::DSx_settings(DSx_past2_espresso_flow) {0.0}
    set ::DSx_settings(DSx_past2_espresso_flow_weight) {0.0}
    set ::DSx_settings(DSx_past2_espresso_weight) {0.0}
    set ::DSx_settings(DSx_past2_espresso_elapsed) {0.0}
    set ::DSx_settings(shot_date_time2) {}
    set ::DSx_settings(drink_weight2) 0
    set ::DSx_settings(past_bean_weight2) 0
    set ::DSx_settings(past_profile_title2) {}
    set ::DSx_settings(DSx_past2_espresso_flow_goal) {0.0}
    set ::DSx_settings(DSx_past2_espresso_pressure_goal) {0.0}
    set ::DSx_settings(DSx_past2_espresso_temperature_goal) {0.0}
    set ::DSx_settings(DSx_past2_espresso_state_change) {0.0}
    set ::DSx_settings(past_sav_all) 0
    set ::DSx_settings(past_sav_drops) 0
    set ::DSx_settings(past_sav_out) 0
    save_DSx_settings
    DSx_past2_shot_reference_reset
    set DSx_pastprops2(name) ""
    set ::DSx_settings(DSx_past2_espresso_name) ""
    set ::DSx_settings(past_shot_desc2) {}
    set ::DSx_settings(DSx_past2_steam_pressure) {0.0}
    set ::DSx_settings(DSx_past2_steam_flow) {0.0}
    set ::DSx_settings(DSx_past2_steam_temperature) {0.0}
    set ::DSx_settings(DSx_past2_steaming_count_setting) {}
    set ::DSx_settings(DSx_past2_steam_timeout_setting) {}
    set ::DSx_settings(DSx_past2_steam_temperature_setting) {}
    set ::DSx_settings(DSx_past2_steam_flow_setting) {}
    set ::DSx_settings(DSx_past2_steam_highflow_start_setting) {}
   ### Added by Enrique ###
	set ::DSx_settings(past_shot_file2) {}
	foreach field_name $::DSx_settings(extra_past_shot_fields) {
		set ::DSx_settings(past_${field_name}2) {}
	}
   ### End addition ###
}

proc DSx_past_shot_files {} {
	### Support for Enrique's describe your espresso plugin
	if {[info exists ::DSx_filtered_past_shot_files] == 1} {
	    return $::DSx_filtered_past_shot_files
    }
    ###
	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/history/" *.shot]]
	set dd {}
	foreach f $files {
	    set fn "[homedir]/history/$f"
	    array unset -nocomplain DSx_pastprops
	    array set DSx_pastprops [read_file $fn]
	    set name [ifexists DSx_pastprops(name)]
	    if {$name == "None"} {
	    	set name [translate "None"]
	    } elseif {$name == ""} {
	    	set name [file rootname $f]
	    }
		lappend dd $name $f
	}
	return $dd
}

proc DSx_past2_shot_files {} {
	### Support for Enrique's describe your espresso plugin
	if {$::DSx_settings(history_godshots) == "history" && [info exists ::DSx_filtered_past_shot_files2] == 1} {
        return $::DSx_filtered_past_shot_files2
    }
    ###
	if {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
	    set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/$::DSx_settings(history_godshots)/" *.steam]]
	} else {
	    set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/$::DSx_settings(history_godshots)/" *.shot]]
	}
	if {$::DSx_settings(history_godshots) != "godshots"} {
	    set ::DSx_settings(list_order) -decreasing
	    } else {
	    set ::DSx_settings(list_order) -increasing
	}
	set dd2 {}
	foreach f2 $files {
	    set fn2 "[homedir]/$::DSx_settings(history_godshots)/$f2"
	    array unset -nocomplain DSx_pastprops2
	    array set DSx_pastprops2 [read_file $fn2]
	    set name [ifexists DSx_pastprops2(name)]
	    if {$name == "None"} {
	    	set name [translate "None"]
	    } elseif {$name == ""} {
	    	set name [file rootname $f2]
	    }
		lappend dd2 $name $f2
	}
	return $dd2
}


proc fill_DSx_past_shots_listbox {} {
	unset -nocomplain ::DSx_past_shot_filenames
	set widget $::globals(DSx_past_shots_widget)
	$widget delete 0 99999
	set cnt 0
	array set DSx_past_shot_files_array [DSx_past_shot_files]
	foreach desc [lsort -decreasing -dictionary [array names DSx_past_shot_files_array]] {
		set fn $DSx_past_shot_files_array($desc)
		$widget insert $cnt $desc
		set ::DSx_past_shot_filenames($cnt) $fn
		if {$desc == $::DSx_settings(DSx_past_espresso_name)} {
			$widget selection set $cnt
			$widget see $cnt
			load_DSx_past_shot 1
		}
		incr cnt
	}
}

proc fill_DSx_past2_shots_listbox {} {
	unset -nocomplain ::DSx_past2_shot_filenames
	set widget $::globals(DSx_past2_shots_widget)
	$widget delete 0 99999
	set cnt 0
	array set DSx_past2_shot_files_array [DSx_past2_shot_files]
	foreach desc [lsort $::DSx_settings(list_order) -dictionary [array names DSx_past2_shot_files_array]] {
		set fn $DSx_past2_shot_files_array($desc)
		$widget insert $cnt $desc
		set ::DSx_past2_shot_filenames($cnt) $fn
		if {$desc == $::DSx_settings(DSx_past2_espresso_name)} {
			$widget selection set $cnt
			$widget see $cnt
			load_DSx_past2_shot 1
		}
		incr cnt
	}
}

proc load_DSx_past_shot { {force 0} } {
	if {$::de1(current_context) != "DSx_past" && $force == 0} {
		return
	}
	set stepnum [$::globals(DSx_past_shots_widget) curselection]
	if {$stepnum == ""} {
		return
	}
	set f [ifexists ::DSx_past_shot_filenames($stepnum)]
	if {$stepnum == ""} {
		return
	}
    ### modefied archive files for Enrique's plugin
	if { [file exists "[homedir]/history/$f"] } {
        set fn "[homedir]/history/$f"
    } elseif { [file exists "[homedir]/history_archive/$f"] } {
        set fn "[homedir]/history_archive/$f"
    }
    ###
	array unset -nocomplain DSx_pastprops
	array set DSx_pastprops [encoding convertfrom utf-8 [read_binary_file $fn]]
    set ::DSx_settings(DSx_past_espresso_pressure) $DSx_pastprops(espresso_pressure)
    set ::DSx_settings(DSx_past_espresso_temperature_basket) $DSx_pastprops(espresso_temperature_basket)
    set ::DSx_settings(DSx_past_espresso_temperature_mix) $DSx_pastprops(espresso_temperature_mix)
    set ::DSx_settings(DSx_past_espresso_flow_weight) $DSx_pastprops(espresso_flow_weight)
    set ::DSx_settings(DSx_past_espresso_flow) $DSx_pastprops(espresso_flow)
    set ::DSx_settings(DSx_past_espresso_weight) $DSx_pastprops(espresso_weight)
    if {[llength [ifexists DSx_pastprops(espresso_elapsed)]] > 0} {
    	set ::DSx_settings(DSx_past_espresso_elapsed) $DSx_pastprops(espresso_elapsed)
    }
    if {[info exists DSx_pastprops(espresso_temperature_goal)] == 1} {
        set ::DSx_settings(DSx_past_espresso_pressure_goal) $DSx_pastprops(espresso_pressure_goal)
        set ::DSx_settings(DSx_past_espresso_flow_goal) $DSx_pastprops(espresso_flow_goal)
        set ::DSx_settings(DSx_past_espresso_temperature_goal) $DSx_pastprops(espresso_temperature_goal)
        set ::DSx_settings(DSx_past_espresso_state_change) {0.0}
        if {[info exists DSx_pastprops(espresso_state_change)] == 1} {
            set ::DSx_settings(DSx_past_espresso_state_change) $DSx_pastprops(espresso_state_change)
        }
    } else {
        set ::DSx_settings(DSx_past_espresso_pressure_goal) {0.0}
        set ::DSx_settings(DSx_past_espresso_flow_goal) {0.0}
        set ::DSx_settings(DSx_past_espresso_temperature_goal) {0.0}
        set ::DSx_settings(DSx_past_espresso_state_change) {0.0}
    }
    array set DSx_past_sets $DSx_pastprops(settings)
    set ::DSx_settings(drink_weight) $DSx_past_sets(drink_weight)
    if {[info exists DSx_past_sets(grinder_dose_weight)] == 0} {
        set DSx_past_sets(grinder_dose_weight) 0
        if {[info exists DSx_past_sets(DSx_bean_weight)] == 1} {
            set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(DSx_bean_weight)
        }
        if {[info exists DSx_past_sets(dsv4_bean_weight)] == 1} {
            set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv4_bean_weight)
        }
        if {[info exists DSx_past_sets(dsv3_bean_weight)] == 1} {
            set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv3_bean_weight)
        }
        if {[info exists DSx_past_sets(dsv2_bean_weight)] == 1} {
            set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv2_bean_weight)
        }
    } else {
        if {$DSx_past_sets(grinder_dose_weight) < 1} {
            if {[info exists DSx_past_sets(DSx_bean_weight)] == 1} {
                set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(DSx_bean_weight)
            }
            if {[info exists DSx_past_sets(dsv4_bean_weight)] == 1} {
                set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv4_bean_weight)
            }
            if {[info exists DSx_past_sets(dsv3_bean_weight)] == 1} {
                set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv3_bean_weight)
            }
            if {[info exists DSx_past_sets(dsv2_bean_weight)] == 1} {
                set DSx_past_sets(grinder_dose_weight) $DSx_past_sets(dsv2_bean_weight)
            }
        }
    }
    set ::DSx_settings(past_bean_weight) [round_to_one_digits $DSx_past_sets(grinder_dose_weight)]
    set ::DSx_settings(past_profile_title) $DSx_past_sets(profile_title)
    set ::DSx_settings(shot_date_time) [clock format $DSx_pastprops(clock) -format {%a, %d %b %Y   %I:%M%p}]
    if {[info exists DSx_past_sets(calibration_flow_multiplier)] == 1} {
        set ::DSx_settings(past_calibration_flow_multiplier) $DSx_past_sets(calibration_flow_multiplier)
    } else {
        set ::DSx_settings(past_calibration_flow_multiplier) "unknown"
    }
### setup additional history data from "Your setup & This espresso". Added by Enrique ###	
    set ::DSx_settings(past_shot_file) $fn
	set ::DSx_settings(past_clock) $DSx_pastprops(clock)
	foreach field_name $::DSx_settings(extra_past_shot_fields) {
		if { [info exists DSx_past_sets($field_name)] } {
			set ::DSx_settings(past_$field_name) $DSx_past_sets($field_name)
		} else {
			set ::DSx_settings(past_$field_name) {}
		}
	}
### end of addition

    if {[info exists DSx_past_sets(DSx_sav_out)] == 1} {
            set ::DSx_settings(past_sav_all) $DSx_past_sets(DSx_sav_all)
            set ::DSx_settings(past_sav_drops) $DSx_past_sets(DSx_sav_drops)
            set ::DSx_settings(past_sav_out) $DSx_past_sets(DSx_sav_out)
        } else {
            set ::DSx_settings(past_sav_all) 0
            set ::DSx_settings(past_sav_drops) 0
            set ::DSx_settings(past_sav_out) 0
        }
    array set DSx_past_mach $DSx_pastprops(machine)
    if {[info exists DSx_past_mach(preinfusion_volume)] == 1} {
            set ::DSx_settings(past_volume1) [expr {$DSx_past_mach(preinfusion_volume) + $DSx_past_mach(pour_volume)}]
        } else {
            set ::DSx_settings(past_volume1) 0
    }
    save_DSx_settings
    reset_messages
    DSx_past_shot_reference_reset
	DSx_current_listbox_item $::globals(DSx_past_shots_widget)
    if {[info exists DSx_pastprops(name)] != 1} {
        set DSx_pastprops(name) [file rootname $f]
    }
    set ::DSx_settings(DSx_past_espresso_name) $DSx_pastprops(name)
}

proc load_DSx_past2_shot { {force 0} } {
	if {$::de1(current_context) != "DSx_past" && $force == 0} {
		return
	}
	set stepnum [$::globals(DSx_past2_shots_widget) curselection]
	if {$stepnum == ""} {
		return
	}
	set f2 [ifexists ::DSx_past2_shot_filenames($stepnum)]
	if {$stepnum == ""} {
		return
	}
	### add archive files for Enrique's plugin
	if { [file exists "[homedir]/$::DSx_settings(history_godshots)/$f2"] } {
        set fn2 "[homedir]/$::DSx_settings(history_godshots)/$f2"
    } elseif { $::DSx_settings(history_godshots) eq "history" } {
        set fn2 "[homedir]/history_archive/$f2"
    }
	###
	array unset -nocomplain DSx_pastprops2
	array set DSx_pastprops2 [encoding convertfrom utf-8 [read_binary_file $fn2]]

    if {$::DSx_settings(history_godshots) == "DSx_steam_history"} {
        set ::DSx_settings(DSx_past2_espresso_elapsed) $DSx_pastprops2(steam_elapsed)
        set ::DSx_settings(DSx_past2_steam_pressure) $DSx_pastprops2(steam_pressure)
        set ::DSx_settings(DSx_past2_steam_flow) $DSx_pastprops2(steam_flow)
        set ::DSx_settings(DSx_past2_steam_temperature) $DSx_pastprops2(steam_temperature)
        set ::DSx_settings(DSx_past2_steam_temperature_setting) $DSx_pastprops2(steam_temperature_setting)
        set ::DSx_settings(DSx_past2_steaming_count_setting) $DSx_pastprops2(steaming_count_setting)
        set ::DSx_settings(DSx_past2_steam_timeout_setting) $DSx_pastprops2(steam_timeout_setting)
        set ::DSx_settings(DSx_past2_steam_flow_setting) $DSx_pastprops2(steam_flow_setting)
        set ::DSx_settings(DSx_past2_steam_highflow_start_setting) $DSx_pastprops2(steam_highflow_start_setting)
        set ::DSx_settings(shot_date_time2) [clock format $DSx_pastprops2(clock) -format {%a, %d %b %Y   %I:%M%p}]
    } else {
        set ::DSx_settings(DSx_past2_espresso_pressure) $DSx_pastprops2(espresso_pressure)
        set ::DSx_settings(DSx_past2_espresso_temperature_basket) $DSx_pastprops2(espresso_temperature_basket)
        set ::DSx_settings(DSx_past2_espresso_temperature_mix) $DSx_pastprops2(espresso_temperature_mix)
        set ::DSx_settings(DSx_past2_espresso_flow_weight) $DSx_pastprops2(espresso_flow_weight)
        set ::DSx_settings(DSx_past2_espresso_flow) $DSx_pastprops2(espresso_flow)
        set ::DSx_settings(DSx_past2_espresso_weight) $DSx_pastprops2(espresso_weight)
        if {[llength [ifexists DSx_pastprops2(espresso_elapsed)]] > 0} {
            set ::DSx_settings(DSx_past2_espresso_elapsed) $DSx_pastprops2(espresso_elapsed)
        }
        if {[info exists DSx_pastprops2(espresso_temperature_goal)] == 1} {
            set ::DSx_settings(DSx_past2_espresso_pressure_goal) $DSx_pastprops2(espresso_pressure_goal)
            set ::DSx_settings(DSx_past2_espresso_flow_goal) $DSx_pastprops2(espresso_flow_goal)
            set ::DSx_settings(DSx_past2_espresso_temperature_goal) $DSx_pastprops2(espresso_temperature_goal)
            set ::DSx_settings(DSx_past_espresso_state_change) {0.0}
            if {[info exists DSx_pastprops2(espresso_state_change)] == 1} {
                set ::DSx_settings(DSx_past2_espresso_state_change) $DSx_pastprops2(espresso_state_change)
            }
        } else {
            set ::DSx_settings(DSx_past2_espresso_pressure_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_flow_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_temperature_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_state_change) {0.0}
        }
        if {[info exists DSx_pastprops2(settings)] == 1} {
            array set DSx_past_sets2 $DSx_pastprops2(settings)
            set ::DSx_settings(drink_weight2) $DSx_past_sets2(drink_weight)
            if {[info exists DSx_past_sets2(grinder_dose_weight)] == 0} {
                set DSx_past_sets2(grinder_dose_weight) 0
                if {[info exists DSx_past_sets2(DSx_bean_weight)] == 1} {
                    set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(DSx_bean_weight)
                }
                if {[info exists DSx_past_sets2(dsv4_bean_weight)] == 1} {
                    set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv4_bean_weight)
                }
                if {[info exists DSx_past_sets2(dsv3_bean_weight)] == 1} {
                    set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv3_bean_weight)
                }
                if {[info exists DSx_past_sets2(dsv2_bean_weight)] == 1} {
                    set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv2_bean_weight)
                }
            } else {
                if {$DSx_past_sets2(grinder_dose_weight) < 1} {
                    if {[info exists DSx_past_sets2(DSx_bean_weight)] == 1} {
                        set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(DSx_bean_weight)
                    }
                    if {[info exists DSx_past_sets2(dsv4_bean_weight)] == 1} {
                        set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv4_bean_weight)
                    }
                    if {[info exists DSx_past_sets2(dsv3_bean_weight)] == 1} {
                        set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv3_bean_weight)
                    }
                    if {[info exists DSx_past_sets2(dsv2_bean_weight)] == 1} {
                        set DSx_past_sets2(grinder_dose_weight) $DSx_past_sets2(dsv2_bean_weight)
                    }
                }
            }
            set ::DSx_settings(past_bean_weight2) [round_to_one_digits $DSx_past_sets2(grinder_dose_weight)]
            set ::DSx_settings(past_profile_title2) $DSx_past_sets2(profile_title)
            array set DSx_past_mach2 $DSx_pastprops2(machine)
            if {[info exists DSx_past_mach2(preinfusion_volume)] == 1} {
                set ::DSx_settings(past_volume2) [expr {$DSx_past_mach2(preinfusion_volume) + $DSx_past_mach2(pour_volume)}]
            } else {
                set ::DSx_settings(past_volume2) 0
            }
        } else {
            if {[info exists DSx_pastprops2(drink_weight)] == 1} {
                set ::DSx_settings(drink_weight2) $DSx_pastprops2(drink_weight)
            } else {
                set ::DSx_settings(drink_weight2) 0
            }

            if {[info exists DSx_pastprops2(grinder_dose_weight)] == 0} {
                set DSx_pastprops2(grinder_dose_weight) 0
                if {[info exists DSx_pastprops2(DSx_bean_weight)] == 1} {
                    set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(DSx_bean_weight)
                }
                if {[info exists DSx_pastprops2(dsv4_bean_weight)] == 1} {
                    set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv4_bean_weight)
                }
                if {[info exists DSx_pastprops2(dsv3_bean_weight)] == 1} {
                    set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv3_bean_weight)
                }
                if {[info exists DSx_pastprops2(dsv2_bean_weight)] == 1} {
                    set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv2_bean_weight)
                }
            } else {
                if {$DSx_pastprops2(grinder_dose_weight) < 1} {
                    if {[info exists DSx_pastprops2(DSx_bean_weight)] == 1} {
                        set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(DSx_bean_weight)
                    }
                    if {[info exists DSx_pastprops2(dsv4_bean_weight)] == 1} {
                        set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv4_bean_weight)
                    }
                    if {[info exists DSx_pastprops2(dsv3_bean_weight)] == 1} {
                        set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv3_bean_weight)
                    }
                    if {[info exists DSx_pastprops2(dsv2_bean_weight)] == 1} {
                        set DSx_pastprops2(grinder_dose_weight) $DSx_pastprops2(dsv2_bean_weight)
                    }
                }
            }
            set ::DSx_settings(past_bean_weight2) [round_to_one_digits $DSx_pastprops2(grinder_dose_weight)]
            if {[info exists DSx_pastprops2(profile_title)] == 1} {
                set ::DSx_settings(past_profile_title2) $DSx_pastprops2(profile_title)
            } else {
                set ::DSx_settings(past_profile_title2) ""
            }
        }
        set ::DSx_settings(shot_date_time2) [clock format $DSx_pastprops2(clock) -format {%a, %d %b %Y   %I:%M%p}]

        ### setup additional history data from "Your setup & This espresso". Added by Enrique ###
        set ::DSx_settings(past_shot_file2) $fn2
        set ::DSx_settings(past_clock2) $DSx_pastprops2(clock)
        foreach field_name $::DSx_settings(extra_past_shot_fields) {
            if { [info exists DSx_past_sets2($field_name)] } {
                set ::DSx_settings(past_${field_name}2) $DSx_past_sets2($field_name)
            } else {
                set ::DSx_settings(past_${field_name}2) {}
            }
        }
        ### end of addition
    }
    save_DSx_settings
    reset_messages
    DSx_past2_shot_reference_reset
	DSx_current_listbox_item $::globals(DSx_past2_shots_widget)
    if {[info exists DSx_pastprops2(name)] != 1} {
        set DSx_pastprops2(name) [file rootname $f2]
    }
    set ::DSx_settings(DSx_past2_espresso_name) $DSx_pastprops2(name)
}

proc DSx_save_h2g {} {
	set ::DSx_message ""
	save_DSx_settings
	set clock [clock seconds]
	set filename [subst {[clock format $clock -format "%Y%m%dT%H%M%S"].shot}]
	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/godshots/" *.shot]]
	foreach fg $files {
	    set fng "[homedir]/godshots/$fg"
	    array unset -nocomplain godpropsg
	    array set godpropsg [read_file $fng]
	    if {[ifexists godpropsg(name)] == $::DSx_settings(DSx_past2_espresso_name)} {
	    	set ::DSx_message "Ooops!    That name is already taken..."
            }
        }
        if {$::DSx_settings(DSx_past2_espresso_name) == ""} {
            set ::DSx_message "Ooops!    You forgot to enter a name..."
        }
        if {$::DSx_message == ""} {
        set espresso_data {}
        append espresso_data "filename [list $filename]\n"
        append espresso_data "name [list $::DSx_settings(DSx_past2_espresso_name)]\n"
        append espresso_data "clock $clock\n"
        append espresso_data "espresso_elapsed {$::DSx_settings(DSx_past_espresso_elapsed)}\n"
        append espresso_data "espresso_pressure {$::DSx_settings(DSx_past_espresso_pressure)}\n"
        append espresso_data "espresso_weight {$::DSx_settings(DSx_past_espresso_weight)}\n"
        append espresso_data "espresso_flow {$::DSx_settings(DSx_past_espresso_flow)}\n"
        append espresso_data "espresso_flow_weight {$::DSx_settings(DSx_past_espresso_flow_weight)}\n"
        append espresso_data "espresso_temperature_basket {$::DSx_settings(DSx_past_espresso_temperature_basket)}\n"
        append espresso_data "espresso_temperature_mix {$::DSx_settings(DSx_past_espresso_temperature_mix)}\n"
        append espresso_data "espresso_temperature_goal {$::DSx_settings(DSx_past_espresso_temperature_goal)}\n"
        append espresso_data "espresso_pressure_goal {$::DSx_settings(DSx_past_espresso_pressure_goal)}\n"
        append espresso_data "espresso_flow_goal {$::DSx_settings(DSx_past_espresso_flow_goal)}\n"
	    append espresso_data "drink_weight {$::DSx_settings(drink_weight)}\n"
	    append espresso_data "grinder_dose_weight {$::DSx_settings(past_bean_weight)}\n"
	    append espresso_data "profile_title {$::DSx_settings(past_profile_title)}\n"
        set fng "[homedir]/godshots/$filename"
        write_file $fng $espresso_data
        fill_god_shots_listbox
        fill_DSx_past_shots_listbox;
        fill_DSx_past2_shots_listbox;
        set_next_page off off;
        page_show DSx_past;
        DSx_past2_shot_files
    }
}

proc DSx_archive {} {
    if {[file exists [homedir]/history/$::DSx_settings(DSx_past_espresso_name).shot] != 1} {
        set ::DSx_message2 "file $::DSx_settings(DSx_past_espresso_name) does not exist"
        } else {
        borg spinner on
        file rename -force [homedir]/history/$::DSx_settings(DSx_past_espresso_name).shot [homedir]/history_archive/$::DSx_settings(DSx_past_espresso_name).shot
        borg spinner off
        borg systemui $::android_full_screen_flags
        fill_DSx_past_shots_listbox;
        fill_DSx_past2_shots_listbox
    }
}

proc reset_messages {} {
        set ::DSx_message ""
        set ::DSx_message2 ""
}

proc history_vars {} {
    ### added by Enrique ### CHANGE LINE 2807 ADD "$"
	set ::DSx_settings(past_shot_file) {}
	set ::DSx_settings(past_shot_file2) {}	
	foreach field_name $::DSx_settings(extra_past_shot_fields) {
		if {[info exists ::DSx_settings(past_$field_name)] } {
			set ::DSx_settings(past_$field_name) {}
		}
		if {[info exists ::DSx_settings(past_${field_name}2)] } {
			set ::DSx_settings(past_${field_name}2) {}
		}		
	}
    ### end addition ###
    if {[info exists ::DSx_settings(home_show_history)] != 1} {
        set ::DSx_settings(home_show_history) {1}
    }
    if {[info exists ::DSx_settings(graph_weight_total)] != 1} {
        set ::DSx_settings(graph_weight_total) {0}
    }
    if {[info exists ::DSx_settings(DSx_past2_espresso_elapsed)] != 1} {
        set ::DSx_settings(DSx_past2_espresso_elapsed) {0.0}
        set ::DSx_settings(DSx_past2_espresso_filename) {}
        set ::DSx_settings(DSx_past2_espresso_flow) {0.0}
        set ::DSx_settings(DSx_past2_espresso_flow_weight) {0.0}
        set ::DSx_settings(DSx_past2_espresso_name) none
        set ::DSx_settings(DSx_past2_espresso_pressure) {0.0}
        set ::DSx_settings(DSx_past2_espresso_temperature_basket) {0.0}
        set ::DSx_settings(DSx_past2_espresso_temperature_mix) {0.0}
        set ::DSx_settings(DSx_past2_espresso_weight) {0.0}

        set ::DSx_settings(DSx_past_espresso_elapsed) {0.0}
        set ::DSx_settings(DSx_past_espresso_filename) {}
        set ::DSx_settings(DSx_past_espresso_flow) {0.0}
        set ::DSx_settings(DSx_past_espresso_flow_weight) {0.0}
        set ::DSx_settings(DSx_past_espresso_name) none
        set ::DSx_settings(DSx_past_espresso_pressure) {0.0}
        set ::DSx_settings(DSx_past_espresso_temperature_basket) {0.0}
        set ::DSx_settings(DSx_past_espresso_weight) {0.0}
        set ::DSx_settings(DSx_past_espresso_temperature_mix) {0.0}

    }
    if {[info exists ::DSx_settings(hist_temp_key)] != 1} {
        set ::DSx_settings(history_godshots) history
        set ::DSx_settings(original_profile_title) { }
        set ::DSx_settings(past_profile_title) { }
        set ::DSx_settings(profile_title) { }
        set ::DSx_settings(hist_temp_key) {Temperature (x10)°C}
        set ::DSx_settings(past_profile_title2) { }
        set ::DSx_settings(shot_date_time) {choose a file from the list}
        set ::DSx_settings(shot_date_time2) { }
        set ::DSx_settings(drink_weight) 0
        set ::DSx_settings(drink_weight2) 0
    }
    if {[info exists ::DSx_settings(past_bean_weight)] != 1} {
        set ::DSx_settings(past_bean_weight) 0
    }
    if {[info exists ::DSx_settings(past_bean_weight2)] != 1} {
        set ::DSx_settings(past_bean_weight2) 0
    }
    if {[info exists ::DSx_settings(list_order)] != 1} {
        set ::DSx_settings(list_order) -decreasing
    }
    if {[info exists [homedir]/history_archive] != 1} {
        set path [homedir]/history_archive
        file mkdir $path
        file attributes $path
    }
    if {[info exists ::DSx_settings(DSx_past2_espresso_pressure_goal] != 1} {
            set ::DSx_settings(DSx_past_espresso_pressure_goal) {0.0}
            set ::DSx_settings(DSx_past_espresso_flow_goal) {0.0}
            set ::DSx_settings(DSx_past_espresso_temperature_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_pressure_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_flow_goal) {0.0}
            set ::DSx_settings(DSx_past2_espresso_temperature_goal) {0.0}
            set ::DSx_settings(DSx_past_espresso_state_change) {0.0}
            set ::DSx_settings(DSx_past2_espresso_state_change) {0.0}
    }

    if {$::settings(enable_fahrenheit) == 1 && $::DSx_settings(hist_temp_key) == {Temperature (x10)°C}} {
        set ::DSx_settings(hist_temp_key) {Temperature (x20)°F}
        } elseif {$::settings(enable_fahrenheit) != 1 && $::DSx_settings(hist_temp_key) == {Temperature (x20)°F}} {
        set ::DSx_settings(hist_temp_key) {Temperature (x10)°C}
    }

    if {[info exists ::DSx_settings(DSx_left_shot_time)] != 1} {
        set ::DSx_settings(DSx_left_shot_time) 0
        set ::DSx_settings(DSx_right_shot_time) 0
    }
    if {[info exists ::DSx_settings(past_shot_desc)] != 1} {
        set ::DSx_settings(past_shot_desc) {}
        set ::DSx_settings(past_shot_desc2) {}
    }
    if {[info exists ::DSx_settings(show_history_resistance)] == 0 } {
        set ::DSx_settings(show_history_resistance) off
        set ::DSx_settings(hist_resistance_key) ""
    }
    if {[info exists ::DSx_settings(show_history_temperature)] == 0 } {
        set ::DSx_settings(show_history_temperature)  off
        set ::DSx_settings(hist_temp_key) ""
    }
    if {[info exists ::DSx_settings(show_history_goal)] == 0 } {
        set ::DSx_settings(show_history_goal)  off
    }
    if {[info exists ::DSx_settings(hist_goal_curve)] != 1} {
        set ::DSx_settings(hist_goal_curve) 0
    }
    if {[info exists ::DSx_settings(hist_temp_curve)] != 1} {
        set ::DSx_settings(hist_temp_curve) 0
    }
    if {[info exists ::DSx_settings(hist_temp_goal_curve)] != 1} {
        set ::DSx_settings(hist_temp_goal_curve) 0
    }
    if {[info exists ::DSx_settings(hist_resistance_curve)] != 1} {
        set ::DSx_settings(hist_resistance_curve) 0
    }
    save_DSx_settings
    save_settings
}

proc restart_set {} {
    set ::restart 1
}

### stop hot water by weight
proc save_wsaw_to_settings {} {
    set ::settings(DSx_wsaw) $::DSx_settings(wsaw)
    save_settings
}

proc wsaw_value {} {
    if {($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > 0 } {
        return $::DSx_settings(wsaw)g
    } else {
        return "off"
    }
}
proc wsaw_fav_indicator {} {
    if {($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > 0 } {
        return "*"
    } else {
        return ""
    }
}
proc wsaw_text {} {
    if {($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > 0 } {
        return "Water SAW - $::DSx_settings(wsaw)g"
    } else {
        return ""
    }
}
proc wsaw_warning {} {
    if {($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > [expr ($::settings(water_volume) * 0.7)]} {
        return "Check water volume"
    } else {
        return ""
    }
}
proc wsaw_cal_value {} {
    if {($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > 0 } {
        return $::DSx_settings(wsaw_cal)g
    } else {
        return "off"
    }
}

proc DSx_espresso {} {
    set ::current_espresso_page off
    set_next_page off off
    start_espresso
    cancel_auto_stop
}

proc DSx_steam {} {
    if {[start_button_ready] == [translate "READY"] && $::settings(steam_timeout) > 0} {
        DSx_reset_graphs
        set_next_page steam steam
        start_steam
        cancel_auto_stop
    }
    if {$::settings(steam_timeout) == 0 || [start_button_ready] == [translate "WAIT"]} {
        steam_off_message
    }
}

proc steam_off_message {} {
    if {$::settings(steam_timeout) == 0} {
        set ::steam_off_message [translate "Steam is turned off"]
        after 2000 {set ::steam_off_message ""}
    } else {
        set ::steam_off_message [translate "Wait... still heating"]
        after 2000 {set ::steam_off_message ""}
    }
}

proc DSx_water {} {
    if {[start_button_ready] == [translate "READY"]} {
        if {$::settings(scale_bluetooth_address) != ""} {
            set ::wsaw_run 0;
            skale_tare;
            after 600 {set_next_page water water; start_water; set ::wsaw_run 1};
        } else {
            set_next_page water water
            start_water
        }
        cancel_auto_stop
    }
}

proc DSx_flush_time_display {} {
    if {[DSx_flush_time] <= 0} {
    return ""
    } else {
    return [DSx_flush_time]
    }
}

proc DSx_flush_time {} {
    set flush_timer [expr {$::DSx_settings(flush_time) - ([clock seconds] - $::DSx_timer_start) + $::DSx_flush_time2}]
    if {$flush_timer >= 0} {
        return [round_to_integer $flush_timer]
    } else {
        return 0
    }
}
set ::flush_counting 0
proc DSx_loop {} {

    if {$::DSx_timer_reset == 1 && $::flush_counting != 1} {
            set ::flush_counting 1
	        set ::DSx_timer_start [clock seconds]
	        set ::DSx_timer_reset 0

	}
    if {$::flush_run == 1 && $::de1_num_state($::de1(state)) == "HotWaterRinse"} {
        if {$::DSx_settings(flush_time) + [DSx_flush_time] <= $::DSx_settings(flush_time)} {
            DSx_stop
        }
    }
	if {[info exists ::DSx_loop_1] == 1} {
		after cancel $::DSx_loop_1
		unset ::DSx_loop_1
	}
	if {$::flush_run == 0} {
        set ::flush_counting 0
        return
    }
	set ::DSx_loop_1 [after 100 DSx_loop]
}

proc DSx_flush {} {
    set_next_page hotwaterrinse preheat_2;
    start_hot_water_rinse;
    cancel_auto_stop
}
proc DSx_flush_extend {} {
    if {$::DSx_flush_time2 == 0 && $::DSx_settings(flush_time2) > 0} {
        set ::DSx_flush_time2 $::DSx_settings(flush_time2)
    } elseif {$::de1_num_state($::de1(state)) == "HotWaterRinse"} {
        DSx_stop;
    }
}

proc DSx_flush_time_extend_text {} {
    if {$::DSx_settings(flush_time2) > 0 } {
        return [round_to_integer $::DSx_settings(flush_time2)]s
    } else {
        return "off"
    }
}

proc DSx_add_flush_time_extend_text {} {
    if {$::DSx_flush_time2 == 0 && $::DSx_settings(flush_time2) > 0} {
        return +[round_to_integer $::DSx_settings(flush_time2)]s
    } else {
        return ""
    }
}

#########
proc wsaw {} {
    if {$::wsaw_run == 1 && $::settings(scale_bluetooth_address) != "" && ($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal)) > 1} {
        if {$::de1(scale_sensor_weight) > ($::DSx_settings(wsaw) - $::DSx_settings(wsaw_cal))} {
            set ::wsaw_run 0
            DSx_stop
        }
    }
}

proc wsaw_stop_water {} {
    set_next_page off off;
    start_idle;
}
proc DSx_stop {} {
    set ::DSx_timer_start 0
    set ::flush_run 0
    set ::wsaw_run 0
    set_next_page off off
    start_idle
}

set ::DSx_blink2 1
proc DSx_low_water {} {
    if {[expr $::de1(water_level) < {$::settings(water_refill_point) + 3}]} {
        if {$::DSx_blink2 == 1} {
                after 400 {set ::DSx_blink2 0}
                return ""
            } else {
                set ::DSx_blink2 1
                return "[water_tank_level_to_milliliters $::de1(water_level)] [translate mL]"
            }
	    }
	return "[water_tank_level_to_milliliters $::de1(water_level)] [translate mL] "
}

proc heading_colour_picker {} {
    set colour [tk_chooseColor -initialcolor $::DSx_settings(heading_colour) -title "Set heading colour"]
    if {$colour != {}} {
        set ::DSx_settings(heading_colour) $colour
        save_DSx_settings
        .can itemconfigure $::DSx_heading -fill $::DSx_settings(heading_colour)
        $::DSx_heading_entry configure -foreground $::DSx_settings(heading_colour)
    }
}

proc DSx_font_selection {} {
    #{{Text Files}       {.txt}        }
    #{{TCL Scripts}      {.tcl}        }
    #{{C Source Files}   {.c}      TEXT}
    #{{GIF Files}        {.gif}        }
    #{{GIF Files}        {}        GIFF}
    #{{All Files}        *             }

    set basedir [skin_directory]/DSx_Font_Files
    set types {
        {{Font Files}       {.ttf}        }
        {{Font Files}       {.otf}        }
    }
    set filename [tk_getOpenFile -filetypes $types -initialdir $basedir]

    if {$filename != ""} {
        set tn [file tail $filename]
        set rn [file rootname $tn]
        set ::DSx_settings(font_name) $rn

        set fd [file dirname $filename]
        set ::DSx_settings(font_dir) $fd
        restart_set
        save_DSx_settings
        set_colour

    }
}

proc DSx_load_font {name fn pcsize {androidsize {}} } {
    # calculate font size # Code credit to Barney
    if {$::DSx_settings(font_name) == "GochiHand-Regular"} {
            set offset 1.24
        } elseif { $::DSx_settings(font_name) == "Bradley Hand Bold"} {
            set offset 1.14
        } else {
            set offset 1
    }
    if {$::android == 1} {
        set f 2.19
    } else {
        set f 2
    }
    if {($::android == 1 || $::undroid == 1) && $androidsize != ""} {
        set pcsize $androidsize
    }
    set platform_font_size [expr {int(1.0 * $::fontm * $pcsize * $f * $offset)}]

    #if {[language] == "zh-hant" || [language] == "zh-hans"} {
    #    set fn ""
    #    set familyname $::helvetica_font
    #} elseif {[language] == "th"} {
    #   set fn "[homedir]/fonts/sarabun.ttf"
    #}
    if {[info exists ::loaded_fonts] != 1} {
        set ::loaded_fonts list
    }
    set fontindex [lsearch $::loaded_fonts $fn]
    if {$fontindex != -1} {
        set familyname [lindex $::loaded_fonts [expr $fontindex + 1]]
    } elseif {($::android == 1 || $::undroid == 1) && $fn != ""} {
        catch {
            set familyname [lindex [sdltk addfont $fn] 0]
        }
        lappend ::loaded_fonts $fn $familyname
    }
    if {[info exists familyname] != 1 || $familyname == ""} {
        msg "Font familyname not available; using name '$name'."
        set familyname $name
    }
    catch {
        font create $name -family $familyname -size $platform_font_size
    }
    msg "added font name: \"$name\" family: \"$familyname\" size: $platform_font_size filename: \"$fn\""
}

proc DSx_font {font_name size} {

    if {$font_name == "font"} {
        set font_name $::DSx_settings(font_name)
    }
    if {[info exists ::skin_fonts] != 1} {
        set ::skin_fonts list
    }
    set font_key "$font_name $size DSx"
    set font_index [lsearch $::skin_fonts $font_key]
    if {$font_index == -1} {
        # support for both OTF and TTF files
        if {[file exists "$::DSx_settings(font_dir)/$font_name.otf"] == 1} {
            DSx_load_font $font_key "$::DSx_settings(font_dir)/$font_name.otf" $size
            lappend ::skin_fonts $font_key
        } elseif {[file exists "$::DSx_settings(font_dir)/$font_name.ttf"] == 1} {
            DSx_load_font $font_key "$::DSx_settings(font_dir)/$font_name.ttf" $size
            lappend ::skin_fonts $font_key
        } elseif {[file exists "[skin_directory]/DSx_Font_Files/$font_name.otf"] == 1} {
            DSx_load_font $font_key "[skin_directory]/DSx_Font_Files/$font_name.otf" $size
            lappend ::skin_fonts $font_key
        } elseif {[file exists "[skin_directory]/DSx_Font_Files/$font_name.ttf"] == 1} {
            DSx_load_font $font_key "[skin_directory]/DSx_Font_Files/$font_name.ttf" $size
            lappend ::skin_fonts $font_key
        } else {
            msg "Unable to load font '$font_key'"
        }
    }
    return $font_key
}

proc DSx_clock_font {} {
    if {$::DSx_settings(original_clock_font) == 0} {
        set ::DSx_settings(clock_font) $::DSx_settings(font_name)
        } else {
        set ::DSx_settings(clock_font) {Comic Sans MS}
    }
    set_colour
}

proc DSx_date {} {
    if {$::DSx_settings(clock_hide) != 1} {
        set a [clock format [clock seconds] -format "%a, %d %b"]
        } else {
        set a ""
    }
    return $a
}

proc DSx_clock {} {

    if {$::DSx_settings(clock_hide) != 1} {
        if {$::settings(enable_ampm) == 0} {
            set a [clock format [clock seconds] -format "%H"]
            set b [clock format [clock seconds] -format ":%M"]
            set c $a
            } else {
            set a [clock format [clock seconds] -format "%I"]
            set b [clock format [clock seconds] -format ":%M"]
            set c $a
            regsub {^[0]} $c {\1} c
            }
        } else {
        set c ""
        set b ""
    }
    return $c$b
}

proc DSx_clock_ap {} {
    if {$::DSx_settings(clock_hide) != 1 && $::settings(enable_ampm) == 1} {
        set a [clock format [clock seconds] -format %P]
        } else {
        set a ""
    }
    return $a
}

proc DSx_clock_s {} {
    if {$::DSx_settings(clock_hide) != 1} {
        set a [clock format [clock seconds] -format %S]
    } else {
        set a ""
    }
    return $a
}

proc cancel_auto_stop {} {
    if {$::android == 0 } {
    after cancel [list update_de1_state "$::de1_state(Idle)\x5"]
    after cancel [list update_de1_state "$::de1_state(Idle)\x5"]
    after cancel [list update_de1_state "$::de1_state(Idle)\x5"]
    after cancel [list update_de1_state "$::de1_state(Idle)\x5"]
    }
}

proc DSx_return_temperature_number {in} {
	if {$::settings(enable_fahrenheit) == 1} {
		return [round_to_two_digits [expr {[celsius_to_fahrenheit $in] * 0.05}]]
	} else {
		return [round_to_two_digits [expr {$in * 0.1}]]
	}
}

proc DSx_steam_graph_list {} {
	return [list steam_elapsed steam_temperature steam_flow steam_pressure]
}

proc backup_DSx_steam_graph {} {
	foreach sg [DSx_steam_graph_list] {
	unset -nocomplain ::DSx_settings(steam_graph_$sg)
		if {[$sg length] > 0} {
			set ::DSx_settings(steam_graph_$sg) [$sg range 0 end]
		} else {
			set ::DSx_settings(steam_graph_$sg) {}
		}
	}

}

proc restore_DSx_steam_graph {} {
	set last_elapsed_time_index [expr {[espresso_elapsed length] - 1}]
	foreach sg [DSx_steam_graph_list] {
		$sg length 0
		if {[info exists ::DSx_settings(steam_graph_$sg)] == 1} {
			$sg append $::DSx_settings(steam_graph_$sg)
		}

	}
}

proc save_steam_history {unused_old_state unused_new_state} {

    if {[expr {[steam_pour_millitimer]}] < 8000} {
        return
    }
    if {$::DSx_settings(save_DSx_steam_history) != 1} {
        return
    }
    if {[info exists [homedir]/DSx_steam_history] != 1} {
        set path [homedir]/DSx_steam_history
        file mkdir $path
        file attributes $path
    }
    if {[catch {
        set clock [clock seconds]
        set name [clock format $clock]

        set steam_data {}
        append steam_data "$name\n"
        append steam_data "clock $clock\n"
        append steam_data "\n"
        append steam_data "steam_elapsed {[steam_elapsed range 0 end]}\n"
        append steam_data "steam_pressure {[steam_pressure range 0 end]}\n"
        append steam_data "steam_flow {[steam_flow range 0 end]}\n"
        if {$::settings(enable_fahrenheit) == 1} {
            append steam_data "steam_temperature {[steam_temperature range 0 end]}\n"
            } else {
            append steam_data "steam_temperature {[steam_temperature range 0 end]}\n"
        }
        append steam_data "\n"
        append steam_data "steaming_count_setting $::settings(steaming_count)\n"
        append steam_data "steam_timeout_setting $::settings(steam_timeout)\n"
        append steam_data "steam_temperature_setting $::settings(steam_temperature)\n"
        append steam_data "steam_flow_setting $::settings(steam_flow)\n"
        append steam_data "steam_highflow_start_setting $::settings(steam_highflow_start)\n"
    } err]} {
        msg "Steam history not saved, $err"
    } else {
        set fn "[homedir]/DSx_steam_history/[clock format $clock -format "%Y%m%dT%H%M%S"].steam"
        write_file $fn $steam_data
        msg "Save this steam to history"
    }
}
### DAMIAN
if { $::skin::dsx::use_event_system } {
	::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
		set ps [dict get $event_dict previous_state]
		set ts [dict get $event_dict this_state]
		if { $ps == "Steam" && $ts == "Idle" } {
			save_steam_history $ps $ts}
	}]
} else {
	::register_state_change_handler Steam Idle save_steam_history
}


proc DSx_live_graph_list {} {
	return [list DSx_espresso_temperature_basket DSx_espresso_temperature_mix DSx_espresso_temperature_goal espresso_elapsed espresso_pressure espresso_weight espresso_weight_chartable espresso_flow espresso_flow_weight espresso_flow_weight_raw espresso_water_dispensed espresso_flow_weight_2x espresso_flow_2x espresso_resistance espresso_resistance_weight espresso_pressure_delta espresso_flow_delta espresso_flow_delta_negative espresso_flow_delta_negative_2x espresso_temperature_mix espresso_temperature_basket espresso_state_change espresso_pressure_goal espresso_flow_goal espresso_flow_goal_2x espresso_temperature_goal espresso_de1_explanation_chart_flow espresso_de1_explanation_chart_elapsed_flow espresso_de1_explanation_chart_flow_2x espresso_de1_explanation_chart_flow_1_2x espresso_de1_explanation_chart_flow_2_2x espresso_de1_explanation_chart_flow_3_2x espresso_de1_explanation_chart_pressure espresso_de1_explanation_chart_temperature espresso_de1_explanation_chart_temperature_10 espresso_de1_explanation_chart_pressure_1 espresso_de1_explanation_chart_pressure_2 espresso_de1_explanation_chart_pressure_3 espresso_de1_explanation_chart_elapsed_flow espresso_de1_explanation_chart_elapsed_flow_1 espresso_de1_explanation_chart_elapsed_flow_2 espresso_de1_explanation_chart_elapsed_flow_3 espresso_de1_explanation_chart_elapsed espresso_de1_explanation_chart_elapsed_1 espresso_de1_explanation_chart_elapsed_2 espresso_de1_explanation_chart_elapsed_3]
}

if { $::skin::dsx::use_event_system } {

	::de1::event::listener::after_flow_complete_add [lambda {event_dict} {
		set ps [dict get $event_dict previous_state]
		set ts [dict get $event_dict this_state]
		if { $ps == "Espresso" } {
			save_final_live_graph $ps $ts
		}
	}]

	::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
		set ps [dict get $event_dict previous_state]
		set ts [dict get $event_dict this_state]
		if { $ps == "Idle" && $ts == "Espresso" } {
			save_dose $ps $ts
		}
	}]

} else {

	::register_state_change_handler Espresso Idle save_final_live_graph
	::register_state_change_handler Idle Espresso save_dose

}


rename ::clear_espresso_chart ::skin::dsx::clear_espresso_chart_orig
msg -INFO "DSx: rename ::clear_espresso_chart ::skin::dsx::clear_espresso_chart_orig"

proc ::clear_espresso_chart {args} {

	clear_temp_data
	::skin::dsx::clear_espresso_chart_orig {*}$args
}



proc backup_DSx_live_graph {} {
	foreach lg [DSx_live_graph_list] {
	unset -nocomplain ::DSx_settings(live_graph_$lg)
		if {[$lg length] > 0} {
			set ::DSx_settings(live_graph_$lg) [$lg range 0 end]
			set ::DSx_settings(live_graph_profile) $::settings(profile_title)
		    set ::DSx_settings(live_graph_time) $::settings(espresso_clock)
		    set ::DSx_settings(live_graph_beans) $::settings(grinder_dose_weight)
		    set ::DSx_settings(live_graph_weight) $::settings(drink_weight)
		    set ::DSx_settings(live_graph_pi_water) [round_to_integer $::de1(preinfusion_volume)]
		    set ::DSx_settings(live_graph_pour_water) [round_to_integer $::de1(pour_volume)]
		    set ::DSx_settings(live_graph_water) [expr {[round_to_integer $::de1(preinfusion_volume)] + [round_to_integer $::de1(pour_volume)]}]
		    set ::DSx_settings(live_graph_pi_time) [espresso_preinfusion_timer]
		    set ::DSx_settings(live_graph_pour_time) [espresso_pour_timer]
		    set ::DSx_settings(live_graph_shot_time) [espresso_elapsed_timer]
		} else {
			set ::DSx_settings(live_graph_$lg) {}
		}
	}
}
proc save_final_live_graph {unused_old_state unused_new_state} {
    backup_DSx_live_graph
    save_DSx_settings
}
proc DSx_water_data {} {
    set piv [round_to_integer $::de1(preinfusion_volume)]
    set pv [round_to_integer $::de1(pour_volume)]
    set tv [expr {[round_to_integer $::de1(preinfusion_volume)] + [round_to_integer $::de1(pour_volume)]}]

    if {$piv >= 1} {
        return "$piv+$pv = $tv"
    } else {
        return "$tv"
    }
}

proc DSx_espresso_elapsed_timer {} {
    set pit [espresso_preinfusion_timer]
    set pt [espresso_pour_timer]
    set tt [espresso_elapsed_timer]
    if {$pit >= 1} {
        return "$pit+$pt = $tt"
    } else {
        return "$tt"
    }
}

proc DSx_live_graph_data_timer {} {
    set pit $::DSx_settings(live_graph_pi_time)
    set pt $::DSx_settings(live_graph_pour_time)
    set tt $::DSx_settings(live_graph_shot_time)
    if {$pit >= 1} {
        return "$pit+$pt = $tt"
    } else {
        return "$tt"
    }
}

proc DSx_live_graph_data_water {} {
    set piv $::DSx_settings(live_graph_pi_water)
    set pv $::DSx_settings(live_graph_pour_water)
    set tv $::DSx_settings(live_graph_water)
    if {$piv >= 1} {
        return "$piv+$pv = $tv"
    } else {
        return "$tv"
    }
}

proc last_extraction_ratio {} {
    catch {
        set r [round_to_one_digits [expr $::DSx_settings(live_graph_weight)/$::DSx_settings(live_graph_beans)]]
    }
    return 1:$r
}
proc live_extraction_ratio {} {
    catch {
        set r [round_to_one_digits [expr $::de1(scale_sensor_weight)/$::settings(grinder_dose_weight)]]
    }
    return 1:$r
}


proc last_shot_date {} {
    set date [clock format $::DSx_settings(live_graph_time) -format {%a %d %b}]
    if {$::settings(enable_ampm) == 0} {
        set a [clock format $::DSx_settings(live_graph_time) -format {%H}]
        set b [clock format $::DSx_settings(live_graph_time) -format {:%M}]
        set c $a
    } else {
        set a [clock format $::DSx_settings(live_graph_time) -format {%I}]
        set b [clock format $::DSx_settings(live_graph_time) -format {:%M}]
        set c $a
        regsub {^[0]} $c {\1} c
    }
    if {$::DSx_settings(clock_hide) != 1 && $::settings(enable_ampm) == 1} {
        set pm [clock format $::DSx_settings(live_graph_time) -format %P]
        } else {
        set pm ""
    }
    return "$date $c$b$pm"
}

proc restore_DSx_live_graph {} {
	set last_elapsed_time_index [expr {[espresso_elapsed length] - 1}]
	if {$last_elapsed_time_index > 1} {
	    return
	}
	foreach lg [DSx_live_graph_list] {
		$lg length 0
		if {[info exists ::DSx_settings(live_graph_$lg)] == 1} {
			$lg append $::DSx_settings(live_graph_$lg)
		}
	}
}

proc LRv2_preview_text {} {
        if {$::settings(profile_title) == {Damian's LRv2} || $::settings(profile_title) == {Damian's LRv3} || $::settings(profile_title) == {Damian's LM Leva}} {
        return "of how $::settings(profile_title) should look"
        } else {
        return ""
        }
}

proc DSx_graph_restore {} {
    after 1 {restore_DSx_live_graph; restore_DSx_steam_graph}
}

proc LRv2_preview {} {

    if {$::settings(profile_title) == {Damian's LRv2}} {
        $::DSx_preview_graph_advanced configure -width [rescale_x_skin 1050] -height [rescale_y_skin 450]
        DSx_espresso_elapsed_preview length 0
        DSx_espresso_pressure_preview length 0
        DSx_espresso_flow_preview_2x length 0
        DSx_espresso_flow_weight_preview_2x length 0
        DSx_espresso_elapsed_preview append {0.0 0.03 0.251 0.477 0.747 0.971 1.244 1.469 1.737 1.962 2.234 2.503 2.729 2.997 3.222 3.493 3.717 3.987 4.211 4.483 4.751 4.975 5.248 5.517 5.747 5.965 6.237 6.463 6.732 6.957 7.227 7.452 7.721 7.992 8.217 8.485 8.712 9.029 9.208 9.477 9.702 10.015 10.196 10.468 10.692 10.962 11.233 11.46 11.728 11.97 12.22 12.447 12.717 12.987 13.212 13.437 13.705 13.977 14.203 14.472 14.698 14.968 15.19 15.482 15.685 15.958 16.184 16.449 16.678 16.951 17.218 17.441 17.715 17.936 18.206 18.43 18.738 18.925 19.195 19.423 19.693 19.96 20.187 20.46 20.681 20.952 21.176 21.458 21.669 21.941 22.165 22.437 22.708 22.929 23.201 23.424 23.696 23.92 24.191 24.42 24.684 24.909 25.179 25.449 25.685 25.992 26.169 26.441 26.709 26.936 27.161 27.455 27.656 27.925 28.202 28.419 28.689 28.959 29.186 29.409 29.708 29.911 30.178 30.408 30.671 30.894 31.209 31.436 31.659 31.929 32.156 32.426 32.656 32.921 33.144 33.417 33.642 33.909 34.179 34.405 34.677 34.91 35.169 35.394 35.664 35.903 36.159 36.389 36.655 36.88 37.151 37.419 37.645 37.924 38.141 38.409 38.635 38.907 39.133 39.402 39.625 39.916 40.164 40.391 40.662 40.884 41.163 41.404 41.651 41.874 42.158 42.372 42.641 42.919 43.136 43.409 43.651 43.9 44.126 44.418 44.621 44.937 45.114 45.4 45.655}
        DSx_espresso_pressure_preview append {0.0 0.01 0.01 0.01 0.03 0.02 0.02 0.03 0.02 0.04 0.08 0.16 0.28 0.37 0.39 0.46 0.55 0.64 0.78 0.93 1.1 1.34 1.55 1.83 2.16 2.51 2.83 3.1 3.2 3.26 3.24 3.26 3.2 3.11 3.17 3.17 3.09 2.97 3.04 3.0 3.06 3.17 3.05 2.96 3.01 3.05 2.95 3.0 3.06 2.95 2.97 3.03 2.99 3.09 3.01 2.97 3.21 3.17 3.04 2.99 2.92 3.01 3.02 2.97 3.06 2.98 2.98 3.06 2.97 3.04 3.1 3.53 4.22 4.99 5.8 6.4 6.94 7.39 7.76 8.01 8.22 8.42 8.56 8.64 8.73 8.83 8.83 8.84 8.9 8.91 8.91 8.94 8.94 8.93 8.97 8.94 8.95 8.96 8.96 8.97 8.98 8.93 8.95 8.97 8.92 8.88 8.88 8.86 8.82 8.82 8.78 8.78 8.74 8.72 8.66 8.68 8.64 8.59 8.61 8.57 8.55 8.52 8.5 8.49 8.43 8.43 8.39 8.38 8.32 8.31 8.3 8.26 8.23 8.18 8.23 8.18 8.14 8.1 8.09 8.05 8.04 7.97 8.01 7.99 7.91 7.88 7.89 7.83 7.82 7.79 7.74 7.76 7.74 7.65 7.67 7.64 7.65 7.57 7.55 7.53 7.51 7.5 7.44 7.42 7.37 7.39 7.34 7.32 7.29 7.27 7.23 7.21 7.18 7.18 7.11 7.07 7.11 7.03 7.02 7.0 6.98 6.92 6.93 6.89 6.86}
        foreach DSx_flow {0.0 2.16 3.14 4.06 4.82 5.42 5.88 6.29 6.6 6.85 7.02 7.09 7.11 7.18 7.22 7.24 7.24 7.23 7.21 7.22 7.18 7.11 7.01 6.93 6.81 6.47 5.98 5.3 4.57 3.88 3.29 2.72 2.19 1.87 1.56 1.27 1.0 0.88 0.71 0.65 0.63 0.5 0.39 0.36 0.35 0.28 0.27 0.28 0.23 0.22 0.25 0.2 0.27 0.22 0.17 0.33 0.29 0.23 0.18 0.14 0.2 0.19 0.15 0.24 0.19 0.17 0.23 0.19 0.25 0.22 0.46 0.82 1.12 1.35 1.42 1.48 1.48 1.44 1.4 1.35 1.34 1.29 1.25 1.23 1.24 1.2 1.18 1.18 1.2 1.2 1.21 1.21 1.24 1.27 1.28 1.32 1.33 1.35 1.38 1.41 1.43 1.45 1.49 1.5 1.5 1.5 1.5 1.53 1.55 1.57 1.56 1.56 1.58 1.58 1.61 1.58 1.6 1.62 1.63 1.66 1.68 1.66 1.69 1.68 1.7 1.7 1.7 1.71 1.7 1.72 1.73 1.7 1.71 1.76 1.73 1.75 1.75 1.75 1.74 1.75 1.73 1.74 1.77 1.72 1.73 1.72 1.69 1.72 1.71 1.69 1.69 1.71 1.68 1.71 1.71 1.74 1.71 1.7 1.7 1.68 1.71 1.69 1.7 1.7 1.71 1.7 1.7 1.67 1.68 1.68 1.67 1.67 1.66 1.61 1.64 1.64 1.6 1.61 1.6 1.58 1.58 1.6 1.57 1.6 1.59} {
            DSx_espresso_flow_preview_2x append [expr {1.7 * $DSx_flow}]
            }
        foreach DSx_flow_weight {0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.05 0.0 0.0 0.0 0.0 0.0 0.1 0.08 0.07 0.11 0.14 0.14 0.07 0.16 0.14 0.12 0.2 0.19 0.26 0.19 0.17 0.13 0.13 0.22 0.18 0.16 0.24 0.3 0.34 0.38 0.4 0.44 0.52 0.54 0.6 0.62 0.68 0.76 0.75 0.78 0.79 0.87 0.89 0.9 0.91 0.93 0.98 0.98 1.03 1.03 1.08 1.11 1.11 1.14 1.17 1.2 1.19 1.23 1.23 1.24 1.25 1.27 1.33 1.33 1.36 1.35 1.34 1.38 1.42 1.41 1.47 1.46 1.43 1.43 1.45 1.48 1.47 1.5 1.47 1.5 1.57 1.59 1.57 1.59 1.59 1.56 1.6 1.59 1.57 1.59 1.6 1.57 1.57 1.59 1.58 1.59 1.61 1.62 1.62 1.63 1.63 1.59 1.59 1.57 1.62 1.62 1.62 1.59 1.65 1.61 1.62 1.66 1.66 1.61 1.63 1.59 1.6 1.6 1.6 1.6 1.63 1.59 1.59 1.59 1.64 1.6 1.61 1.63 1.6 1.63 1.6 1.6 1.63 1.63 1.6 1.6} {
            DSx_espresso_flow_weight_preview_2x append [expr {2.0 * $DSx_flow_weight}]
            }
        } elseif {$::settings(profile_title) == {Damian's LRv3}} {
        $::DSx_preview_graph_advanced configure -width [rescale_x_skin 1050] -height [rescale_y_skin 450]
        DSx_espresso_elapsed_preview length 0
        DSx_espresso_pressure_preview length 0
        DSx_espresso_flow_preview_2x length 0
        DSx_espresso_flow_weight_preview_2x length 0
        DSx_espresso_elapsed_preview append {0.0 0.04 0.263 0.494 0.805 0.986 1.256 1.526 1.751 2.021 2.246 2.514 2.742 3.011 3.237 3.506 3.777 4.003 4.272 4.543 4.766 4.989 5.261 5.486 5.756 6.027 6.25 6.522 6.747 7.016 7.24 7.513 7.782 8.006 8.276 8.501 8.768 8.996 9.266 9.491 9.764 10.029 10.257 10.532 10.749 11.022 11.25 11.517 11.741 12.012 12.279 12.505 12.82 13.003 13.272 13.497 13.823 14.034 14.262 14.529 14.753 15.023 15.251 15.527 15.747 16.013 16.308 16.512 16.782 17.006 17.291 17.524 17.771 17.994 18.269 18.536 18.759 19.029 19.253 19.524 19.748 20.022 20.289 20.515 20.8 21.009 21.279 21.526 21.776 22.048 22.275 22.541 22.766 23.057 23.26 23.528 23.755 24.034 24.295 24.521 24.841 25.024 25.284 25.509 25.781 26.05 26.273 26.545 26.791 27.042 27.263 27.542 27.763 28.029 28.312 28.525 28.793 29.021 29.315 29.52 29.786 30.073 30.278 30.55 30.776 31.045 31.276 31.539 31.763 32.041 32.305 32.527 32.837 33.023 33.295 33.521 33.8 34.059 34.283 34.557 34.812 35.049 35.273 35.547 35.777 36.041 36.311 36.534 36.865 37.034 37.299 37.525 37.798 38.063 38.289 38.561 38.805 39.057 39.281 39.555 39.774 40.043 40.313 40.539 40.808}
        DSx_espresso_pressure_preview append {0.0 0.01 0.0 0.02 0.03 0.02 0.02 0.02 0.06 0.16 0.23 0.24 0.31 0.38 0.46 0.57 0.71 0.87 1.08 1.29 1.5 1.75 2.07 2.36 2.59 2.86 3.07 3.19 3.19 3.16 3.2 3.22 3.19 3.13 3.06 3.05 3.09 3.03 3.01 3.04 3.08 2.96 3.02 3.03 3.08 3.0 2.98 3.06 2.96 3.05 2.98 3.01 3.01 3.03 3.04 2.96 3.05 2.96 3.01 3.0 3.04 2.97 3.04 2.99 3.0 3.0 3.02 3.01 3.05 3.13 3.69 4.45 5.22 5.93 6.47 6.95 7.41 7.7 8.01 8.22 8.37 8.49 8.65 8.73 8.74 8.77 8.81 8.8 8.78 8.81 8.85 8.86 8.87 8.88 8.91 8.93 8.96 8.91 8.94 8.99 8.96 8.92 8.93 8.98 9.02 8.95 8.96 8.98 8.91 8.98 8.96 8.9 8.88 8.91 8.89 8.81 8.87 8.83 8.82 8.74 8.8 8.75 8.73 8.69 8.66 8.63 8.62 8.59 8.54 8.54 8.53 8.52 8.46 8.4 8.46 8.37 8.34 8.4 8.3 8.29 8.28 8.25 8.22 8.16 8.22 8.15 8.13 8.1 8.04 8.04 8.06 8.0 7.98 7.96 7.92 7.89 7.91 7.84 7.8 7.79 7.78 7.75 7.74 7.69 7.64}
        foreach DSx_flow {0.0 2.19 3.12 4.09 4.84 5.47 5.96 6.34 6.64 6.89 7.04 7.14 7.23 7.27 7.34 7.37 7.37 7.35 7.37 7.32 7.32 7.26 7.12 6.87 6.49 5.87 5.22 4.49 3.8 3.21 2.67 2.25 1.87 1.48 1.26 1.08 0.88 0.79 0.65 0.62 0.49 0.48 0.41 0.43 0.35 0.3 0.33 0.26 0.31 0.26 0.3 0.27 0.3 0.28 0.22 0.28 0.23 0.29 0.25 0.31 0.26 0.31 0.26 0.3 0.27 0.32 0.27 0.32 0.34 0.62 0.97 1.26 1.46 1.55 1.59 1.62 1.58 1.58 1.57 1.56 1.52 1.52 1.52 1.53 1.52 1.53 1.53 1.52 1.53 1.53 1.57 1.59 1.63 1.65 1.69 1.69 1.7 1.75 1.79 1.81 1.8 1.82 1.87 1.91 1.93 1.96 2.01 1.99 2.04 2.05 2.04 2.01 2.04 2.04 2.0 2.05 2.06 2.04 1.98 2.02 2.04 2.08 2.08 2.07 2.07 2.04 2.06 2.03 2.05 2.03 2.05 2.04 2.01 2.04 1.98 2.0 2.03 2.02 1.99 1.99 2.0 1.99 2.0 2.02 1.97 1.98 1.99 1.94 1.95 1.99 1.99 1.99 1.98 1.94 1.96 1.98 1.98 1.95 1.88 1.88 1.9 1.91 1.88 1.81 1.84} {
            DSx_espresso_flow_preview_2x append [expr {1.9 * $DSx_flow}]
            }
        foreach DSx_flow_weight {0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.1 0.09 0.07 0.07 0.05 0.05 0.05 0.05 0.1 0.13 0.13 0.11 0.1 0.18 0.16 0.23 0.27 0.23 0.24 0.27 0.23 0.22 0.29 0.33 0.28 0.27 0.28 0.34 0.35 0.4 0.43 0.42 0.55 0.47 0.52 0.68 0.77 0.78 0.76 0.89 0.95 0.95 1.01 1.0 1.09 1.13 1.17 1.14 1.27 1.25 1.25 1.31 1.33 1.38 1.42 1.45 1.49 1.46 1.47 1.54 1.56 1.58 1.59 1.6 1.64 1.64 1.69 1.66 1.7 1.7 1.68 1.72 1.76 1.72 1.71 1.75 1.78 1.76 1.79 1.8 1.78 1.76 1.78 1.81 1.74 1.75 1.78 1.77 1.74 1.77 1.8 1.76 1.74 1.78 1.8 1.77 1.8 1.77 1.8 1.77 1.8 1.78 1.75 1.78 1.8 1.78 1.8 1.77 1.76 1.77 1.8 1.78 1.81 1.78 1.76 1.77 1.76 1.79 1.75 1.78 1.76 1.75} {
            DSx_espresso_flow_weight_preview_2x append [expr {2.2 * $DSx_flow_weight}]
            }
        } elseif {$::settings(profile_title) == {Damian's LM Leva}} {
        $::DSx_preview_graph_advanced configure -width [rescale_x_skin 1050] -height [rescale_y_skin 450]
        DSx_espresso_elapsed_preview length 0
        DSx_espresso_pressure_preview length 0
        DSx_espresso_flow_preview_2x length 0
        DSx_espresso_flow_weight_preview_2x length 0
        DSx_espresso_elapsed_preview append {0.0 0.011 0.258 0.483 0.758 0.979 1.249 1.473 1.742 1.968 2.238 2.509 2.734 3.004 3.229 3.498 3.724 3.993 4.218 4.49 4.713 4.983 5.254 5.481 5.75 5.973 6.245 6.47 6.738 6.964 7.234 7.504 7.729 7.999 8.224 8.494 8.72 8.989 9.213 9.484 9.753 9.978 10.25 10.474 10.743 10.969 11.24 11.464 11.733 11.96 12.229 12.498 12.725 12.993 13.219 13.49 13.716 13.983 14.209 14.479 14.755 14.974 15.244 15.47 15.74 15.963 16.238 16.459 16.729 17.001 17.224 17.492 17.719 17.992 18.213 18.489 18.71 18.978 19.204 19.474 19.751 19.977 20.238 20.464 20.741 20.961 21.229 21.477 21.723 21.994 22.263 22.487 22.713 22.983 23.209 23.478 23.703 23.973 24.242 24.47 24.745 24.963 25.233 25.459 25.735 25.953 26.223 26.455 26.718 26.989 27.213 27.502 27.708 27.978 28.204 28.473 28.709 28.968 29.238 29.463 29.753 29.959 30.23 30.454 30.724 30.95 31.217 31.443 31.738 31.983 32.209 32.491 32.705 32.973 33.198 33.469 33.693 33.971 34.235 34.457 34.74 34.953 35.223 35.448 35.718 35.943 36.242 36.482 36.708 36.977 37.203 37.475 37.72 37.969 38.192 38.464 38.732 38.957 39.229 39.453 39.724 39.953 40.217 40.443 40.761 40.982 41.263 41.49 41.703 41.989 42.204 42.468 42.692 42.962 43.233 43.458 43.746 43.953 44.224 44.457 44.718 44.943 45.225 45.483 45.71 45.978 46.213 46.473 46.698 46.974 47.193}
        DSx_espresso_pressure_preview append {0.0 0.05 0.04 0.07 0.1 0.13 0.19 0.26 0.33 0.41 0.5 0.63 0.77 0.97 1.13 1.36 1.65 1.92 2.15 2.3 2.4 2.47 2.48 2.46 2.42 2.38 2.32 2.35 2.3 2.29 2.24 2.18 2.25 2.27 2.21 2.2 2.25 2.19 2.14 2.21 2.21 2.16 2.23 2.24 2.19 2.22 2.25 2.2 2.17 2.17 2.24 2.23 2.19 2.16 2.23 2.61 3.25 4.03 4.79 5.54 6.11 6.52 6.85 7.1 7.33 7.54 7.7 7.77 7.86 7.91 7.95 7.98 7.98 7.98 8.0 7.99 8.01 7.96 7.97 8.01 7.98 7.97 7.99 7.99 7.97 8.0 7.97 7.99 8.0 7.95 7.95 7.95 7.92 7.89 7.92 7.85 7.87 7.84 7.83 7.79 7.77 7.76 7.72 7.66 7.72 7.64 7.61 7.61 7.6 7.54 7.54 7.51 7.49 7.46 7.44 7.45 7.36 7.36 7.36 7.32 7.3 7.28 7.24 7.23 7.21 7.16 7.14 7.12 7.12 7.09 7.04 7.04 7.03 6.97 6.97 6.94 6.93 6.88 6.85 6.83 6.84 6.78 6.77 6.71 6.71 6.72 6.66 6.64 6.6 6.61 6.57 6.54 6.53 6.49 6.46 6.44 6.43 6.41 6.35 6.38 6.32 6.27 6.28 6.23 6.24 6.2 6.19 6.14 6.13 6.1 6.07 6.06 6.04 6.0 5.97 5.94 5.95 5.9 5.87 5.87 5.81 5.81 5.81 5.75 5.71 5.71 5.68 5.68 5.62 5.6 5.56}
        foreach DSx_flow {0.0 4.03 4.39 5.03 5.47 5.95 6.22 6.45 6.6 6.74 6.84 6.84 6.87 6.91 6.88 6.85 6.77 6.5 6.05 5.5 4.89 4.24 3.57 3.0 2.5 2.08 1.78 1.47 1.25 1.01 0.79 0.73 0.68 0.54 0.42 0.45 0.36 0.28 0.3 0.29 0.23 0.25 0.26 0.2 0.18 0.22 0.18 0.14 0.11 0.19 0.18 0.14 0.11 0.1 0.41 0.95 1.43 1.77 1.95 1.97 1.91 1.86 1.74 1.67 1.58 1.48 1.36 1.24 1.15 1.08 1.01 0.93 0.9 0.88 0.86 0.85 0.82 0.83 0.87 0.87 0.88 0.89 0.9 0.89 0.95 0.95 0.96 1.0 1.01 1.0 1.05 1.06 1.05 1.08 1.08 1.09 1.1 1.12 1.13 1.13 1.15 1.16 1.17 1.21 1.21 1.23 1.23 1.27 1.25 1.27 1.29 1.3 1.31 1.34 1.34 1.34 1.36 1.39 1.4 1.42 1.44 1.45 1.42 1.46 1.45 1.45 1.45 1.45 1.47 1.46 1.45 1.47 1.48 1.49 1.46 1.49 1.51 1.5 1.49 1.52 1.52 1.52 1.51 1.52 1.52 1.48 1.48 1.5 1.53 1.49 1.48 1.5 1.52 1.51 1.49 1.51 1.5 1.46 1.49 1.48 1.48 1.5 1.47 1.51 1.49 1.49 1.48 1.47 1.43 1.41 1.43 1.45 1.43 1.44 1.47 1.49 1.44 1.47 1.44 1.37 1.36 1.38 1.39 1.38 1.4 1.4 1.39 1.39 1.42 1.38 1.4} {
            DSx_espresso_flow_preview_2x append [expr {1.9 * $DSx_flow}]
            }
        foreach DSx_flow_weight {0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.19 0.16 0.19 0.21 0.2 0.26 0.32 0.33 0.34 0.43 0.42 0.45 0.53 0.53 0.54 0.57 0.62 0.65 0.65 0.7 0.73 0.77 0.73 0.81 0.84 0.87 0.88 0.85 0.91 0.92 0.94 0.95 1.0 0.96 1.01 1.01 1.05 1.09 1.03 1.07 1.07 1.11 1.14 1.17 1.15 1.17 1.19 1.23 1.2 1.23 1.25 1.31 1.32 1.3 1.3 1.35 1.33 1.38 1.39 1.39 1.37 1.41 1.39 1.39 1.44 1.43 1.46 1.44 1.43 1.42 1.46 1.46 1.49 1.47 1.45 1.43 1.48 1.46 1.49 1.46 1.49 1.46 1.51 1.49 1.46 1.49 1.52 1.49 1.51 1.46 1.49 1.52 1.49 1.51 1.51 1.54 1.52 1.49 1.51 1.54 1.54 1.52 1.49 1.51 1.54 1.51 1.49 1.49 1.51 1.49 1.51 1.54 1.54 1.57 1.54 1.51 1.54 1.46 1.51 1.48 1.51 1.49 1.51 1.48 1.46 1.46 1.49 1.47} {
            DSx_espresso_flow_weight_preview_2x append [expr {2.2 * $DSx_flow_weight}]
            }
        } else {
        $::DSx_preview_graph_advanced configure -width 1 -height 1
        DSx_espresso_elapsed_preview length 0
        DSx_espresso_pressure_preview length 0
        DSx_espresso_flow_preview_2x length 0
        DSx_espresso_flow_weight_preview_2x length 0
    }
}

proc clear_temp_data {args} {
	DSx_espresso_temperature_basket length 0
    DSx_espresso_temperature_basket append [DSx_return_temperature_number $::settings(espresso_temperature)]
    DSx_espresso_temperature_mix length 0
    DSx_espresso_temperature_mix append [DSx_return_temperature_number $::settings(espresso_temperature)]
    DSx_espresso_temperature_goal length 0
    DSx_espresso_temperature_goal append [DSx_return_temperature_number $::settings(espresso_temperature)]
}

proc DSx_list_rotate {xs {n 1}} {
    if {$n == 0 || [llength $xs] == 0 } {return $xs}
    set n [expr {$n % [llength $xs]}]
    return [concat [lrange $xs $n end] [lrange $xs 0 [expr {$n-1}]]]
}

proc DSx_page_left {} {
    set pages [lsort -dictionary $::DSx_page_name]
    set index [lsearch $pages $::de1(current_context)]
    set sl [DSx_list_rotate $pages]
    set y [lindex $sl $index]
    return $y
}

proc DSx_page_right {} {
    set pages [lsort -dictionary $::DSx_page_name]
    set index [lsearch $pages $::de1(current_context)]
    set sl [DSx_list_rotate $pages -1]
    set y [lindex $sl $index]
    return $y
}

proc DSx_next_step {} {
    de1_send_state "skip to next" $::de1_state(SkipToNext)
}

##### DSx coffee

proc coffee_variables_check {} {
    if {[info exists ::DSx_settings(saturating_weight_rate)] == 0} {
        DSx_moveon_clear
    }
}

set ::DSx_step_saturating Saturating
set ::DSx_step_pressurising Pressurising
set ::DSx_step_extracting Extracting
set ::DSx_template_name_mocha Mocha
set ::DSx_template_name_smooth smooth
set ::DSx_template_name_fruity Fruity

proc DSx_moveon_clear {} {
    set ::DSx_settings(saturating_weight_rate) 0
    set ::DSx_settings(saturating_weight) 0
    set ::DSx_settings(pressurising_weight_rate) 0
    set ::DSx_settings(pressurising_weight) 0
    set ::DSx_settings(extracting_weight_rate) 0
    set ::DSx_settings(extracting_weight) 0
}

proc DSx_Coffee_control args {
    if {$::de1(state) == 4 && [info exists ::settings(current_frame_description)] == 1} {
        if {[string match -nocase *$::DSx_step_saturating* $::settings(current_frame_description)] == 1} {
            if {$::de1(scale_weight) > $::DSx_settings(saturating_weight) && $::DSx_settings(saturating_weight) != 0} {
                DSx_next_step
            }
            if {$::de1(scale_weight_rate) > $::DSx_settings(saturating_weight_rate) && $::DSx_settings(saturating_weight_rate) != 0} {
                DSx_next_step
            }
        }
        if {[string match -nocase *$::DSx_step_pressurising* $::settings(current_frame_description)] == 1} {
            if {$::de1(scale_weight) > $::DSx_settings(pressurising_weight) && $::DSx_settings(pressurising_weight) != 0} {
                DSx_next_step
            }
            if {$::de1(scale_weight_rate) > $::DSx_settings(pressurising_weight_rate) && $::DSx_settings(pressurising_weight_rate) != 0} {
                DSx_next_step
            }
        }
        if {[string match -nocase *$::DSx_step_extracting* $::settings(current_frame_description)] == 1} {
            if {$::de1(scale_weight) > $::DSx_settings(extracting_weight) && $::DSx_settings(extracting_weight) != 0} {
                DSx_next_step
            }
            if {$::de1(scale_weight_rate) > $::DSx_settings(extracting_weight_rate) && $::DSx_settings(extracting_weight_rate) != 0} {
                DSx_next_step
            }
        }
    }
}

proc DSx_saturating_weight_rate {} {
    if {$::DSx_settings(saturating_weight_rate) > 0 } {
        return [round_to_one_digits $::DSx_settings(saturating_weight_rate)]g/s
    } else {
        return off
    }
}
proc DSx_saturating_weight {} {
    if {$::DSx_settings(saturating_weight) > 0 } {
        return [round_to_one_digits $::DSx_settings(saturating_weight)]g
    } else {
        return off
    }
}
proc DSx_pressurising_weight_rate {} {
    if {$::DSx_settings(pressurising_weight_rate) > 0 } {
        return [round_to_one_digits $::DSx_settings(pressurising_weight_rate)]g/s
    } else {
        return off
    }
}
proc DSx_pressurising_weight {} {
    if {$::DSx_settings(pressurising_weight) > 0 } {
        return [round_to_one_digits $::DSx_settings(pressurising_weight)]g
    } else {
        return off
    }
}
proc DSx_extracting_weight_rate {} {
    if {$::DSx_settings(extracting_weight_rate) > 0 } {
        return [round_to_one_digits $::DSx_settings(extracting_weight_rate)]g/s
    } else {
        return off
    }
}
proc DSx_extracting_weight {} {
    if {$::DSx_settings(extracting_weight) > 0 } {
        return [round_to_one_digits $::DSx_settings(extracting_weight)]g
    } else {
        return off
    }
}

proc DSx_tap_multiplier {} {
    if {$::DSx_tap_multiplier == {- 0.1 +}} {
        set ::DSx_tap_multiplier {- 1.0 +}
    } else {
        set ::DSx_tap_multiplier {- 0.1 +}
    }
}

######## DSx coffee profile

proc DSx_coffee_temperature_adjust  {} {
    if {$::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2"} {
        set ::tempsl {}
        foreach s $::settings(advanced_shot) {
        lappend newlist $s
        array set x $s
        set stepw [ifexists x(weight)]
        if {$stepw == ""} {
            set x(weight) 0
        }
        set x(temperature) [round_to_one_digits [expr {$x(temperature) + $::DSx_settings(temperature_adjustment)}]]
        lappend newlist2 [array get x]
        set ::settings(advanced_shot) $newlist2
        }
        set ::tempsl_short {}
        foreach s_short [lrange $::settings(advanced_shot) 0 10] {
        array set x_short $s_short
        set spc {  ...  }
        append ::tempsl_short $x_short(name) $spc [return_temperature_measurement $x_short(temperature)]\n
        }
        set ::DSx_steps_output $::tempsl_short
        array set first_step [lindex $::settings(advanced_shot) 0]
        set ::settings(espresso_temperature) $first_step(temperature)
        DSx_profile_temp_adjusted
        set ::Dsx_temperature_shift_amount [expr {$::Dsx_temperature_shift_amount + $::DSx_settings(temperature_adjustment)}]
        set ::DSx_settings(temperature_adjustment) 0
    } else {
        set ::DSx_steps_output {}
    }
}

proc DSx_F {in} {
	if {[de1plus]} {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]\u00B0F}]
		} else {
			if {[round_to_half_integer $in] == [round_to_integer $in]} {
				# don't display a .0 on the number if it's not needed
				return [subst {[round_to_integer $in]\u00B0C}]
			} else {
				return [subst {[round_to_half_integer $in]\u00B0C}]
			}
		}
	} else {
		if {$::settings(enable_fahrenheit) == 1} {
			return [subst {[round_to_integer [celsius_to_fahrenheit $in]]\u00B0F}]
		} else {
			return [subst {[round_to_integer $in]\u00B0C}]
		}

	}
}

proc DSx_profile_temp_adjusted {} {
    if {$::settings(settings_profile_type) == "settings_2c" || $::settings(settings_profile_type) == "settings_2c2"} {
        set spc { }
        if {$::settings(enable_fahrenheit) == 1} {
            set cf "°F"
        } else {
            set cf "°C"
        }
        set s [string index $::settings(profile_title) end-1]

        if {$s == {°}} {
            if {$::settings(enable_fahrenheit) == 1} {
                set ::settings(profile_title) [regsub [round_to_integer [celsius_to_fahrenheit [expr {$::settings(espresso_temperature) - $::DSx_settings(temperature_adjustment)}]]] $::settings(profile_title) [round_to_integer [celsius_to_fahrenheit $::settings(espresso_temperature)]]]
            } else {
                set ::settings(profile_title) [regsub [expr {$::settings(espresso_temperature) - $::DSx_settings(temperature_adjustment)}] $::settings(profile_title) $::settings(espresso_temperature)]
            }
        } else {
            if {$::DSx_settings(temperature_adjustment) != 0} {
                if {$::settings(enable_fahrenheit) == 1} {
                    set ::settings(profile_title) $::settings(profile_title)$spc[round_to_integer [celsius_to_fahrenheit $::settings(espresso_temperature)]]$cf
                } else {
                    set ::settings(profile_title) $::settings(profile_title)$spc$::settings(espresso_temperature)$cf
                }
            }
        }
        save_settings_to_de1
        profile_has_changed_set_colors
        update_de1_explanation_chart
        fill_profiles_listbox
    }
}

proc DSx_temp_steps {} {
    if {$::settings(enable_fahrenheit) == 1} {
            return "°F"
        } else {
            return "°C"
        }
}
proc refresh_DSx_temperature {} {
    set ::DSx_settings(temperature_adjustment) 0
    DSx_coffee_temperature_adjust
}

proc load_DSx_coffee_mocha {} {
    if {$::settings(profile_title) == {DSx coffee mocha} && $::settings(profile_has_changed) == 1} {
        set ::settings(profile_has_changed) 0
        set ::DSx_saved_2 {DSx coffee has reset!}
        after 3000 {set ::DSx_saved_2 ""}
    }

    set ::settings(advanced_shot) {
        {exit_if 1 flow 8 volume 100 transition fast exit_flow_under 0 temperature 89.0 name Filling pressure 2.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.5 seconds 25.00 exit_pressure_under 0}
        {exit_if 0 flow 8 volume 100 transition fast exit_flow_under 0 temperature 88.5 name Saturating pressure 3.0 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 3.0 seconds 60.00 exit_pressure_under 0}
        {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 88.5 name Pressurising pressure 9.0 sensor coffee pump pressure exit_flow_over 6 exit_pressure_over 11 exit_pressure_under 0 seconds 60.00}
        {exit_if 0 volume 100 transition smooth exit_flow_under 0 temperature 88.0 name Extracting pressure 3.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.80 exit_pressure_over 11 seconds 60.00 exit_pressure_under 0}
        {exit_if 0 volume 100 transition fast exit_flow_under 0 temperature 88.0 name {Pressure Hold} pressure 3.0 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.80 exit_pressure_over 11 exit_pressure_under 0 seconds 127}
        {exit_if 0 flow 2.50 volume 100 transition fast exit_flow_under 0 temperature 88.0 name {Flow Limit} pressure 3.0 sensor coffee pump flow exit_flow_over 6 exit_pressure_over 11 seconds 127 exit_pressure_under 0}
        }
    set ::settings(profile_title) {DSx coffee mocha}
    set ::settings(profile) {DSx coffee mocha}
    set ::settings(profile_filename) {DSx coffee mocha}
    set ::settings(original_profile_title) {DSx coffee mocha}
    set ::settings(profile_to_save) {DSx coffee mocha}
    set ::DSx_settings(saturating_weight_rate) 0
    set ::DSx_settings(saturating_weight) 0.4
    set ::DSx_settings(pressurising_weight_rate) 1.8
    set ::DSx_settings(pressurising_weight) 0
    set ::DSx_settings(extracting_weight_rate) 0
    set ::DSx_settings(extracting_weight) 0
    set ::settings(final_desired_shot_weight_advanced) 42
    load_DSx_coffee_common_settings
}

proc load_DSx_coffee_smooth {} {
    if {$::settings(profile_title) == {DSx coffee mocha} && $::settings(profile_has_changed) == 1} {
        set ::settings(profile_has_changed) 0
        set ::DSx_saved_2 {DSx coffee has reset!}
        after 3000 {set ::DSx_saved_2 ""}
    }
    set ::settings(advanced_shot) {
        {exit_if 1 flow 11 volume 100 transition fast exit_flow_under 0 temperature 89.0 name Filling pressure 1.80 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 1.00 seconds 20 exit_pressure_under 0}
        {exit_if 0 flow 1.50 volume 100 transition fast exit_flow_under 0 temperature 88.5 name Saturating pressure 2.20 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 4 exit_pressure_under 0 seconds 20.00}
        {exit_if 1 flow 1.50 volume 100 transition fast exit_flow_under 0 temperature 88.0 name Pressurising pressure 8.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 1.50 exit_pressure_over 8.00 exit_pressure_under 0 seconds 8.00}
        {exit_if 1 flow 1.50 volume 100 transition fast exit_flow_under 0 temperature 88.0 name Extracting pressure 8.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.50 exit_pressure_over 11 exit_pressure_under 0 seconds 30.00}
        {exit_if 0 flow 1.50 volume 100 transition smooth exit_flow_under 0 temperature 88.0 name Decline pressure 2.20 sensor coffee pump pressure exit_type flow_over exit_flow_over 6 exit_pressure_over 11 seconds 58.00 exit_pressure_under 0}
        }
    set ::settings(profile_title) {DSx coffee smooth}
    set ::settings(profile) {DSx coffee smooth}
    set ::settings(profile_filename) {DSx coffee smooth}
    set ::settings(original_profile_title) {DSx coffee smooth}
    set ::settings(profile_to_save) {DSx coffee smooth}
    set ::DSx_settings(saturating_weight_rate) 0
    set ::DSx_settings(saturating_weight) 0.4
    set ::DSx_settings(pressurising_weight_rate) 0
    set ::DSx_settings(pressurising_weight) 0
    set ::DSx_settings(extracting_weight_rate) 1.5
    set ::DSx_settings(extracting_weight) 0
    set ::settings(final_desired_shot_weight_advanced) 36
    load_DSx_coffee_common_settings
}

proc load_DSx_coffee_fruity {} {
    if {$::settings(profile_title) == {DSx coffee fruity} && $::settings(profile_has_changed) == 1} {
        set ::settings(profile_has_changed) 0
        set ::DSx_saved_2 {DSx coffee has reset!}
        after 3000 {set ::DSx_saved_2 ""}
    }
    set ::settings(advanced_shot) {
        {exit_if 1 flow 4.00 volume 100 transition fast exit_flow_under 0 temperature 93.0 name Filling pressure 2.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.60 seconds 20 exit_pressure_under 0}
        {exit_if 1 flow 4.00 volume 100 transition smooth exit_flow_under 0 temperature 93.0 name {Buffering } pressure 1.00 sensor coffee pump pressure exit_type pressure_over exit_flow_over 6 exit_pressure_over 0.90 seconds 4.00 exit_pressure_under 0}
        {exit_if 0 flow 0.50 volume 100 transition smooth exit_flow_under 0 temperature 92.5 name Saturating pressure 2.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 3.00 exit_pressure_over 4 seconds 80.00 exit_pressure_under 0}
        {exit_if 1 flow 8.00 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name Pressurising pressure 6.00 sensor coffee pump flow exit_type pressure_over exit_flow_over 1.50 exit_pressure_over 7.00 exit_pressure_under 0 seconds 25.00}
        {exit_if 1 flow 1.50 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name Extracting pressure 7.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 2.50 exit_pressure_over 11 seconds 50.00 exit_pressure_under 0}
        {exit_if 0 flow 1.50 volume 100 transition smooth exit_flow_under 0 temperature 92.0 name Decline pressure 3.00 sensor coffee pump pressure exit_type flow_over exit_flow_over 6 exit_pressure_over 11 seconds 60.00 exit_pressure_under 0}
        }
    set ::settings(profile_title) {DSx coffee fruity}
    set ::settings(profile) {DSx coffee fruity}
    set ::settings(profile_filename) {DSx coffee fruity}
    set ::settings(original_profile_title) {DSx coffee fruity}
    set ::settings(profile_to_save) {DSx coffee fruity}
    set ::DSx_settings(saturating_weight_rate) 0.6
    set ::DSx_settings(saturating_weight) 1.4
    set ::DSx_settings(pressurising_weight_rate) 2.2
    set ::DSx_settings(pressurising_weight) 0
    set ::DSx_settings(extracting_weight_rate) 2.0
    set ::DSx_settings(extracting_weight) 0
    set ::settings(final_desired_shot_weight_advanced) 55
    load_DSx_coffee_common_settings
}

proc load_DSx_coffee_common_settings {} {
    set ::settings(beverage_type) espresso
    set ::settings(final_desired_shot_volume_advanced) 130
    set ::settings(final_desired_shot_volume_advanced_count_start) 0
    set ::settings(tank_desired_water_temperature) 0

    set ::settings(goal_is_basket_temp) 1
    set ::settings(preheat_temperature) 90
    set ::settings(author) Damian
    set ::settings(profile_has_changed) 0
    set ::settings(profile_notes) {DSx coffee requires a scale connected and DSx skin to operate.
    Changes to this profile will not save.
    By Damian Brakel https://www.diy.brakel.com.au/}
    set ::settings(profile_step) {}
    set ::settings(settings_profile_type) settings_2c
    set ::settings(temperature_target) portafilter
    check_steam_on
    set ::DSx_settings(orange_cup_indicator) { }
    set ::DSx_settings(blue_cup_indicator) { }
    set ::DSx_settings(pink_cup_indicator) { }
    clear_profile_font
    saw_switch
    save_DSx_settings
    save_settings
    save_settings_to_de1
    profile_has_changed_set_colors
    update_de1_explanation_chart
    fill_profiles_listbox
    LRv2_preview
    DSx_graph_restore
    refresh_DSx_temperature
}

##### Stuff to prevent saving DSx coffee as a profile #####

proc donotedit {} {
    set DSx_profile [string range $::settings(profile_title) 0 2]
    set s [string index $::settings(profile_title) end-1]
    if {$DSx_profile == {DSx} && $s != {°}} {
        return {Do not edit this page}
    } else {
        return ""
    }
}

proc no_save_DSx_coffee args {
    set DSx_profile [string range $::settings(profile_title) 0 2]
    set s [string index $::settings(profile_title) end-1]
    if {$DSx_profile == {DSx} && $s != {°}} {
		after 1 {delete_selected_profile;}
		set ::DSx_file_exists_message "You can not save DSx coffee"
        after 4000 {set ::DSx_file_exists_message ""}
	}
}

##### DSx Admin

proc DSx_app_update {} {
    if {$::DSx_settings(backup_b4_update) == 1} {
        borg spinner on
        file delete -force [homedir]BackUpCopy
        file copy -force [homedir] [homedir]BackUpCopy
        borg spinner off
        borg systemui $::android_full_screen_flags
    }
    set ::de1(app_update_button_label) [translate "Updating"]
    update;
    start_app_update
}

proc DSx_done_button {} {

    if {$::settings(steam_temperature) > 130} {
                set ::DSx_settings(steam_temperature_backup) $::settings(steam_temperature)
            }
    if {$::settings(steam_temperature) < 130} {
                set ::settings(steam_timeout) 0
            }
    if {$::settings(steam_temperature) > 130 && $::settings(steam_timeout) < 1} {
                set ::settings(steam_timeout) 1
            }
    save_DSx_settings
    save_settings
    if {[ifexists ::calibration_disabled_fahrenheit] == 1} {
			set ::settings(enable_fahrenheit) 1
			unset -nocomplain ::calibration_disabled_fahrenheit
			msg "Calibration re-enabled Fahrenheit"
		}
    save_settings_to_de1
    set_alarms_for_de1_wake_sleep
    say [translate {Done}] $::settings(sound_button_in)
    save_settings
    de1_send_steam_hotwater_settings
    de1_send_waterlevel_settings
    set_fan_temperature_threshold $::settings(fan_threshold)
    de1_enable_water_level_notifications
    set_next_page off DSx_5_admin
    page_show DSx_5_admin
}


proc DSx_fill_skin_listbox {} {
	set widget $::globals(DSx_tablet_styles_listbox)
	$widget delete 0 99999

	set cnt 0
	set ::current_skin_number 0
	foreach d [skin_directories] {
		if {$d == "CVS" || $d == "example"} {
			continue
		}
		$widget insert $cnt [translate $d]
		if {$::settings(skin) == $d} {
			set ::current_skin_number $cnt
		}
		if {[ifexists ::de1plus_skins($d)] == 1} {
			# mark skins that require the DE1PLUS model with a different color to highlight them
			$widget itemconfigure $cnt -background #F0F0FF
		}
		incr cnt

	}
	$widget selection set $::current_skin_number
	make_current_listbox_item_blue $widget
	DSx_preview_tablet_skin
	$widget yview $::current_skin_number

}

proc DSx_preview_tablet_skin {} {
	if {$::de1(current_context) != "DSx_admin_skin"} {
		return
	}
	msg "DSx_preview_tablet_skin"
	set w $::globals(DSx_tablet_styles_listbox)
	if {[$w curselection] == ""} {
		msg "no current skin selection"
		puts "::current_skin_number: $::current_skin_number"
		$w selection set $::current_skin_number
	}
	set skindir [lindex [skin_directories] [$w curselection]]
	set ::settings(skin) $skindir
	set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
	if {[file exists $fn] != 1} {
    	catch {
    		file mkdir "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/"
    	}
		puts "creating $fn"
        set rescale_images_x_ratio [expr {$::screen_size_height / 1600.0}]
        set rescale_images_y_ratio [expr {$::screen_size_width / 2560.0}]
		set src "[homedir]/skins/$skindir/2560x1600/icon.jpg"
		catch {
			$::DSx_table_style_preview_image read $src
			photoscale $::DSx_table_style_preview_image $rescale_images_y_ratio $rescale_images_x_ratio
			$::DSx_table_style_preview_image write $fn  -format {jpeg -quality 90}
		}

	} else {
		set fn "[homedir]/skins/$skindir/${::screen_size_width}x${::screen_size_height}/icon.jpg"
		$::DSx_table_style_preview_image read $fn
	}
	DSx_current_listbox_item $::globals(DSx_tablet_styles_listbox)
}

proc set_DSx_skins_scrollbar_dimensions {} {
    $::DSx_skin_scrollbar configure -length [winfo height $::globals(DSx_tablet_styles_listbox)]
    set coords [.can coords $::globals(DSx_tablet_styles_listbox) ]
    set newx [expr {[winfo width $::globals(DSx_tablet_styles_listbox)] + [lindex $coords 0]}]
    .can coords $::DSx_skin_scrollbar "$newx [lindex $coords 1]"
}

proc load_DSx_language {} {
	set stepnum [$::DSx_languages_widget curselection]
	if {$stepnum == ""} {
		return
	}
	if {$stepnum == 0} {
		set ::settings(language) ""
	} else {
		set ::settings(language) [lindex [translation_langs_array] [expr {($stepnum * 2) - 2}] ]
	}
	DSx_current_listbox_item $::DSx_languages_widget
}

proc fill_DSx_languages_listbox {} {

	set widget $::DSx_languages_widget

	$widget delete 0 99999
	set cnt 0
	set current_profile_number 0

	# on android we can automatically detect the language from the OS setting, and this is the preferred way to go
	$widget insert $cnt [translate Automatic]
	incr cnt

	set current 0

	foreach {code desc} [translation_langs_array] {

		if {$::settings(language) == $code} {
			set current $cnt
		}
		$widget insert $cnt "$desc"
		incr cnt
	}

	$widget selection set $current;
	DSx_current_listbox_item $::DSx_languages_widget

	$::DSx_languages_widget yview $current
}

proc set_DSx_languages_scrollbar_dimensions {} {
    $::DSx_languages_scrollbar configure -length [winfo height $::DSx_languages_widget]
    set coords [.can coords $::DSx_languages_widget ]
    set newx [expr {[winfo width $::DSx_languages_widget] + [lindex $coords 0]}]
    .can coords $::DSx_languages_scrollbar "$newx [lindex $coords 1]"
}

proc DSx_scheduler_feature_hide_show_refresh {} {
	if {$::de1(current_context) == "DSx_admin_saver"} {
		show_hide_from_variable $::DSx_scheduler_widgetids ::settings scheduler_enable write
	}
}

### DSx Plugin UI###


set ::DSx_plugin_message ""

proc DSx_active_plugin_files {} {
	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/skins/DSx/DSx_Plugins/" *.dsx]]
    set files [lsearch -inline -all -not -exact $files DSx_admin.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_backup.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_cal.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_coffee.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_theme.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_workflow.dsx]
    set files [lsearch -inline -all -not -exact $files DSx_plugin_UI.dsx]
	set dd {}
	foreach f $files {
	    set fn "[homedir]skins/DSx/DSx_Plugins/$f"
	    set name [file rootname $f]
	    set space { }
	    set name $name$space[package versions $name]
		lappend dd $name $f
	}
	return $dd
}

proc fill_DSx_active_plugin_listbox {} {
	unset -nocomplain ::DSx_active_plugin_filenames
	set widget $::globals(DSx_active_plugin_widget)
	$widget delete 0 99999
	set cnt 0
	array set DSx_active_plugin_files_array [DSx_active_plugin_files]
	foreach desc [lsort -decreasing -dictionary [array names DSx_active_plugin_files_array]] {
		set fn $DSx_active_plugin_files_array($desc)
		$widget insert $cnt $desc
		set ::DSx_active_plugin_filenames($cnt) $fn

		incr cnt
	}
}

proc set_DSx_active_plugin_scrollbar_dimensions {} {
	# set the height of the scrollbar to be the same as the listbox
	$::DSx_active_plugin_scrollbar configure -length [winfo height $::globals(DSx_active_plugin_widget)]
	set coords [.can coords $::globals(DSx_active_plugin_widget) ]
	set newx [expr {[winfo width $::globals(DSx_active_plugin_widget)] + [lindex $coords 0]}]
	.can coords $::DSx_active_plugin_scrollbar "$newx [lindex $coords 1]"
}

proc DSx_inactive_plugin_files {} {
	set files [lsort -dictionary [glob -nocomplain -tails -directory "[homedir]/skins/DSx/DSx_Plugins/" *.off]]
	set dd {}
	foreach f $files {
	    set fn "[homedir]skins/DSx/DSx_Plugins/$f"
	    set name [file rootname $f]
		lappend dd $name $f
	}
	return $dd
}

proc fill_DSx_inactive_plugin_listbox {} {
	unset -nocomplain ::DSx_inactive_plugin_filenames
	set widget $::globals(DSx_inactive_plugin_widget)
	$widget delete 0 99999
	set cnt 0
	array set DSx_inactive_plugin_files_array [DSx_inactive_plugin_files]
	foreach desc [lsort -decreasing -dictionary [array names DSx_inactive_plugin_files_array]] {
		set fn $DSx_inactive_plugin_files_array($desc)
		$widget insert $cnt $desc
		set ::DSx_inactive_plugin_filenames($cnt) $fn
		incr cnt
	}
}

proc set_DSx_inactive_plugin_scrollbar_dimensions {} {
	# set the height of the scrollbar to be the same as the listbox
	$::DSx_inactive_plugin_scrollbar configure -length [winfo height $::globals(DSx_inactive_plugin_widget)]
	set coords [.can coords $::globals(DSx_inactive_plugin_widget) ]
	set newx [expr {[winfo width $::globals(DSx_inactive_plugin_widget)] + [lindex $coords 0]}]
	.can coords $::DSx_inactive_plugin_scrollbar "$newx [lindex $coords 1]"
}

proc DSx_plugin_dir {} {
    return [homedir]/skins/DSx/DSx_Plugins
}

proc DSx_active_plugin_rename {} {
    catch {
        set ::restart 1
        set w $::globals(DSx_active_plugin_widget)
        unset -nocomplain plugin
        set cnt [$w curselection]
        set plugin [file rootname $::DSx_active_plugin_filenames($cnt)]
        set fn "[DSx_plugin_dir]/${plugin}.dsx"
        set nfn "[DSx_plugin_dir]/${plugin}.off"
        if {[file exists [DSx_plugin_dir]/${plugin}.off] == 1} {
            file delete -force [DSx_plugin_dir]/${plugin}.off
        }
        if {[catch {file rename $fn $nfn} err] == 0} {
            set ::DSx_plugin_message " $plugin   deactivated! \r\r When you tap the home button, you will be asked\r to exit and restart the app"
            fill_DSx_active_plugin_listbox
            fill_DSx_inactive_plugin_listbox
        } else {
            set ::DSx_plugin_message "Oops, try again"
            fill_DSx_active_plugin_listbox
            fill_DSx_intive_plugin_listbox
        }
    }
}

proc DSx_inactive_plugin_rename {} {
    catch {
        set ::restart 1
        set iw $::globals(DSx_inactive_plugin_widget)
        unset -nocomplain iplugin
        set icnt [$iw curselection]
        set iplugin [file rootname $::DSx_inactive_plugin_filenames($icnt)]
        set ifn "[DSx_plugin_dir]/${iplugin}.off"
        set infn "[DSx_plugin_dir]/${iplugin}.dsx"
        if {[catch {file copy $ifn $infn} err] == 0} {
            unset -nocomplain version

            if {[catch {source  [file join "./skins/DSx/DSx_Plugins/" ${iplugin}.dsx]} err] == 0} {
                page_show DSx_plugin_UI
                if {[info exists version] != 1} {
                    set version {1.0}
                }
                set ::DSx_plugin_message "$iplugin   activated! \r\r When you tap the home button, you will be asked\r to exit and restart the app"
                fill_DSx_active_plugin_listbox
                fill_DSx_inactive_plugin_listbox
            } else {
                file rename -force $infn $ifn
                set ::DSx_plugin_message "That pluging has problems!"
            }
        } else {
            set ::DSx_plugin_message "Oops, $iplugin is already active"
            fill_DSx_inactive_plugin_listbox
            fill_DSx_active_plugin_listbox
        }
    }
}

proc DSx_page_left2 {} {
    set pages [lsort -dictionary $::DSx_page_name]
    lappend pages {off}
    set pages [lsearch -inline -all -not -exact $pages DSx_5_admin]
    set pages [lsearch -inline -all -not -exact $pages DSx_7_backup]
    set pages [lsearch -inline -all -not -exact $pages DSx_2_cal]
    set pages [lsearch -inline -all -not -exact $pages DSx_3_coffee]
    set pages [lsearch -inline -all -not -exact $pages DSx_6_theme]
    set pages [lsearch -inline -all -not -exact $pages DSx_4_workflow]
    set index [lsearch $pages $::DSx_settings(first_page_from_saver)]
    set sl [DSx_list_rotate $pages]
    set y [lindex $sl $index]
    return $y
}

proc toggle_active_plugin_list {} {
    if {[lsearch -exact $::DSx_page_name $::DSx_settings(first_page_from_saver)] == -1} {
        set ::DSx_settings(first_page_from_saver) off
    }
    set ::DSx_settings(first_page_from_saver) [DSx_page_left2]
}



##########

### over write
proc profile_has_not_changed_set args {
	set ::settings(profile_has_changed) 0
    LRv2_preview
}

if { $::skin::dsx::use_event_system } {

	### TODO: Confirm if this can be done once, or really needs to be done on every update

	::de1::event::listener::on_major_state_change_add [lambda {event_dict} {
		if { [dict get $event_dict previous_state] == "Steam" } {
			backup_DSx_steam_graph
		}
	}]

	rename ::gui::update::append_live_data_to_espresso_chart \
		::skin::dsx::append_live_data_to_espresso_chart_orig
	msg -INFO "DSx: rename ::gui::update::append_live_data_to_espresso_chart" \
		"::skin::dsx::append_live_data_to_espresso_chart_orig"

	proc ::gui::update::append_live_data_to_espresso_chart {event_dict args} {

		if { ! [::de1::state::is_flow_state \
				[dict get $event_dict this_state] \
				[dict get $event_dict this_substate]] } { return }

		wsaw

		::skin::dsx::append_live_data_to_espresso_chart_orig $event_dict {*}$args

		dict with event_dict {

			# TODO: See above note on calling backup_DSx_steam_graph only once

			# if { $this_state == "Steam"} { backup_DSx_steam_graph }

			# DSx chooses p/f, rather than p/(f^2)

			set ::espresso_resistance(end) \
				[round_to_two_digits \
					 [expr { $GroupFlow > 0 &&  $GroupPressure > 0 ? \
							 (1/$GroupFlow)*($GroupPressure) : 0 }]]

			DSx_espresso_temperature_basket append \
				[DSx_return_temperature_number $HeadTemp]

			DSx_espresso_temperature_goal append \
				[DSx_return_temperature_number $SetHeadTemp]

			DSx_espresso_temperature_mix append \
				[DSx_return_temperature_number $MixTemp]
		}

		# Change from prior, record the data, then check for step-advance conditions
		# TODO: Confirm that this makes logical sense with Damian

		DSx_Coffee_control
	}

} else {

	rename ::append_live_data_to_espresso_chart ::skin::dsx::append_live_data_to_espresso_chart_orig
	msg "INFO: DSx: rename ::gui::update::append_live_data_to_espresso_chart" \
		"::skin::dsx::append_live_data_to_espresso_chart_orig"

	proc ::append_live_data_to_espresso_chart {args} {

		wsaw

		::skin::dsx::append_live_data_to_espresso_chart_orig {*}$args

		if {$::de1_num_state($::de1(state)) == "Steam"} { backup_DSx_steam_graph }

		# DSx chooses p/f, rather than p/(f^2)
		set ::espresso_resistance(end) \
			[round_to_two_digits \
				 [expr { $::de1(flow) > 0 && $::de1(pressure) > 0 ? \
						 (1/$::de1(flow))*($::de1(pressure)) : 0 }]]

		DSx_espresso_temperature_basket append \
			[DSx_return_temperature_number $::de1(head_temperature)]
		DSx_espresso_temperature_goal append \
			[DSx_return_temperature_number $::de1(goal_temperature)]
		DSx_espresso_temperature_mix append \
			[DSx_return_temperature_number $::de1(mix_temperature)]

		# Change from prior, record the data, then check for step-advance conditions
		# TODO: Confirm that this makes logical sense with Damian

		DSx_Coffee_control
	}
}
