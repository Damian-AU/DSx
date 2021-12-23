#### Skin by Damian Brakel ####

set ::DSx_settings(version) 5.02

package provide DSx_skin 1.0

package require lambda

package ifneeded DSx $::DSx_settings(version) [list source [file join "./skins/DSx/" skin.tcl]]
package ifneeded DSx_functions $::DSx_settings(version) [list source [file join "./skins/DSx/DSx_Code_Files/" DSx_functions.tcl]]
package require DSx_functions $::DSx_settings(version)

DSx_startup
profile_has_changed_set_colors
set listbox_font [DSx_font font 8]

if {[file exists "[skin_directory]/DSx_Home_Page/DSx_home.page"] == 1} {
    source [file join "./skins/DSx/DSx_Home_Page/" DSx_home.page]
    if {[info exists ::DSx_home_page_version] != 1} {
        set ::DSx_home_page_version {custom}
    }
} elseif {[file exists "[skin_directory]/DSx_Home_Page/DSx_2021_home.page"] == 1 && $::DSx_settings(DSx_home) == "2021home"} {
    source [file join "./skins/DSx/DSx_Home_Page/" DSx_2021_home.page]
} else {
    set ::DSx_home_page_version {}
    set ::DSx_settings(next_shot_DSx_home_coords) {500 1150}
    set ::DSx_settings(last_shot_DSx_home_coords) {2120 1150}
    ### Heading
    if {[ifexists ::DSx_settings(decent_logo)] == 1} {
        add_de1_image "$::DSx_home_pages" 1100 40 "[skin_directory_graphics]/decent_logo.png"
    } else {
        set ::DSx_heading [add_de1_variable "$::DSx_home_pages" 1280 100 -font [DSx_font font 30] -fill $::DSx_settings(heading_colour) -anchor "center" -textvariable {$::DSx_settings(heading)}]
    }
    #Clock
    set ::DSx_clock_font_var_1 [add_de1_variable "$::DSx_home_pages" 2420 80 -font [DSx_font "$::DSx_settings(clock_font)" 14.5] -fill $::DSx_settings(font_colour) -justify right -anchor "e" -textvariable {[DSx_clock]}]
    set ::DSx_clock_font_var_2 [add_de1_variable "$::DSx_home_pages" 2450 130 -font [DSx_font "$::DSx_settings(clock_font)" 6.4] -fill #efbf63 -justify center -anchor "e" -textvariable {[DSx_date]}]
    set ::DSx_clock_font_var_3 [add_de1_variable "$::DSx_home_pages" 2420 92 -font [DSx_font "$::DSx_settings(clock_font)" 8] -fill $::DSx_settings(font_colour) -justify left -anchor "w" -textvariable { [DSx_clock_s]}]
    set ::DSx_clock_font_var_4 [add_de1_variable "$::DSx_home_pages" 2426 60 -font [DSx_font "$::DSx_settings(clock_font)" 6] -fill #efbf63 -justify left -anchor "w" -textvariable { [DSx_clock_ap]}]

    ### Right side
    # Data
    add_de1_variable "$::DSx_standby_pages steam preheat_2 water" 1840 325 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 720] -textvariable {$::DSx_settings(live_graph_profile)}
    add_de1_variable "$::DSx_standby_pages steam preheat_2 water" 1840 375 -justify right -anchor "nw" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 720] -textvariable {[last_shot_date]}
    add_de1_variable "$::DSx_standby_pages" 2140 740 -justify center -anchor "n" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {[DSx_live_graph_data_timer]s   [DSx_live_graph_data_water]mL}
    add_de1_variable "$::DSx_standby_pages" 2140 780 -justify center -anchor "n" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {Ratio [round_to_one_digits $::DSx_settings(live_graph_beans)]g : $::DSx_settings(live_graph_weight)g ([last_extraction_ratio])}
    add_de1_variable "espresso" 2140 740 -justify center -anchor "n" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {[DSx_espresso_elapsed_timer]s   [DSx_water_data]mL}
    add_de1_variable "espresso" 2140 780 -justify center -anchor "n" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {Ratio [round_to_one_digits $::settings(grinder_dose_weight)]g : [round_to_one_digits $::de1(scale_sensor_weight)]g ([live_extraction_ratio])}
    add_de1_variable "espresso" 1810 370 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 520] -textvariable {[pressure_text]}
    add_de1_variable "espresso" 2120 370 -justify center -anchor "n" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 520] -textvariable {[waterflow_text]}
    add_de1_variable "espresso" 2440 370 -justify left -anchor "ne" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 520] -textvariable {[waterweight_text]}
    add_de1_variable "steam" 1830 1060 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 520] -textvariable {[pressure_text]}
    add_de1_variable "steam" 2440 1060 -justify left -anchor "ne" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -width [rescale_x_skin 520] -textvariable {[waterflow_text]}
    add_de1_image "$::DSx_home_pages" 1820 1280 "[skin_directory_graphics]/icons/setup.png"
    add_de1_image "$::DSx_home_pages" 2040 1280 "[skin_directory_graphics]/icons/settings.png"
    add_de1_image "$::DSx_home_pages" 2260 1280 "[skin_directory_graphics]/icons/power.png"
    add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); set ::current_espresso_page "off"; load_test; set_next_page off DSx_4_workflow; start_idle; page_show DSx_4_workflow} 1810 1250 2030 1500
    add_de1_button "$::DSx_standby_pages" { say [translate {settings}] $::settings(sound_button_in); set ::current_espresso_page "off"; show_settings;} 2030 1250 2250 1500
    add_de1_button "$::DSx_standby_pages" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; off_timer;} 2250 1250 2470 1500
    ### Left Side
    add_de1_image "$::DSx_home_pages" 140 350 "[skin_directory_graphics]/icons/history.png"
    add_de1_image "$::DSx_home_pages" 100 770 "[skin_directory_graphics]/icons/jug.png"
    add_de1_image "$::DSx_home_pages" 100 1270 "[skin_directory_graphics]/icons/bluecup.png"
    add_de1_image "$::DSx_home_pages" 320 1270 "[skin_directory_graphics]/icons/pinkcup.png"
    add_de1_image "$::DSx_home_pages" 540 1270 "[skin_directory_graphics]/icons/orangecup.png"
    add_de1_variable "$::DSx_home_pages" 360 350 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Group [group_head_heater_temperature_text]}
    add_de1_variable "$::DSx_home_pages" 360 400 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Steam [steamtemp_text]}
    add_de1_variable "$::DSx_home_pages" 360 450 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Tank [DSx_low_water]}
    add_de1_variable "$::DSx_home_pages" 580 490 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(red) -textvariable {[DSx_preheat_status]}
    set ::DSx_profile_name [add_de1_variable "$::DSx_home_pages" 410 640 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -width [rescale_x_skin 600] -textvariable {$::settings(profile_title)}]
    set ::DSx_bean_name [add_de1_variable "$::DSx_home_pages" 320 724 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_saw_name [add_de1_variable "$::DSx_home_pages" 320 774 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_sav_name [add_de1_variable "$::DSx_home_pages" 320 824 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_flush_name [add_de1_variable "$::DSx_home_pages" 320 874 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_steam_name [add_de1_variable "$::DSx_home_pages" 320 924 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_water_name [add_de1_variable "$::DSx_home_pages" 320 974 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {*}]
    set ::DSx_wsaw_name [add_de1_variable "$::DSx_home_pages" 320 1024 -justify right -anchor "nw" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[wsaw_fav_indicator]}]
    set ::DSx_jug_name [add_de1_variable "$::DSx_home_pages" 190 850 -justify center -anchor "n" -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_jug_label]}]
    add_de1_variable "$::DSx_home_pages" 350 720 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Beans - [round_to_one_digits $::DSx_settings(bean_weight)]g}
    add_de1_variable "$::DSx_home_pages" 350 770 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Shot - (1:[round_to_one_digits [expr (0.01 + $::DSx_settings(saw))/$::DSx_settings(bean_weight)]])  $::DSx_settings(saw)g}
    add_de1_variable "$::DSx_home_pages" 350 820 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_profile_type] [DSx_sav]}
    add_de1_variable "$::DSx_home_pages" 350 870 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Flush - [round_to_integer $::DSx_settings(flush_time)][translate "s"]}
    add_de1_variable "$::DSx_home_pages" 350 920 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Steam - [DSx_steam_time_text]}
    add_de1_variable "$::DSx_home_pages" 350 970 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Water - [return_liquid_measurement $::settings(water_volume)] [return_temperature_measurement $::settings(water_temperature)]}
    add_de1_variable "$::DSx_home_pages" 350 1020 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[wsaw_text]}
    add_de1_variable "$::DSx_home_pages" 200 1450 -justify center -anchor "s" -text "" -font [DSx_font notosansuiregular 24] -fill $::DSx_settings(blue) -textvariable {$::DSx_settings(blue_cup_indicator)}
    add_de1_variable "$::DSx_home_pages" 420 1450 -justify center -anchor "s" -text "" -font [DSx_font notosansuiregular 24] -fill $::DSx_settings(pink) -textvariable {$::DSx_settings(pink_cup_indicator)}
    add_de1_variable "$::DSx_home_pages" 640 1450 -justify center -anchor "s" -text "" -font [DSx_font notosansuiregular 24] -fill $::DSx_settings(orange) -textvariable {$::DSx_settings(orange_cup_indicator)}
    add_de1_button "$::DSx_standby_pages" {say [translate {}] $::settings(sound_button_in); history_prep;}  100 320 360 540
    add_de1_button "$::DSx_standby_pages" {say [translate {}] $::settings(sound_button_in); load_test; set ::Dsx_temperature_shift_amount 0; set_next_page off DSx_3_coffee; start_idle;}  360 320 700 540
    add_de1_button "$::DSx_standby_pages" {say [translate {}] $::settings(sound_button_in); show_settings; after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show off; set ::settings(active_settings_tab) settings_1; set_profiles_scrollbar_dimensions;}  100 550 700 720
    add_de1_button "$::DSx_standby_pages" {say [translate {}] $::settings(sound_button_in); load_test; set_next_page off DSx_4_workflow; start_idle} 320 730 700 1040
    add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); jug_toggle;} 100 750 320 980
    add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); load_bluecup; DSx_set_on; after 1200 DSx_set_off;} 90 1250 310 1500
    add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); load_pinkcup; DSx_set_on; after 1200 DSx_set_off;} 310 1250 530 1500
    add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); load_orangecup; DSx_set_on; after 1200 DSx_set_off;} 530 1250 750 1500

    ### Start button
    if {$::DSx_settings(bezel) == 1} {
        if {$::DSx_settings(dial) == 2} {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/SbuttonE.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/SbuttonF.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/SbuttonS.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/SbuttonW.png"
            } elseif {$::DSx_settings(dial) == 3} {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/SbuttonF.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/SbuttonS.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/SbuttonW.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/SbuttonE.png"
            } else {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/SbuttonE.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/SbuttonS.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/SbuttonF.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/SbuttonW.png"
        }
        } elseif {$::DSx_settings(bezel) == 2} {
        add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/2SbuttonA.png"
        add_de1_image "espresso" 830 250 "[skin_directory_graphics]/2SbuttonE.png"
        add_de1_image "steam" 830 250 "[skin_directory_graphics]/2SbuttonE.png"
        add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/2SbuttonE.png"
        add_de1_image "water" 830 250 "[skin_directory_graphics]/2SbuttonE.png"
        } else {
            if {$::DSx_settings(dial) == 2} {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/3SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/3SbuttonE.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/3SbuttonF.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/3SbuttonS.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/3SbuttonW.png"
            } elseif {$::DSx_settings(dial) == 3} {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/3SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/3SbuttonF.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/3SbuttonS.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/3SbuttonW.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/3SbuttonE.png"
            } else {
            add_de1_image "$::DSx_standby_pages" 830 250 "[skin_directory_graphics]/3SbuttonA.png"
            add_de1_image "espresso" 830 250 "[skin_directory_graphics]/3SbuttonE.png"
            add_de1_image "steam" 830 250 "[skin_directory_graphics]/3SbuttonS.png"
            add_de1_image "preheat_2" 830 250 "[skin_directory_graphics]/3SbuttonF.png"
            add_de1_image "water" 830 250 "[skin_directory_graphics]/3SbuttonW.png"
        }
    }
    add_de1_image "$::DSx_active_pages" 1200 570 "[skin_directory_graphics]/icons/stop.png"
    if {$::DSx_settings(icons) == 2} {
        if {$::DSx_settings(dial) == 2} {
            add_de1_image "$::DSx_standby_pages espresso" 1214 310 "[skin_directory_graphics]/icons/DEespresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1200 900 "[skin_directory_graphics]/icons/DEsteam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 1490 610 "[skin_directory_graphics]/icons/DEflush.png"
            add_de1_image "$::DSx_standby_pages water" 900 610 "[skin_directory_graphics]/icons/DEwater.png"
            add_de1_variable "preheat_2" 1570 590 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
            } elseif {$::DSx_settings(dial) == 3} {
            add_de1_image "$::DSx_standby_pages espresso" 1204 900 "[skin_directory_graphics]/icons/DEespresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1490 610 "[skin_directory_graphics]/icons/DEsteam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 900 610 "[skin_directory_graphics]/icons/DEflush.png"
            add_de1_image "$::DSx_standby_pages water" 1200 310 "[skin_directory_graphics]/icons/DEwater.png"
            add_de1_variable "preheat_2" 980 590 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
            } else {
            add_de1_image "$::DSx_standby_pages espresso" 1214 310 "[skin_directory_graphics]/icons/DEespresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1490 610 "[skin_directory_graphics]/icons/DEsteam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 1200 900 "[skin_directory_graphics]/icons/DEflush.png"
            add_de1_image "$::DSx_standby_pages water" 900 610 "[skin_directory_graphics]/icons/DEwater.png"
            add_de1_variable "preheat_2" 1280 890 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
            }
        } else {
        if {$::DSx_settings(dial) == 2} {
            add_de1_image "$::DSx_standby_pages espresso" 1180 320 "[skin_directory_graphics]/icons/espresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1180 900 "[skin_directory_graphics]/icons/steam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 1470 600 "[skin_directory_graphics]/icons/flush.png"
            add_de1_image "$::DSx_standby_pages water" 910 610 "[skin_directory_graphics]/icons/water.png"
            add_de1_variable "preheat_2" 1570 680 -text "" -font [DSx_font font 8] -fill #8efba2 -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
            } elseif {$::DSx_settings(dial) == 3} {
            add_de1_image "$::DSx_standby_pages espresso" 1180 900 "[skin_directory_graphics]/icons/espresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1470 600 "[skin_directory_graphics]/icons/steam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 890 600 "[skin_directory_graphics]/icons/flush.png"
            add_de1_image "$::DSx_standby_pages water" 1200 310 "[skin_directory_graphics]/icons/water.png"
            add_de1_variable "preheat_2" 990 680 -text "" -font [DSx_font font 8] -fill #8efba2 -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
            } else {
            add_de1_image "$::DSx_standby_pages espresso" 1180 320 "[skin_directory_graphics]/icons/espresso.png"
            add_de1_image "$::DSx_standby_pages steam" 1470 600 "[skin_directory_graphics]/icons/steam.png"
            add_de1_image "$::DSx_standby_pages preheat_2" 1180 870 "[skin_directory_graphics]/icons/flush.png"
            add_de1_image "$::DSx_standby_pages water" 910 610 "[skin_directory_graphics]/icons/water.png"
            add_de1_variable "preheat_2" 1280 950 -text "" -font [DSx_font font 8] -fill #8efba2 -anchor "center" -justify "center" -textvariable {[DSx_add_flush_time_extend_text]}
        }
    }
    add_de1_variable "$::DSx_standby_pages" 1280 680 -text [translate "START"] -font [DSx_font font 14] -fill $::DSx_settings(green) -anchor "center" -textvariable {[start_button_ready]}
    add_de1_variable "$::DSx_standby_pages" 1280 1180 -text [translate ""] -font [DSx_font font 20] -fill $::DSx_settings(blue) -anchor "center"  -textvariable {$::DSx_saved_2}
    # Count down timer
    add_de1_variable "steam" 1280 480 -text "" -font [DSx_font font 20] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {[DSx_steam_time]}
    add_de1_variable "preheat_2" 1280 480 -text "" -font [DSx_font font 20] -fill $::DSx_settings(font_colour) -anchor "center" -justify center -textvariable {[DSx_flush_time_display]}
    # DE1 connection and substate info
    add_de1_variable "$::DSx_standby_pages" 1280 600 -justify center -anchor "center" -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {[de1_connected_state_DSx]}
    add_de1_variable "$::DSx_standby_pages" 1280 560 -justify center -anchor "center" -text "" -font [DSx_font font 8] -fill $::DSx_settings(red) -textvariable {$::steam_off_message}
    if {$::DSx_settings(bezel) == 1} {
        if {$::DSx_settings(dial) == 2} {
            add_de1_variable "preheat_2" 1280 940 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {flushing HOT water}
            add_de1_variable "steam" 1280 786 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_steam_info]}
            add_de1_variable "water" 1280 940 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {pouring HOT water}
            add_de1_variable "espresso" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::settings(current_frame_description)}
            } elseif {$::DSx_settings(dial) == 3} {
            add_de1_variable "preheat_2" 1280 940 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {flushing HOT water}
            add_de1_variable "steam" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_steam_info]}
            add_de1_variable "water" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {pouring HOT water}
            add_de1_variable "espresso" 1280 486 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::settings(current_frame_description)}
            } else {
            add_de1_variable "preheat_2" 1280 786 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {flushing HOT water}
            add_de1_variable "steam" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_steam_info]}
            add_de1_variable "water" 1280 940 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {pouring HOT water}
            add_de1_variable "espresso" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::settings(current_frame_description)}
            }
        } else {
        add_de1_variable "preheat_2" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {flushing HOT water}
        add_de1_variable "steam" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_steam_info]}
        add_de1_variable "water" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {pouring HOT water}
        add_de1_variable "espresso" 1280 840 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::settings(current_frame_description)}
    }
    add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in); DSx_stop} 880 340 1660 1060
    add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); DSx_stop}  880 340 1660 1060
    add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); DSx_steam_state_off; DSx_stop; check_if_steam_clogged} 880 340 1660 1060
    add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); DSx_stop} 880 340 1660 1060
    if {$::DSx_settings(dial) == 2} {
        add_de1_button "off" {say [translate {espresso}] $::settings(sound_button_in); DSx_reset_graphs; DSx_espresso;} 1100 260 1460 540
        add_de1_button "preheat_2" {say [translate {flush2}] $::settings(sound_button_in); DSx_flush_extend} 1440 540 1730 860
        add_de1_button "off" {say [translate {flush}] $::settings(sound_button_in); DSx_flush} 1440 540 1730 860
        add_de1_button "off" {say [translate {steam}] $::settings(sound_button_in); DSx_steam} 1100 860 1460 1140
        add_de1_button "off" {say [translate {Hot water}] $::settings(sound_button_in); DSx_water;} 830 540 1120 860
        } elseif {$::DSx_settings(dial) == 3} {
        add_de1_button "off" {say [translate {espresso}] $::settings(sound_button_in); DSx_reset_graphs; DSx_espresso;} 1100 860 1460 1140
        add_de1_button "preheat_2" {say [translate {flush2}] $::settings(sound_button_in); DSx_flush_extend} 830 540 1120 860
        add_de1_button "off" {say [translate {flush}] $::settings(sound_button_in); DSx_flush} 830 540 1120 860
        add_de1_button "off" {say [translate {steam}] $::settings(sound_button_in); DSx_steam} 1440 540 1730 860
        add_de1_button "off" {say [translate {Hot water}] $::settings(sound_button_in); DSx_water;} 1100 260 1460 540
        } else {
        add_de1_button "off" {say [translate {espresso}] $::settings(sound_button_in); DSx_reset_graphs; DSx_espresso;} 1100 260 1460 540
        add_de1_button "preheat_2" {say [translate {flush2}] $::settings(sound_button_in); DSx_flush_extend} 1100 860 1460 1140
        add_de1_button "off" {say [translate {flush}] $::settings(sound_button_in); DSx_flush} 1100 860 1460 1140
        add_de1_button "off" {say [translate {steam}] $::settings(sound_button_in); DSx_steam} 1440 540 1730 860
        add_de1_button "off" {say [translate {Hot water}] $::settings(sound_button_in); DSx_water;} 830 540 1120 860
    }

    ## move on buttons
    if {$::DSx_settings(dial) == 3} {
        add_de1_variable "espresso" 1200 980 -justify center -anchor e -font [DSx_font font 8] -fill $::DSx_settings(green) -textvariable {tap to >>>}
        add_de1_variable "espresso" 1360 980 -justify center -anchor w -font [DSx_font font 8] -fill $::DSx_settings(green) -textvariable {<<< move on}
        add_de1_button "espresso" {DSx_next_step} 1000 880 1560 1140
    } else {
        add_de1_variable "espresso" 1200 410 -justify center -anchor e -font [DSx_font font 8] -fill $::DSx_settings(green) -textvariable {tap to >>>}
        add_de1_variable "espresso" 1360 410 -justify center -anchor w -font [DSx_font font 8] -fill $::DSx_settings(green) -textvariable {<<< move on}
        add_de1_button "espresso" {DSx_next_step} 1000 270 1560 530
    }
    dui add dbutton "espresso_zoomed" 1900 1280 \
    -bwidth 300 -bheight 300 -tags graph_shift_button \
    -labelvariable {\uf051} -label_font [DSx_font {Font Awesome 5 Pro-Regular-400} 10] -label_fill $::DSx_settings(green) -label_pos {0.5 0.5} \
    -command {DSx_next_step}

    ## scale
    if {$::DSx_settings(no_scale) == 1} {
        add_de1_image "$::DSx_home_pages" 880 1200 "[skin_directory_graphics]/big_scale1.png"
        if {$::android != 1} {
            set ::de1(scale_sensor_weight) 400
            } else {
            set ::de1(scale_weight_rate) -1
        }
        set ::show_net_weight " "
        if {$::de1(scale_sensor_weight) <= $::show_net_weight || $::DSx_settings(jug_g) < 50} {
            set ::show_net_weight " "
            } else {
            set ::show_net_weight [round_to_milk [expr ($::de1(scale_sensor_weight) - $::DSx_settings(jug_g))]]g
        }
        set ::show_net_bean_weight " "
        if {$::de1(scale_sensor_weight) <= $::show_net_bean_weight || $::DSx_settings(bean_offset) < 50} {
            set ::show_net_bean_weight " "
            } else {
            set ::show_net_bean_weight [round_to_bean [expr ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset))]]g
        }
        add_de1_variable "$::DSx_home_pages" 980 1270 -justify right -anchor "nw" -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[round_to_bean [expr ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset))]]}
        add_de1_variable "$::DSx_home_pages" 1280 1320 -justify center -anchor "n" -text "" -font [DSx_font font 13] -fill $::DSx_settings(font_colour) -textvariable {[round_to_one_digits $::de1(scale_sensor_weight)]g}
        add_de1_variable "$::DSx_home_pages" 1580 1270 -justify left -anchor "ne" -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[round_to_milk [expr ($::de1(scale_sensor_weight) - $::DSx_settings(jug_g))]]}
        add_de1_variable "$::DSx_home_pages" 1280 1270 -justify center -anchor "n" -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {+}
        add_de1_variable "$::DSx_home_pages" 1280 1400 -justify center -anchor "n" -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {-}
        add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); clear_steam_font; steam_time_calc; DSx_set_on; after 1200 DSx_set_off;} 1400 1250 1620 1500
        add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); clear_bean_font; DSx_set_dose; DSx_bean_set_on; after 1500 DSx_set_off;} 930 1250 1150 1500
        add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); vertical_clicker 5 5 ::de1(scale_sensor_weight) 100 750 %x %y %x0 %y0 %x1 %y1;} 1150 1200 1400 1570 ""
        } else {
        add_de1_image "$::DSx_home_pages" 880 1200 "[skin_directory_graphics]/big_scale1.png"
        if {$::android != 1} {
            set ::de1(scale_sensor_weight) 18
            } else {
            set ::de1(scale_weight_rate) -1
        }
        set ::show_net_weight " "
        if {$::de1(scale_sensor_weight) <= $::show_net_weight || $::DSx_settings(jug_g) < 20} {
            set ::show_net_weight " "
            } else {
            set ::show_net_weight [round_to_milk [expr ($::de1(scale_sensor_weight) - $::DSx_settings(jug_g))]]g
        }
        add_de1_variable "$::DSx_home_pages" 980 1270 -justify right -anchor "nw" -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[round_to_bean [expr ($::de1(scale_sensor_weight) - $::DSx_settings(bean_offset))]]}
        add_de1_variable "$::DSx_home_pages" 1290 1340 -justify center -anchor "n" -text "" -font [DSx_font font 13] -fill $::DSx_settings(font_colour) -textvariable {[round_to_one_digits $::de1(scale_sensor_weight)]g}
        add_de1_variable "$::DSx_home_pages" 1580 1270 -justify left -anchor "ne" -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[round_to_milk [expr ($::de1(scale_sensor_weight) - $::DSx_settings(jug_g))]]}
        # skale ble reconnection button
        add_de1_button "$::DSx_home_pages" {say [translate {connect}] $::settings(sound_button_in); scale_tare; catch {ble_connect_to_scale}} 1150 1200 1400 1500
        add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); clear_bean_font; DSx_set_dose; DSx_bean_set_on; after 1500 DSx_set_off;} 930 1250 1150 1500
        add_de1_button "$::DSx_standby_pages" {say "" $::settings(sound_button_in); clear_steam_font; steam_time_calc; DSx_set_on; after 1200 DSx_set_off;} 1400 1250 1620 1500
    }
    add_de1_variable "$::DSx_home_pages" 1280 1410 -justify center -anchor "n" -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour)  -textvariable {[DSx_scale_disconnected]}

    ### Graphs home stanby page
    # Steam graph
    add_de1_widget "$::DSx_standby_pages" graph 1810 850 {
        set ::DSx_home_steam_graph_1 $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            set_next_page off off_steam_zoomed;
            set_next_page steam steam_steam_zoomed;
            page_show $::de1(current_context);
        }
        $widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 4] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 4] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        #$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 5] -color #e73249  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -linewidth [rescale_x_skin 2]
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -subdivisions 1
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 220] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    # espresso graph
    add_de1_widget "$::DSx_standby_pages" graph 1800 440 {
        set ::DSx_home_espresso_graph_1 $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            DSx_reset_graphs;
            set_next_page off off_zoomed;
            set_next_page espresso espresso_zoomed;
            page_show $::de1(current_context);
        }
        $widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {2 2};
        $widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
        $widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 3] -color #AAAAAA  -pixels 0 ;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0;
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0  2  4  6  8  10  12}  -hide 0;
        $widget axis configure y2 -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max 6 -subdivisions 2 -majorticks {0  1  2  3  4  5  6} -hide 0;
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 300] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    ### Graphs action page
    # Steam graph
    add_de1_widget "steam" graph 1810 850 {
        set ::DSx_home_steam_graph_2 $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            set_next_page off off;
            set_next_page steam steam_steam_zoomed;
            page_show $::de1(current_context);
        }
        $widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 4] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 4] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        #$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 5] -color #e73249  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -linewidth [rescale_x_skin 2]
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -subdivisions 1
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 220] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    # Espresso action graph
    add_de1_widget "espresso" graph 1800 440 {
        set ::DSx_home_espresso_graph_2 $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            DSx_reset_graphs;
            set_next_page off off;
            set_next_page espresso espresso_zoomed;
            page_show $::de1(current_context);
        }
        $widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {2 2};
        $widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 4] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
        $widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 3] -color #AAAAAA  -pixels 0 ;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0;
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0  2  4  6  8  10  12}  -hide 0;
        $widget axis configure y2 -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max 6 -subdivisions 2 -majorticks {0  1  2  3  4  5  6} -hide 0;
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 300] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    ### Graphs non active action page
    # Steam graph
    add_de1_widget "espresso preheat_2 water" graph 1810 850 {
        set ::DSx_home_steam_graph_3 $widget
        bind $widget [platform_button_press] {
        }
        $widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 4] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 4] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        #$widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 5] -color #e73249  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -linewidth [rescale_x_skin 2]
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -subdivisions 1
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 220] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    # Espresso action graph
    add_de1_widget "preheat_2 steam water" graph 1800 440 {
        set ::DSx_home_espresso_graph_3 $widget
        bind $widget [platform_button_press] {

        }
        $widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth [rescale_x_skin 4] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {2 2};
        $widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 6] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
        $widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 6] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 4] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth [rescale_x_skin 3] -color #AAAAAA  -pixels 0 ;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0;
        $widget axis configure y -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0  2  4  6  8  10  12}  -hide 0;
        $widget axis configure y2 -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 5] -min 0.0 -max 6 -subdivisions 2 -majorticks {0  1  2  3  4  5  6} -hide 0;
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 650] -height [rescale_y_skin 300] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

    ### Graph (zoom) Pages
    #### to make the graph work for sim
    add_de1_variable "$::DSx_zoomed_pages $::DSx_steam_zoomed_pages" 0 2000 -font [DSx_font font 6] -fill #000 -textvariable {
        [pressure_text]
        [waterflow_text]
        [waterweight_text]
        [waterweightflow_text]
        [watervolume_text]
        [watertemp_text]
        [mixtemp_text]
        [steamtemp_text]
        [group_head_heater_temperature_text]
        [espresso_goal_temp_text]
        [pour_volume]
        [preinfusion_volume]
        [profile_type_text]
    }
    # zoomed espresso
    add_de1_widget "$::DSx_zoomed_pages" graph 40 70 {
        set ::DSx_espresso_zoomed_graph $widget
        bind $widget [platform_button_press] {
            set x [translate_coordinates_finger_down_x %x]
            set y [translate_coordinates_finger_down_y %y]
            if {$x < [rescale_y_skin 500]} {
                # left column clicked on chart, indicates zoom

                if {$y > [rescale_y_skin 610]} {
                    DSx_scroll_down
                } else {
                    DSx_scroll_up
                }
            } else {
            save_DSx_settings;
            set_next_page off off;
            set_next_page espresso_zoomed espresso;
            set_next_page espresso espresso;
            set_next_page off_zoomed off;
            page_show $::de1(current_context);
            }
        }
        $widget element create line2_espresso_pressure -xdata espresso_elapsed -ydata espresso_pressure -symbol none -label "" -linewidth $::DSx_settings(glt1) -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_temperature_basket -xdata espresso_elapsed -ydata DSx_espresso_temperature_basket -symbol none -label ""  -linewidth $::DSx_settings(glt2) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_temperature_mix -xdata espresso_elapsed -ydata DSx_espresso_temperature_mix -symbol none -label ""  -linewidth $::DSx_settings(glb2) -color #ff9900 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_flow_weight_2x  -xdata espresso_elapsed -ydata espresso_flow_weight_2x -symbol none -label "" -linewidth $::DSx_settings(glt4) -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_weight_2x  -xdata espresso_elapsed -ydata espresso_weight_chartable -symbol none -label "" -linewidth $::DSx_settings(glb4) -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes $::settings(chart_dashes_espresso_weight);
        $widget element create line_espresso_flow_2x  -xdata espresso_elapsed -ydata espresso_flow_2x -symbol none -label "" -linewidth $::DSx_settings(glt5) -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_espresso_resistance  -xdata espresso_elapsed -ydata espresso_resistance -symbol none -label "" -linewidth $::DSx_settings(glb1) -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0

        $widget element create line_espresso_flow_delta_1  -xdata espresso_elapsed -ydata espresso_flow_delta -symbol none -label "" -linewidth $::DSx_settings(glb5) -color #98c5ff -pixels 0 -smooth $::settings(live_graph_smoothing_technique)
        $widget element create line_espresso_state_change_1 -xdata espresso_elapsed -ydata espresso_state_change -label "" -linewidth $::DSx_settings(glt3) -color #AAAAAA  -pixels 0 ;
        $widget element create line_espresso_temperature_goal -xdata espresso_elapsed -ydata DSx_espresso_temperature_goal -symbol none -label "" -linewidth $::DSx_settings(glb3) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
        $widget element create line_espresso_pressure_goal -xdata espresso_elapsed -ydata espresso_pressure_goal -symbol none -label "" -linewidth $::DSx_settings(glb3) -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
        $widget element create line_espresso_flow_goal_2x  -xdata espresso_elapsed -ydata espresso_flow_goal_2x -symbol none -label "" -linewidth $::DSx_settings(glb3) -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 9] -min 0.0;
        $widget axis configure y -color #008c4c -tickfont [DSx_font font 9] -min $::DSx_settings(zoomed_y_axis_min) -max $::DSx_settings(zoomed_y_axis_max) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}  -hide 0;
        $widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 9] -min $::DSx_settings(zoomed_y2_axis_min) -max $::DSx_settings(zoomed_y2_axis_max) -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2490] -height [rescale_y_skin 1230] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    add_de1_image "$::DSx_zoomed_pages" 2200 1295 "[skin_directory_graphics]/icons/button5.png"
    add_de1_image "$::DSx_zoomed_pages" 40 1400 "[skin_directory_graphics]/icons/zoomminus.png"
    add_de1_image "$::DSx_zoomed_pages" 240 1400 "[skin_directory_graphics]/icons/zoomplus.png"
    add_de1_image "$::DSx_zoomed_pages" 1 375 "[skin_directory_graphics]/icons/zoomshift.png"
    add_de1_image "$::DSx_zoomed_pages" 480 1300 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 700 1300 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 920 1300 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 1140 1300 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 1360 1300 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 480 1444 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 700 1444 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 920 1444 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 1140 1444 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "$::DSx_zoomed_pages" 1360 1444 "[skin_directory_graphics]/icons/button4.png"
    add_de1_image "espresso_zoomed steam_steam_zoomed" 2258 1340 "[skin_directory_graphics]/icons/stop.png"
    # Reset
    set ::DSx_graph_temp_units_text [add_de1_variable "$::DSx_zoomed_pages" 20 1314 -text "" -font [DSx_font font 7] -fill #e73249 -anchor "w"  -justify "center" -textvariable {[DSx_graph_temp_units_text]}]
    set ::DSx_graph_reset_button_text [add_de1_variable "$::DSx_zoomed_pages" 240 1350 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center"  -justify "center" -textvariable {[DSx_graph_reset_button_text]}]
    add_de1_button "$::DSx_zoomed_pages" {say [translate {reset}] $::settings(sound_button_in); DSx_graph_reset_button;} 100 1200 400 1410
    # top row buttons
    add_de1_variable "$::DSx_zoomed_pages" 590 1370 -text "" -font [DSx_font font 8] -fill "#18c37e" -anchor "center"  -justify "center" -textvariable {[round_to_one_digits [expr $::de1(pressure)]]bar}
    add_de1_variable "$::DSx_zoomed_pages" 810 1370 -text "" -font [DSx_font font 8] -fill "#e73249" -anchor "center"  -justify "center" -textvariable {[group_head_heater_temperature_text]}
    add_de1_variable "$::DSx_zoomed_pages" 1030 1370 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center"  -justify "center" -textvariable {steps}
    add_de1_variable "$::DSx_zoomed_pages" 1250 1370 -text "" -font [DSx_font font 8] -fill "#a2693d" -anchor "center"  -justify "center" -textvariable {[round_to_one_digits [expr $::de1(scale_weight_rate)]]g/s}
    add_de1_variable "$::DSx_zoomed_pages" 1470 1370 -text "" -font [DSx_font font 8] -fill "#4e85f4" -anchor "center"  -justify "center" -textvariable {[round_to_one_digits [expr $::de1(flow)]]mL/s}
    # bottom row buttons
    add_de1_variable "$::DSx_zoomed_pages" 590 1515 -text "" -font [DSx_font font 8] -fill #e5e500 -anchor "center"  -justify "center" -textvariable {[DSx_R]}
    add_de1_variable "$::DSx_zoomed_pages" 810 1515 -text "" -font [DSx_font font 8] -fill "#ff9900" -anchor "center"  -justify "center" -textvariable {[mixtemp_text]}
    add_de1_variable "$::DSx_zoomed_pages" 1030 1515 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center"  -justify "center" -textvariable {goal}
    add_de1_variable "$::DSx_zoomed_pages" 1250 1515 -text "" -font [DSx_font font 8] -fill "#a2693d" -anchor "center"  -justify "center" -textvariable {[round_to_one_digits [expr $::de1(scale_weight)]]g }
    add_de1_variable "$::DSx_zoomed_pages" 1470 1515 -text "" -font [DSx_font font 8] -fill "#4e85f4" -anchor "center"  -justify "center" -textvariable {delta}

    add_de1_variable "off_zoomed" 1280 0 -text "" -font [DSx_font font 9] -fill $::DSx_settings(font_colour) -anchor n -textvariable {$::DSx_settings(live_graph_profile)   -   [last_shot_date]}
    add_de1_variable "off_zoomed" 1650 1340 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Beans   [round_to_one_digits $::DSx_settings(live_graph_beans)]g}
    add_de1_variable "off_zoomed" 1650 1400 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Shot   $::DSx_settings(live_graph_weight)g  ([last_extraction_ratio])}
    add_de1_variable "off_zoomed" 1650 1460 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Water  [DSx_live_graph_data_water]mL}
    add_de1_variable "off_zoomed" 1650 1520 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Time   [DSx_live_graph_data_timer]s}
    add_de1_variable "espresso_zoomed" 1650 1340 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Beans   [round_to_one_digits [expr $::settings(grinder_dose_weight)]]g}
    add_de1_variable "espresso_zoomed" 1650 1400 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Shot   [round_to_one_digits $::de1(scale_sensor_weight)]g  ([live_extraction_ratio])}
    add_de1_variable "espresso_zoomed" 1650 1460 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Water  [DSx_water_data]mL}
    add_de1_variable "espresso_zoomed" 1650 1520 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Time   [DSx_espresso_elapsed_timer]s}
    add_de1_variable "off_zoomed" 2342 1430 -text [translate "START"] -font [DSx_font font 13] -fill $::DSx_settings(green) -anchor "center" -justify "center" -textvariable {[start_text_if_espresso_ready]}
    add_de1_text "off_zoomed" 2342 1486 -text [translate "ESPRESSO"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center"
    add_de1_button "off_zoomed" {say [translate {espresso}] $::settings(sound_button_in); set ::DSxv 0; DSx_espresso;} 2200 1280 2560 1600
    add_de1_button "espresso_zoomed" {say [translate {stop}] $::settings(sound_button_in); set_next_page off off; start_idle} 2200 1280 2560 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); DSx_zoom_out;} 0 1420 230 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); DSx_zoom_in;} 230 1420 460 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_t1;} 480 1300 700 1440
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_t2;} 700 1300 920 1440
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_t3;} 920 1300 1140 1440
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_t4;} 1140 1300 1360 1440
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_t5;} 1360 1300 1580 1440
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_b1;} 480 1440 700 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_b2;} 700 1440 920 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_b3;} 920 1440 1140 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_b4;} 1140 1440 1360 1600
    add_de1_button "$::DSx_zoomed_pages" {say [translate {zoom}] $::settings(sound_button_in); push_b5;} 1360 1440 1580 1600

    # Steam zoomed
    add_de1_widget "$::DSx_steam_zoomed_pages" graph 40 0 {
        set ::DSx_home_steam_zoomed_graph $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            set_next_page off off;
            set_next_page steam_steam_zoomed steam;
            set_next_page steam steam;
            set_next_page off_steam_zoomed off;
            page_show $::de1(current_context);
        }
        $widget element create line_steam_pressure -xdata steam_elapsed -ydata steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 10] -color #18c37e  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget element create line_steam_flow -xdata steam_elapsed -ydata steam_flow -symbol none -label "" -linewidth [rescale_x_skin 10] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 6] -linewidth [rescale_x_skin 2]
        $widget axis configure y -color #008c4c -tickfont [DSx_font font 6] -min 0.0;
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2490] -height [rescale_y_skin 800] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

    add_de1_widget "$::DSx_steam_zoomed_pages" graph 40 800 {
        set ::DSx_home_steam_zoomed_graph $widget
        bind $widget [platform_button_press] {
            say [translate {zoom}] $::settings(sound_button_in);
            set_next_page off off;
            set_next_page steam_steam_zoomed steam;
            set_next_page steam steam;
            set_next_page off_steam_zoomed off;
            page_show $::de1(current_context);
        }
        $widget element create line_steam_temperature -xdata steam_elapsed -ydata steam_temperature -symbol none -label ""  -linewidth [rescale_x_skin 10] -color #e73249  -pixels 0 -dashes $::settings(chart_dashes_temperature);
        if {$::settings(enable_fahrenheit) == 1} {
            $widget axis configure y -color #e73249 -tickfont [DSx_font font 6] -min 250 -max 350;
        } else {
            $widget axis configure y -color #e73249 -tickfont [DSx_font font 6] -min 130 -max 180;
        }
        $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 6] -linewidth [rescale_x_skin 2]
        $widget grid configure -color $::DSx_settings(grid_colour)
    } -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2490] -height [rescale_y_skin 500] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
    add_de1_variable "steam_steam_zoomed" 1960 1400 -text "" -font [DSx_font font 20] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {[DSx_steam_time]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 1800 1430 -justify center -anchor "center" -text "" -font [DSx_font font 8] -fill $::DSx_settings(red) -textvariable {$::steam_off_message}
    add_de1_variable "steam_steam_zoomed" 1960 1460 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[DSx_steam_info]}
    add_de1_text "$::DSx_steam_zoomed_pages" 50 24 -text [translate "Pressure (bar)"] -font [DSx_font font 9] -fill "#008c4c" -justify "left" -anchor "nw"
    add_de1_text "$::DSx_steam_zoomed_pages" 2460 24 -text [translate "Flow (mL/s)"] -font [DSx_font font 9] -fill "#206ad4" -justify "left" -anchor "ne"
    add_de1_text "$::DSx_steam_zoomed_pages" 1600 24 -text [translate "Temperature ([return_html_temperature_units])"] -font [DSx_font font 9] -fill "#e73249" -justify "left" -anchor "nw"
    add_de1_image "$::DSx_steam_zoomed_pages" 2200 1295 "[skin_directory_graphics]/icons/button5.png"
    add_de1_variable "off_steam_zoomed" 2342 1430 -text [translate "START"] -font [DSx_font font 13] -fill $::DSx_settings(green) -anchor "center" -justify "center" -textvariable {[start_text_if_espresso_ready]}
    add_de1_text "off_steam_zoomed" 2342 1486 -text [translate "STEAM"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center"
    add_de1_button "off_steam_zoomed" {say [translate {steam}] $::settings(sound_button_in); DSx_steam} 2200 1280 2560 1600
    add_de1_button "steam_steam_zoomed" {say [translate {stop}] $::settings(sound_button_in); DSx_steam_state_off; set_next_page off off; start_idle; check_if_steam_clogged} 2200 1280 2560 1600

    add_de1_variable "$::DSx_steam_zoomed_pages" 300 1300 -justify right -anchor "nw" -font [DSx_font font 8] -fill #18c37e -textvariable {Pressure - [pressure_text]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 300 1360 -justify right -anchor "nw" -font [DSx_font font 8] -fill #4e85f4 -textvariable {Flow - [waterflow_text]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 300 1420 -justify right -anchor "nw" -font [DSx_font font 8] -fill #e73249 -textvariable {Temperature - [steamtemp_text]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 300 1480 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Steam Timer - [DSx_steam_time_text]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 1000 1300 -justify right -anchor "nw" -font [DSx_font font 8] -fill #18c37e -textvariable {}
    add_de1_variable "$::DSx_steam_zoomed_pages" 1000 1360 -justify right -anchor "nw" -font [DSx_font font 8] -fill #4e85f4 -textvariable {Flow setting - [return_steam_flow_calibration $::settings(steam_flow)]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 1000 1420 -justify right -anchor "nw" -font [DSx_font font 8] -fill #e73249 -textvariable {Temperature setting - [return_steam_heater_calibration $::settings(steam_temperature)]}
    add_de1_variable "$::DSx_steam_zoomed_pages" 1000 1480 -justify right -anchor "nw" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Counter - [round_to_integer $::settings(steaming_count)]}

    # end graphs #
}
#################################### end home page

# Sleep pages
add_de1_text "sleep" 2500 1440 -justify right -anchor "ne" -text [translate "Going to sleep"] -font [DSx_font font 20] -fill $::DSx_settings(font_colour)
add_de1_text "DSx_power" 1370 760 -justify left -anchor "ne" -text [translate "Power off  >>> "] -font [DSx_font font 16] -fill $::DSx_settings(font_colour)
add_de1_text "DSx_power" 1600 1400 -justify center -anchor center -text [translate "...or wait for sleep"] -font [DSx_font font 16] -fill $::DSx_settings(font_colour)
add_de1_button "DSx_power" {say [translate {sleep}] $::settings(sound_button_in); set ::current_espresso_page "off"; power_off} 1400 700 1600 900
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); set_next_page off off; start_idle; clearshit} 1280 0 2560 1600
add_de1_button "saver descaling cleaning" {say [translate {awake}] $::settings(sound_button_in); first_page_from_saver} 0 0 1280 1600


##### Setup Pages #####
### Common
add_de1_variable "$::DSx_other_pages" 2150 1560 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify center -anchor center -textvariable {[translate "$::DSx_home_page_version DSx Version [package version DSx] - by Damian"] }
add_de1_image "$::DSx_other_pages" 1820 1280 "[skin_directory_graphics]/icons/arrow_left.png"
add_de1_image "$::DSx_other_pages" 2260 1280 "[skin_directory_graphics]/icons/arrow_right.png"
add_de1_button "$::DSx_page_name" {set ::Dsx_temperature_shift_amount 0; page_show [DSx_page_right]; set_ble_scrollbar_dimensions; set_ble_scale_scrollbar_dimensions} 2250 1250 2470 1500
add_de1_button "$::DSx_page_name" {set ::Dsx_temperature_shift_amount 0; page_show [DSx_page_left]; set_ble_scrollbar_dimensions; set_ble_scale_scrollbar_dimensions} 1810 1250 2030 1500

# save
add_de1_image "$::DSx_other_pages" 2040 1280 "[skin_directory_graphics]/icons/home.png"
add_de1_button "$::DSx_other_pages" {say "" $::settings(sound_button_in); restore_DSx_live_graph; save_DSx_settings; save_settings;
    if {[ifexists ::settings_backup(calibration_flow_multiplier)] != [ifexists ::settings(calibration_flow_multiplier)]} {
        set_calibration_flow_multiplier $::settings(calibration_flow_multiplier)
    }
    if {[ifexists ::settings_backup(fan_threshold)] != [ifexists ::settings(fan_threshold)]} {
        set_fan_temperature_threshold $::settings(fan_threshold)
    }
    if {[ifexists ::settings_backup(water_refill_point)] != [ifexists ::settings(water_refill_point)]} {
        de1_send_waterlevel_settings
    }
    if {[array_item_difference ::settings ::settings_backup "steam_temperature steam_flow"] == 1} {
        # resend the calibration settings if they were changed
        de1_send_steam_hotwater_settings
        de1_enable_water_level_notifications
    }
    if {[array_item_difference ::settings ::settings_backup "enable_fahrenheit orientation screen_size_width saver_brightness use_finger_down_for_tap log_enabled hot_water_idle_temp espresso_warmup_timeout language skin waterlevel_indicator_on default_font_calibration waterlevel_indicator_blink display_rate_espresso display_espresso_water_delta_number display_group_head_delta_number display_pressure_delta_line display_flow_delta_line display_weight_delta_line allow_unheated_water display_time_in_screen_saver enabled_plugins plugin_tabs"] == 1  || [ifexists ::app_has_updated] == 1} {
        set_next_page off DSx_message; page_show DSx_message
        after 2000 app_exit
    } elseif {[ifexists ::settings_backup(scale_bluetooth_address)] == "" && [ifexists ::settings(scale_bluetooth_address)] != ""} {
        set_next_page off DSx_message; page_show DSx_message
        after 2000 app_exit
    } else {
        if {$::DSx_settings(graph_weight_total_b) != $::DSx_settings(graph_weight_total) \
            || $::DSx_settings(tare_off_b) != $::settings(tare_only_on_espresso_start) \
            || $::DSx_settings(font_size_b) != $::settings(default_font_calibration) \
            || $::restart == 1
            } {
            set_next_page off DSx_message; page_show DSx_message
            after 2000 app_exit
        } else {
            if {$::de1_num_state($::de1(state)) == "Sleep"} {
                page_show saver;
            } else {
                set_next_page off off; start_idle; page_show off;
            }
        }
    }
} 2030 1250 2250 1500

add_de1_variable "DSx_message" 1280 800 -font [DSx_font font 12] -fill $::DSx_settings(orange) -justify center -anchor center -textvariable {Shutting down to apply changes, please restart}

##### History Page ########################################################################################
set ::DSx_message2 ""

# EB VERSION: ##############################
set ::globals(DSx_past_shots_widget) [dui add listbox DSx_past 40 1000 -tags history_left_lbox -select_cmd ::load_DSx_past_shot \
	-canvas_height 480 -width 16 -background $::DSx_settings(bg_colour) -font [DSx_font font 8] -bd 0 \
	-foreground $::DSx_settings(font_colour) -borderwidth 1 -selectborderwidth 0 -relief flat \
	-highlightthickness 0 -selectmode single -selectbackground $::DSx_settings(font_colour) \
	-yscrollbar yes -yscrollbar_troughcolor $::DSx_settings(bg_colour)]

set ::globals(DSx_past2_shots_widget) [dui add listbox DSx_past 1940 1000 -tags history_right_lbox -select_cmd ::load_DSx_past2_shot \
	-canvas_height 480 -width 16 -background $::DSx_settings(bg_colour) -font [DSx_font font 8] -bd 0 \
	-foreground $::DSx_settings(font_colour) -borderwidth 1 -selectborderwidth 0 -relief flat \
	-highlightthickness 0 -selectmode single -selectbackground $::DSx_settings(font_colour) \
	-yscrollbar yes -yscrollbar_troughcolor $::DSx_settings(bg_colour)]

#### Graphs
## Left graph
add_de1_widget "DSx_past" graph 40 80 {
	set ::DSx_history_left_graph $widget
	bind $widget [platform_button_press] {
		say [translate {zoom}] $::settings(sound_button_in);
		reset_messages;
		set_next_page DSx_past DSx_past_zoomed;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past_line_espresso_flow_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line_espresso_flow_weight_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line2_espresso_pressure -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past_line_espresso_pressure_goal -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure_goal -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past_line_espresso_flow_goal_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_goal_2x -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
    $widget element create DSx_past_line_espresso_temperature_goal_01 -xdata espresso_elapsed1 -ydata DSx_past_espresso_temperature_goal_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_goal_curve) -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past_line_espresso_temperature_basket_01 -xdata espresso_elapsed1 -ydata DSx_past_espresso_temperature_basket_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_curve) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past_line_espresso_resistance  -xdata espresso_elapsed1 -ydata DSx_past_espresso_resistance -symbol none -label "" -linewidth $::DSx_settings(hist_resistance_curve) -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0
    $widget element create DSx_past_line_espresso_state_change_1 -xdata espresso_elapsed1 -ydata DSx_past_espresso_state_change -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #AAAAAA  -pixels 0 ;
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 7] -min 0.0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 7] -min 0.0 -max $::DSx_settings(zoomed_y_axis_max) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 7] -min 0.0 -max $::DSx_settings(zoomed_y2_axis_max) -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 1220] -height [rescale_y_skin 720] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

## Right graph
add_de1_widget "DSx_past" graph 1300 80 {
	set ::DSx_history_right_graph $widget
	bind $widget [platform_button_press] {
	    reset_messages;
		say [translate {zoom}] $::settings(sound_button_in);
		set_next_page DSx_past DSx_past2_zoomed;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past2_line_espresso_flow_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past2_line_espresso_flow_weight_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past2_line2_espresso_pressure -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_pressure_goal -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure_goal -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past2_line_espresso_flow_goal_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_goal_2x -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
    $widget element create DSx_past2_line_espresso_temperature_goal_01 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_temperature_goal_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_goal_curve) -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past2_line_espresso_temperature_basket_01 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_temperature_basket_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_curve) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_resistance  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_resistance -symbol none -label "" -linewidth $::DSx_settings(hist_resistance_curve) -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0
    $widget element create DSx_past2_line_espresso_state_change_1 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_state_change -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #AAAAAA  -pixels 0 ;
    $widget element create DSx_past2_line2_steam_pressure -xdata espresso_elapsed2 -ydata DSx_past2_steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line2_steam_flow -xdata espresso_elapsed2 -ydata DSx_past2_steam_flow -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line2_steam_temperature -xdata espresso_elapsed2 -ydata DSx_past2_steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 8] -color #e73249  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 7] -min 0.0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 7] -min 0.0 -max $::DSx_settings(zoomed_y_axis_max) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 7] -min 0.0 -max $::DSx_settings(zoomed_y2_axis_max) -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 1220] -height [rescale_y_skin 720] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

# Icon overlay graph
add_de1_widget "DSx_past" graph 1105 1018 {
	set ::DSx_history_icon_graph $widget
	bind $widget [platform_button_press] {
	    reset_messages;
		say [translate {zoom}] $::settings(sound_button_in);
		set_next_page DSx_past DSx_past;
		set_next_page DSx_past DSx_past3_zoomed;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past_line_espresso_flow_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 5] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line_espresso_flow_weight_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 5] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line2_espresso_pressure -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 5] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_flow_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 5] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget element create DSx_past2_line_espresso_flow_weight_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 5] -color #edd4c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget element create DSx_past2_line2_espresso_pressure -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 5] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 4] -min 0.0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 4] ;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 352] -height [rescale_y_skin 158] -background $::DSx_settings(bg_colour) -plotrelief flat

## History zoomed 1
add_de1_widget "DSx_past_zoomed" graph 30 80 {
	set ::DSx_history_left_zoomed_graph $widget
	bind $widget [platform_button_press] {
		say [translate {zoom}] $::settings(sound_button_in);
		set_next_page DSx_past DSx_past;
		set_next_page DSx_past_zoomed DSx_past;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past_line_espresso_flow_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line_espresso_flow_weight_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line2_espresso_pressure -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past_line_espresso_pressure_goal -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure_goal -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past_line_espresso_flow_goal_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_goal_2x -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
    $widget element create DSx_past_line_espresso_temperature_goal_01 -xdata espresso_elapsed1 -ydata DSx_past_espresso_temperature_goal_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_goal_curve) -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past_line_espresso_temperature_basket_01 -xdata espresso_elapsed1 -ydata DSx_past_espresso_temperature_basket_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_curve) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past_line_espresso_resistance  -xdata espresso_elapsed1 -ydata DSx_past_espresso_resistance -symbol none -label "" -linewidth $::DSx_settings(hist_resistance_curve) -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0
    $widget element create DSx_past_line_espresso_state_change_1 -xdata espresso_elapsed1 -ydata DSx_past_espresso_state_change -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #AAAAAA  -pixels 0 ;
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 9] -min 0.0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 9] -min 0.0 -max 17 -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 9] -min 0.0 -max 8.5 -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2500] -height [rescale_y_skin 1340] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

## History zoomed 2
add_de1_widget "DSx_past2_zoomed" graph 30 80 {
	set ::DSx_history_right_zoomed_graph $widget
	bind $widget [platform_button_press] {
		say [translate {zoom}] $::settings(sound_button_in);
		set_next_page DSx_past DSx_past;
		set_next_page DSx_past2_zoomed DSx_past;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past2_line_espresso_flow_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past2_line_espresso_flow_weight_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past2_line2_espresso_pressure -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_pressure_goal -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure_goal -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past2_line_espresso_flow_goal_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_goal_2x -symbol none -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {5 5};
    $widget element create DSx_past2_line_espresso_temperature_goal_01 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_temperature_goal_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_goal_curve) -color #ffa5a6 -smooth $::settings(live_graph_smoothing_technique) -pixels 0 -dashes {5 5};
    $widget element create DSx_past2_line_espresso_temperature_basket_01 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_temperature_basket_01 -symbol none -label ""  -linewidth $::DSx_settings(hist_temp_curve) -color #e73249 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_resistance  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_resistance -symbol none -label "" -linewidth $::DSx_settings(hist_resistance_curve) -color #e5e500 -smooth $::settings(live_graph_smoothing_technique) -pixels 0
    $widget element create DSx_past2_line_espresso_state_change_1 -xdata espresso_elapsed2 -ydata DSx_past2_espresso_state_change -label "" -linewidth $::DSx_settings(hist_goal_curve) -color #AAAAAA  -pixels 0 ;
    $widget element create DSx_past2_line2_steam_pressure -xdata espresso_elapsed2 -ydata DSx_past2_steam_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line2_steam_flow -xdata espresso_elapsed2 -ydata DSx_past2_steam_flow -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line2_steam_temperature -xdata espresso_elapsed2 -ydata DSx_past2_steam_temperature -symbol none -label "" -linewidth [rescale_x_skin 8] -color #e73249  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 9] -majorticks {0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 130 140 150 160 170}  -hide 0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 9] -min 0.0 -max 17 -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 9] -min 0.0 -max 8.5 -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2500] -height [rescale_y_skin 1340] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat

## History zoomed 3
add_de1_widget "DSx_past3_zoomed" graph 30 80 {
	set ::DSx_history_icon_zoomed_graph $widget
	bind $widget [platform_button_press] {
		say [translate {zoom}] $::settings(sound_button_in);
		set_next_page DSx_past DSx_past;
		set_next_page DSx_past3_zoomed DSx_past;
		page_show $::de1(current_context)
	}
	$widget element create DSx_past_line_espresso_flow_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line_espresso_flow_weight_2x  -xdata espresso_elapsed1 -ydata DSx_past_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
	$widget element create DSx_past_line2_espresso_pressure -xdata espresso_elapsed1 -ydata DSx_past_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #69fdb3  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $widget element create DSx_past2_line_espresso_flow_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #7aaaff -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget element create DSx_past2_line_espresso_flow_weight_2x  -xdata espresso_elapsed2 -ydata DSx_past2_espresso_flow_weight_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #edd4c1 -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget element create DSx_past2_line2_espresso_pressure -xdata espresso_elapsed2 -ydata DSx_past2_espresso_pressure -symbol none -label "" -linewidth [rescale_x_skin 8] -color #c5ffe7  -smooth $::settings(live_graph_smoothing_technique) -pixels 0  -dashes {2 2};
    $widget axis configure x -color $::DSx_settings(x_axis_colour) -tickfont [DSx_font font 9] -majorticks {0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 130 140 150 160 170}  -hide 0;
	$widget axis configure y -color #008c4c -tickfont [DSx_font font 9] -min 0.0 -max $::de1(max_pressure) -subdivisions 5 -majorticks {0 1 2 3 4 5 6 7 8 9 10 11 12}  -hide 0;
	$widget axis configure y2 -color #206ad4 -tickfont [DSx_font font 9] -min 0.0 -max 6 -subdivisions 2 -majorticks {0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8} -hide 0;
    $widget grid configure -color $::DSx_settings(grid_colour)
} -plotbackground $::DSx_settings(bg_colour) -width [rescale_x_skin 2500] -height [rescale_y_skin 1340] -borderwidth 1 -background $::DSx_settings(bg_colour) -plotrelief flat
add_de1_text "DSx_past_zoomed DSx_past3_zoomed" 2460 20 -text [translate "Flow (mL/s)"] -font [DSx_font font 8] -fill "#206ad4" -justify "left" -anchor "ne"
add_de1_text "DSx_past_zoomed DSx_past2_zoomed DSx_past3_zoomed" 50 20 -text [translate "Pressure (bar)"] -font [DSx_font font 8] -fill "#008c4c" -justify "left" -anchor "nw"
add_de1_variable "DSx_past_zoomed" 450 20 -text "" -font [DSx_font font 8] -fill #da5050 -anchor "nw" -justify left -textvariable {$::DSx_settings(hist_temp_key)}
add_de1_variable "DSx_past2_zoomed" 450 20 -text "" -font [DSx_font font 8] -fill #206ad4 -anchor "nw" -justify left -textvariable {[graph_flow_key_steam]}
add_de1_variable "DSx_past2_zoomed" 2460 20 -text "" -font [DSx_font font 8] -fill #206ad4 -anchor "ne" -justify left -textvariable {[graph_flow_key_espresso]}
add_de1_variable "DSx_past2_zoomed" 450 20 -text "" -font [DSx_font font 8] -fill #da5050 -anchor "nw" -justify left -textvariable {[graph_temp_key_espresso]}
add_de1_variable "DSx_past_zoomed DSx_past2_zoomed" 1900 20 -text "" -font [DSx_font font 8] -fill #a2693d -anchor "ne" -justify left -textvariable {[graph_weight_key]}
add_de1_variable "DSx_past2_zoomed" 2460 20 -text "" -font [DSx_font font 8] -fill #e73249 -anchor "ne" -justify left -textvariable {[graph_temp_key_steam]}


## Page
add_de1_image "DSx_past" 690 1000 "[skin_directory_graphics]/icons/button8.png"
add_de1_image "DSx_past" 1090 1000 "[skin_directory_graphics]/icons/button8.png"
add_de1_image "DSx_past" 1490 1000 "[skin_directory_graphics]/icons/button8.png"
add_de1_image "DSx_past" 690 1210 "[skin_directory_graphics]/icons/button8.png"
add_de1_image "DSx_past" 1090 1210 "[skin_directory_graphics]/icons/button8.png"
add_de1_image "DSx_past" 1490 1210 "[skin_directory_graphics]/icons/button8.png"

add_de1_image "DSx_past" 1690 1400 "[skin_directory_graphics]/icons/heart2.png"
add_de1_image "DSx_past" 1180 1390 "[skin_directory_graphics]/icons/home.png"
add_de1_image "DSx_past" 680 1390 "[skin_directory_graphics]/icons/store.png"
add_de1_text "DSx_past" 780 1524 -text [translate "archive"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); DSx_archive} 670 1390 890 1600
add_de1_button "DSx_past" {
    say "" $::settings(sound_button_in)
    if {$::de1_num_state($::de1(state)) == "Sleep"} {
                page_show saver;
            } else {
                set_next_page off off; start_idle; page_show off;
            }
    save_DSx_settings
} 1170 1390 1390 1600

add_de1_button "DSx_past" {
    if {$::de1_num_state($::de1(state)) != "Sleep"} {
        say "" $::settings(sound_button_in)
        unset -nocomplain ::settings_backup
        array set ::settings_backup [array get ::settings]
        set_next_page off describe_espresso0; page_show off
        set_god_shot_scrollbar_dimensions
    } else {
        set ::DSx_message2 "button inactive during sleep"; after 2000 reset_messages;
    }
} 1680 1390 1900 1600
source "[homedir]/skins/Insight/scentone.tcl"

#####
add_de1_text "DSx_past DSx_past_zoomed DSx_past2_zoomed DSx_past3_zoomed" 1280 30 -text [translate "History Viewer"] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_text "DSx_past" 2500 30 -text [translate "Flow (mL/s)"] -font [DSx_font font 7] -fill "#206ad4" -justify "left" -anchor "ne"
add_de1_text "DSx_past" 50 30 -text [translate "Pressure (bar)"] -font [DSx_font font 7] -fill "#008c4c" -justify "left" -anchor "nw"
add_de1_text "DSx_past" 2500 1 -text [translate "Weight (g/s)"] -font [DSx_font font 7] -fill "#a2693d" -justify "left" -anchor "ne"
add_de1_variable "DSx_past" 50 1 -text "" -font [DSx_font font 7] -fill #da5050 -anchor "nw" -justify left -textvariable {$::DSx_settings(hist_temp_key)}
add_de1_variable "DSx_past" 500 1 -text "" -font [DSx_font font 7] -fill #e5e500 -anchor "nw" -justify left -textvariable {$::DSx_settings(hist_resistance_key)}

add_de1_text "DSx_past" 1690 1050 -text [translate "showing"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_text "DSx_past" 880 1066 -text [translate "Save to"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_text "DSx_past" 880 1114 -text [translate "godshots"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_variable "DSx_past" 1694 1094 -text "" -font [DSx_font font 12] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {[history_godshot_steam]}
add_de1_variable "DSx_past" 1260 1360 -text "" -font [DSx_font font 14] -fill $::DSx_settings(red) -anchor "center" -justify "center" -textvariable {$::DSx_message2}
add_de1_text "DSx_past" 870 1250 -text [translate "Temperature"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_text "DSx_past" 1280 1250 -text [translate "Goals & Steps"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_text "DSx_past" 1680 1250 -text [translate "Resistance"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center"
add_de1_variable "DSx_past" 870 1304 -text "" -font [DSx_font font 12] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::DSx_settings(show_history_temperature)}
add_de1_variable "DSx_past" 1280 1304 -text "" -font [DSx_font font 12] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::DSx_settings(show_history_goal)}
add_de1_variable "DSx_past" 1680 1304 -text "" -font [DSx_font font 12] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::DSx_settings(show_history_resistance)}
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); set_next_page off off; history_godshots_switch; after 200; fill_DSx_past2_shots_listbox; reset_messages} 1506 1010 1870 1180
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); unset -nocomplain ::settings_backup; array set ::settings_backup [array get ::settings]; set_next_page off off; page_show DSx_h2g; reset_messages} 696 1010 1060 1180
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); history_graph_temperature;} 696 1210 1060 1380
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); history_graph_goal;} 1101 1210 1465 1380
add_de1_button "DSx_past" {say "" $::settings(sound_button_in); history_graph_resistance;} 1501 1210 1865 1380
## shot data
add_de1_variable "DSx_past" 640 56 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor center -justify center -textvariable {$::DSx_settings(shot_date_time)}
add_de1_variable "DSx_past" 40 800 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -justify left -width [rescale_x_skin  800] -textvariable {$::DSx_settings(past_profile_title)}
add_de1_variable "DSx_past" 1260 800 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "ne" -justify right -textvariable {$::DSx_settings(DSx_left_shot_time)    $::DSx_settings(past_bean_weight)g : $::DSx_settings(drink_weight)g (1:[round_to_one_digits [expr (0.01 + $::DSx_settings(drink_weight))/$::DSx_settings(past_bean_weight)]])}
add_de1_variable "DSx_past" 1260 850 -text "" -font [DSx_font font 7] -fill "#206ad4" -anchor "ne" -justify right -textvariable {[round_to_integer $::DSx_settings(past_volume1)]mL}
add_de1_variable "DSx_past" 1900 56 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor center -justify center -textvariable {$::DSx_settings(shot_date_time2)}

add_de1_variable "DSx_past" 1300 800 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -justify left -textvariable {[past_steam_settings_data]}
add_de1_variable "DSx_past" 1300 800 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -justify left -width [rescale_x_skin  800] -textvariable {[past_profile_title_right]}
add_de1_variable "DSx_past" 2520 800 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "ne" -justify right -textvariable {[past_shot_data_right]}
add_de1_variable "DSx_past" 2520 850 -text "" -font [DSx_font font 7] -fill "#206ad4" -anchor "ne" -justify right -textvariable {[past_shot_volume_right]}

## zoomed shot data
add_de1_variable "DSx_past_zoomed" 2510 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "e" -justify left -textvariable {$::DSx_settings(shot_date_time)}
add_de1_variable "DSx_past_zoomed" 50 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "w" -justify left -width [rescale_x_skin  500] -textvariable {$::DSx_settings(past_profile_title)}
add_de1_variable "DSx_past_zoomed" 1410 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "e" -justify right -textvariable {$::DSx_settings(DSx_left_shot_time)    $::DSx_settings(past_bean_weight)g : $::DSx_settings(drink_weight)g (1:[round_to_one_digits [expr (0.01 + $::DSx_settings(drink_weight))/$::DSx_settings(past_bean_weight)]])}
add_de1_variable "DSx_past_zoomed" 1450 1460 -text "" -font [DSx_font font 7] -fill "#206ad4" -anchor "w" -justify right -textvariable {[round_to_integer $::DSx_settings(past_volume1)]mL}
add_de1_variable "DSx_past2_zoomed" 2510 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "e" -justify left -textvariable {$::DSx_settings(shot_date_time2)}
add_de1_variable "DSx_past2_zoomed" 50 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "w" -justify left -textvariable {[past_profile_title_right]}
add_de1_variable "DSx_past2_zoomed" 50 1480 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "w" -justify left -textvariable {[past_steam_settings_data]}
add_de1_variable "DSx_past2_zoomed" 1410 1460 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "e" -justify right -textvariable {[past_shot_data_right]}
add_de1_variable "DSx_past2_zoomed" 1450 1460 -text "" -font [DSx_font font 7] -fill "#206ad4" -anchor "w" -justify right -textvariable {[past_shot_volume_right]}

### Page h2g
add_de1_text "DSx_h2g" 340 420 -text [translate "Save As..."] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_widget "DSx_h2g" entry 340 480  {
	set ::globals(widget_DSx_past_shot_save) $widget
	bind $widget <Return> {say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; hide_android_keyboard}
	bind $widget <Leave> hide_android_keyboard

	} -width 45 -font [DSx_font font 8]  -borderwidth 1 -bg #FFFFFF  -foreground #4e85f4 -textvariable ::DSx_settings(DSx_past2_espresso_name)
add_de1_text "DSx_h2g" 1640 465 -text [translate "Cancel"] -font [DSx_font font 14] -fill "#FF0000" -anchor "center"
add_de1_text "DSx_h2g" 2040 465 -text [translate "Save"] -font [DSx_font font 14] -fill "#00FF00" -anchor "center"
add_de1_button "DSx_h2g" {say "" $::settings(sound_button_in); set_next_page off off; page_show DSx_past;} 1460 386 1825 552
add_de1_button "DSx_h2g" {say "" $::settings(sound_button_in); DSx_save_h2g;} 1860 386 2225 552
set ::DSx_message ""
add_de1_variable "DSx_h2g" 1260 230 -text "" -font [DSx_font font 14] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {$::DSx_message}

###### DSx workflow ########################################################################################
add_de1_variable "DSx_4_workflow" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Workflow Setup Page}
# bean
add_de1_image "DSx_4_workflow" 100 154 "[skin_directory_graphics]/icons/bean.png"
add_de1_image "DSx_4_workflow" 100 340 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_4_workflow" 500 440 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[round_to_one_digits $::DSx_settings(bean_weight)]g}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 1 0.1 ::DSx_settings(bean_weight) 1 40 %x %y %x0 %y0 %x1 %y1; save_DSx_settings; clear_bean_font;} 100 340 900 540 ""
# saw
add_de1_image "DSx_4_workflow" 2260 134 "[skin_directory_graphics]/icons/espresso.png"
add_de1_variable "DSx_4_workflow" 2200 230 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {(1:[round_to_one_digits [expr (0.01 + $::DSx_settings(saw))/$::DSx_settings(bean_weight)]])}
add_de1_image "DSx_4_workflow" 1660 340 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_4_workflow" 2060 440 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[round_to_integer $::DSx_settings(saw)]g}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::DSx_settings(saw) 1 1000 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 1660 340 2460 540 ""
# steam
add_de1_image "DSx_4_workflow" 100 674 "[skin_directory_graphics]/icons/steam.png"
add_de1_image "DSx_4_workflow" 300 680 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_4_workflow" 700 780 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_steam_time_text]}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::settings(steam_timeout) 0 250 %x %y %x0 %y0 %x1 %y1; check_steam_on;} 300 680 1100 880 ""
# Jug
add_de1_image "DSx_4_workflow" 1110 674 "[skin_directory_graphics]/icons/jug.png"
add_de1_variable "DSx_4_workflow" 1200 750 -justify center -anchor "n" -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_jug_label]}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); jug_toggle;} 1110 680 1320 880
# flush
add_de1_image "DSx_4_workflow" 100 904 "[skin_directory_graphics]/icons/flush.png"
add_de1_image "DSx_4_workflow" 300 920 "[skin_directory_graphics]/icons/click.png"
add_de1_image "DSx_4_workflow" 1110 920 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_4_workflow" 700 1020 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[round_to_integer $::DSx_settings(flush_time)]s}
add_de1_variable "DSx_4_workflow" 1372 1020 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_flush_time_extend_text]}
add_de1_variable "DSx_4_workflow" 1372 1090 -justify center -anchor center -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {2nd tap extra time}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 10 1 ::DSx_settings(flush_time) 1 250 %x %y %x0 %y0 %x1 %y1; save_DSx_flush_time_to_settings; clear_flush_font;} 300 920 1100 1120 ""
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 1 1 ::DSx_settings(flush_time2) 0 20 %x %y %x0 %y0 %x1 %y1; save_DSx_settings;} 1110 920 1580 1120 ""
# water
add_de1_image "DSx_4_workflow" 120 1259 "[skin_directory_graphics]/icons/water.png"
add_de1_image "DSx_4_workflow" 300 1160 "[skin_directory_graphics]/icons/click.png"
add_de1_image "DSx_4_workflow" 1110 1160 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_4_workflow" 700 1310 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(blue) -textvariable {[wsaw_warning]}
add_de1_variable "DSx_4_workflow" 700 1260 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[return_liquid_measurement $::settings(water_volume)]}
add_de1_variable "DSx_4_workflow" 1372 1260 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[return_temperature_measurement $::settings(water_temperature)]}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 10 1 ::settings(water_volume) 10 400 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; clear_water_font;} 300 1160 1100 1360 ""
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 1 1 ::settings(water_temperature) 60 100 %x %y %x0 %y0 %x1 %y1; save_settings; de1_send_steam_hotwater_settings; clear_water_font;} 1110 1160 1580 1360 ""
# wsaw
add_de1_image "DSx_4_workflow" 300 1370 "[skin_directory_graphics]/icons/click.png"
add_de1_image "DSx_4_workflow" 1110 1370 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_4_workflow" 700 1470 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[wsaw_value]}
add_de1_variable "DSx_4_workflow" 1372 1470 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[wsaw_cal_value]}
add_de1_variable "DSx_4_workflow" 700 1540 -justify center -anchor center -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {Water stop at weight}
add_de1_variable "DSx_4_workflow" 1372 1540 -justify center -anchor center -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {off-set}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::DSx_settings(wsaw) 0 300 %x %y %x0 %y0 %x1 %y1; save_DSx_settings; save_wsaw_to_settings; clear_wsaw_font;} 300 1370 1100 1570 ""
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); horizontal_clicker 0.1 0.1 ::DSx_settings(wsaw_cal) 0 3 %x %y %x0 %y0 %x1 %y1; save_DSx_settings;} 1110 1370 1580 1570 ""
# favourite
add_de1_image "DSx_4_workflow" 1830 900 "[skin_directory_graphics]/icons/bluecup.png"
add_de1_image "DSx_4_workflow" 2050 900 "[skin_directory_graphics]/icons/pinkcup.png"
add_de1_image "DSx_4_workflow" 2270 900 "[skin_directory_graphics]/icons/orangecup.png"
add_de1_variable "DSx_4_workflow" 2150 849 -text "" -font [DSx_font font 8] -fill $::DSx_settings(green) -anchor "center" -justify "center" -textvariable {$::fave_saved}
add_de1_variable "DSx_4_workflow" 2140 1130 -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -textvariable {tap to save}
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); save_bluecup; fav_saved_on; after 1000 fav_saved_off;} 1820 890 2040 1110
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); save_pinkcup; fav_saved_on; after 1000 fav_saved_off;} 2040 890 2260 1110
add_de1_button "DSx_4_workflow" {say "" $::settings(sound_button_in); save_orangecup; fav_saved_on; after 1000 fav_saved_off;} 2260 890 2480 1110
# Profile
add_de1_variable "DSx_4_workflow" 1280 220 -text "" -font [DSx_font font 12] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -width [rescale_x_skin 1200] -textvariable {$::settings(profile_title)}
add_de1_button "DSx_4_workflow" {say [translate {}] $::settings(sound_button_in); set ::DSx_workflow_to_settings_1 1; show_settings; after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show off; set ::settings(active_settings_tab) settings_1; set_profiles_scrollbar_dimensions} 1040 140 1540 300
add_de1_image "DSx_4_workflow" 1210 340 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_4_workflow" 1340 310 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {flow}
add_de1_variable "DSx_4_workflow" 1490 310 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {mass}
add_de1_variable "DSx_4_workflow" 1200 380 -justify center -anchor e -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_saturating}
add_de1_variable "DSx_4_workflow" 1340 380 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_saturating_weight_rate]}
add_de1_variable "DSx_4_workflow" 1490 380 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_saturating_weight]}
add_de1_variable "DSx_4_workflow" 1200 440 -justify center -anchor e -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_pressurising}
add_de1_variable "DSx_4_workflow" 1340 440 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_pressurising_weight_rate]}
add_de1_variable "DSx_4_workflow" 1490 440 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_pressurising_weight]}
add_de1_variable "DSx_4_workflow" 1200 500 -justify center -anchor e -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_extracting}
add_de1_variable "DSx_4_workflow" 1340 500 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_extracting_weight_rate]}
add_de1_variable "DSx_4_workflow" 1490 500 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {[DSx_extracting_weight]}
add_de1_button "DSx_4_workflow" {say [translate {DSx coffee}] $::settings(sound_button_in); set ::Dsx_temperature_shift_amount 0; page_show DSx_3_coffee;} 1000 340 1600 540

###### DSx theme ########################################################################################
add_de1_widget "DSx_6_theme" entry 280 0 {
        set ::DSx_heading_entry $widget
        bind $widget <Return> { say [translate {save}] $::settings(sound_button_in); borg toast [translate "Saved"]; save_DSx_settings; hide_android_keyboard}
		bind $widget <Leave> hide_android_keyboard
    }  -width 21 -font [DSx_font font 30] -borderwidth 2 -bg $::DSx_settings(bg_colour) -textvariable ::DSx_settings(heading) -relief sunken -highlightthickness 0 -highlightcolor #000000 -justify center -foreground $::DSx_settings(heading_colour)
add_de1_widget "DSx_6_theme" checkbutton 2100 30 {set ::DSx_6_theme_checkbutton_logo $widget} -text [translate "Use the\rDecent Espresso\rlogo heading"] -indicatoron true -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify center -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(decent_logo) -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa -relief flat -command decent_logo_check;
set ::DSx_logo_message ""
add_de1_variable "DSx_6_theme" 2140 280 -font [DSx_font font 11] -fill $::DSx_settings(red) -justify center -anchor center -textvariable {$::DSx_logo_message}
proc decent_logo_check {} {
    if {[file exists "[skin_directory_graphics]/decent_logo.png"] == 1} {
        restart_set
    } else {
        set ::DSx_settings(decent_logo) 0
        set ::DSx_logo_message "I could not find\rthe decent_logo file"
        after 2000 {set ::DSx_logo_message ""}
    }
}
# Heading colour
add_de1_image "DSx_6_theme" 100 350 "[skin_directory_graphics]/icons/button7.png"
set ::DSx_6_theme_var_10_3 [add_de1_text "DSx_6_theme" 300 450 -font [DSx_font font 10] -justify center -anchor center -text [translate "Heading\rColor"] -fill $::DSx_settings(font_colour)]
set ::DSx_6_theme_var_7_1 [add_de1_text "DSx_6_theme" 300 570 -font [DSx_font font 7] -justify center -anchor center -text [translate "Default $::DSx_settings(font_colour)"] -fill $::DSx_settings(font_colour)]
add_de1_button "DSx_6_theme" {say "" $::settings(sound_button_in); heading_colour_picker;} 100 350 500 550
set ::dial [add_de1_image "DSx_6_theme" 860 730 ""]
set ::DSx_6_theme_var_10_1 [add_de1_variable "DSx_6_theme" 1280 240 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Theme Setup Page}]

add_de1_widget "DSx_6_theme" radiobutton 900 300 {set ::DSx_6_theme_home1 $widget} -text [translate "Use DSx 2021 home page"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(DSx_home) -value "2021home" -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 900 390 {set ::DSx_6_theme_home2 $widget} -text [translate "Use Dial Design home page"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(DSx_home) -value "dial" -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config

#set ::DSx_6_theme_var_10_2 [add_de1_variable "DSx_6_theme" 1160 440 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Dial Design}]
set ::DSx_6_theme_var_10_2 [add_de1_variable "DSx_6_theme" 1160 440 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {}]
set ::DSx_6_theme_var_8_1 [add_de1_variable "DSx_6_theme" 800 480 -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Bezel}]
set ::DSx_6_theme_var_8_2 [add_de1_variable "DSx_6_theme" 1100 480 -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Icons}]
set ::DSx_6_theme_var_8_3 [add_de1_variable "DSx_6_theme" 1400 480 -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor w -textvariable {Layout}]
add_de1_widget "DSx_6_theme" radiobutton 100 940 {set ::DSx_6_theme_radiobutton1 $widget} -text [translate "background 1"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(bg_name) -value bg1.jpg -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command theme_change
add_de1_widget "DSx_6_theme" radiobutton 100 1040 {set ::DSx_6_theme_radiobutton2 $widget} -text [translate "background 2"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(bg_name) -value bg2.jpg -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command theme_change
add_de1_widget "DSx_6_theme" radiobutton 100 1140 {set ::DSx_6_theme_radiobutton3 $widget} -text [translate "background 3"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(bg_name) -value bg3.jpg -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command theme_change
add_de1_widget "DSx_6_theme" radiobutton 100 1240 {set ::DSx_6_theme_radiobutton4 $widget} -text [translate "background 4"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(bg_name) -value bg4.jpg -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command theme_change
add_de1_widget "DSx_6_theme" radiobutton 100 1340 {set ::DSx_6_theme_radiobutton5 $widget} -text [translate "background 5"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(bg_name) -value bg5.jpg -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command theme_change
add_de1_widget "DSx_6_theme" radiobutton 760 520 {set ::DSx_6_theme_bezel_radiobutton1 $widget} -text [translate "Orig"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(bezel) -value 1 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 760 620 {set ::DSx_6_theme_bezel_radiobutton2 $widget} -text [translate "Clock"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(bezel) -value 2 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 760 720 {set ::DSx_6_theme_bezel_radiobutton3 $widget} -text [translate "Ring"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(bezel) -value 3 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 1060 520 {set ::DSx_6_theme_icons_radiobutton1 $widget} -text [translate "DSx"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(icons) -value 1 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 1060 620 {set ::DSx_6_theme_icons_radiobutton2 $widget} -text [translate "DE1.3"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(icons) -value 2 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 1360 520 {set ::DSx_6_theme_dial_radiobutton1 $widget} -text [translate "DSx"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(dial) -value 1 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 1360 620 {set ::DSx_6_theme_dial_radiobutton2 $widget} -text [translate "CLB"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(dial) -value 2 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
add_de1_widget "DSx_6_theme" radiobutton 1360 720 {set ::DSx_6_theme_dial_radiobutton3 $widget} -text [translate "DE1.3"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(dial) -value 3 -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command dial_config
dial_config_start

# Font
add_de1_image "DSx_6_theme" 100 650 "[skin_directory_graphics]/icons/button7.png"
set ::DSx_6_theme_var_12_1 [add_de1_variable "DSx_6_theme" 300 730 -font [DSx_font font 12] -fill $::DSx_settings(orange) -anchor center -textvariable {Font}]
set ::DSx_6_theme_var_7_3 [add_de1_variable "DSx_6_theme" 300 800 -font [DSx_font font 7] -width [rescale_x_skin 340] -fill $::DSx_settings(font_colour) -anchor center -textvariable {$::DSx_settings(font_name)}]
add_de1_button "DSx_6_theme" {say "" $::settings(sound_button_in); DSx_font_selection;} 100 650 500 850

#graph axis
add_de1_image "DSx_6_theme" 1880 420 "[skin_directory_graphics]/icons/click1.png"
set ::DSx_6_theme_var_18_1 [add_de1_variable "DSx_6_theme" 2124 520 -text "" -font [DSx_font font 18] -fill $::DSx_settings(font_colour) -anchor "center"  -textvariable {[round_to_integer $::DSx_settings(zoomed_y_axis_scale_default)]}]
set ::DSx_6_theme_var_7_2 [add_de1_variable "DSx_6_theme" 2124 670 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify center -anchor "center"  -textvariable {[translate "Set zoomed graph default\r y axis hight. (6 to 15)"]}]
add_de1_button "DSx_6_theme" {say "" $::settings(sound_button_in); horizontal_clicker_int 1 1 ::DSx_settings(zoomed_y_axis_scale_default) 6 15 %x %y %x0 %y0 %x1 %y1; DSx_reset_graphs; save_DSx_settings;} 1880 420 2360 620 ""
add_de1_widget "DSx_6_theme" checkbutton 1920 880 {set ::DSx_6_theme_checkbutton_1 $widget} -text [translate "Scale not used"] -indicatoron true -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(no_scale) -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa -relief flat -command restart_set;
add_de1_widget "DSx_6_theme" checkbutton 1920 960 {set ::DSx_6_theme_checkbutton_2 $widget} -text [translate "Hide Clock"] -indicatoron true -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(clock_hide) -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa -relief flat;
add_de1_widget "DSx_6_theme" checkbutton 1920 1040 {set ::DSx_6_theme_checkbutton_3 $widget} -text [translate "Original Clock font"] -indicatoron true  -font "[DSx_font "$::DSx_settings(clock_font)" 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(original_clock_font) -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa -relief flat -command DSx_clock_font;
set ::DSx_6_theme_var_9_1 [add_de1_variable "DSx_6_theme" 1000 1540 -text "" -font [DSx_font font 9] -fill $::DSx_settings(orange) -justify center -anchor "center"  -textvariable {[translate "Note: options in Orange require an app restart"]}]

###### DSx cal ########################################################################################
add_de1_widget "DSx_2_cal" checkbutton 920 500 {set ::DSx_2_cal_checkbutton_1 $widget} -text [translate "Select if you\rprefer to tare\rwith the empty\rjug before weighing\rwith milk"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(orange) -variable ::DSx_settings(pre_tare) -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground $::DSx_settings(orange) -relief flat -command save_DSx_settings;

set ::cal_instructions "Tare the scale with your empty jug, add some milk and record its weight, steam to your desired temperature and record the time. \rSet the weight for your empty jug/s and you're set to go! "
add_de1_variable "DSx_2_cal" 1920 840 -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -width [rescale_x_skin 1100] -textvariable {$::cal_instructions}
add_de1_variable "DSx_2_cal" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Steam by Weight Setup Page}
add_de1_variable "DSx_2_cal" 600 304 -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Empty jug weight}
add_de1_variable "DSx_2_cal" 600 604 -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Empty jug weight}
add_de1_variable "DSx_2_cal" 600 904 -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Empty jug weight}
add_de1_variable "DSx_2_cal" 2000 304 -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Milk net weight}
add_de1_variable "DSx_2_cal" 2000 604 -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Calibration time}
# jug 1
add_de1_image "DSx_2_cal" 180 134 "[skin_directory_graphics]/icons/jug.png"
add_de1_image "DSx_2_cal" 400 140 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_2_cal" 270 240 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {S}
add_de1_variable "DSx_2_cal" 760 180 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {X}
add_de1_variable "DSx_2_cal" 600 240 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[jug_s_cal_text]}
add_de1_button "DSx_2_cal" {say [translate {set jug}] $::settings(sound_button_in); set_jug_s} 180 140 800 340 ""
add_de1_button "DSx_2_cal" {say [translate {clear}] $::settings(sound_button_in); clear_jug_s} 720 120 850 220
# jug 2
add_de1_image "DSx_2_cal" 180 434 "[skin_directory_graphics]/icons/jug.png"
add_de1_image "DSx_2_cal" 400 440 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_2_cal" 270 540 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {M}
add_de1_variable "DSx_2_cal" 760 480 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {X}
add_de1_variable "DSx_2_cal" 600 540 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[jug_m_cal_text]}
add_de1_button "DSx_2_cal" {say [translate {set jug}] $::settings(sound_button_in); set_jug_m} 180 440 800 640 ""
add_de1_button "DSx_2_cal" {say [translate {clear}] $::settings(sound_button_in); clear_jug_m} 720 420 850 520
# jug 3
add_de1_image "DSx_2_cal" 180 734 "[skin_directory_graphics]/icons/jug.png"
add_de1_image "DSx_2_cal" 400 740 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_2_cal" 270 840 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {L}
add_de1_variable "DSx_2_cal" 760 780 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {X}
add_de1_variable "DSx_2_cal" 600 840 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[jug_l_cal_text]}
add_de1_button "DSx_2_cal" {say [translate {set jug}] $::settings(sound_button_in); set_jug_l} 180 740 800 940 ""
add_de1_button "DSx_2_cal" {say [translate {clear}] $::settings(sound_button_in); clear_jug_l} 720 720 850 820
# bean
add_de1_image "DSx_2_cal" 180 1034 "[skin_directory_graphics]/icons/bean.png"
add_de1_image "DSx_2_cal" 400 1040 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_2_cal" 600 1210 -justify center -anchor center -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -textvariable {Bean offset}
add_de1_variable "DSx_2_cal" 760 1080 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {X}
add_de1_variable "DSx_2_cal" 600 1140 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[bean_offset_text]}
add_de1_button "DSx_2_cal" {say [translate {set bean}] $::settings(sound_button_in); set_bean_offset} 180 1040 800 1240
add_de1_button "DSx_2_cal" {say [translate {clear}] $::settings(sound_button_in); clear_bean_offset} 720 1020 850 1120
add_de1_variable "DSx_2_cal" 500 1350 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Tap to set from scale.\rTap X to clear}
# jug full
add_de1_image "DSx_2_cal" 1380 134 "[skin_directory_graphics]/icons/jug_full.png"
add_de1_image "DSx_2_cal" 1600 140 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_2_cal" 2000 240 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[round_to_integer $::DSx_settings(milk_g)]g}
add_de1_button "DSx_2_cal" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::DSx_settings(milk_g) 1 600 %x %y %x0 %y0 %x1 %y1; set_jug} 1600 140 2400 340 ""
# time
add_de1_image "DSx_2_cal" 1380 434 "[skin_directory_graphics]/icons/steam_timer.png"
add_de1_image "DSx_2_cal" 1600 440 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_2_cal" 2000 540 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[round_to_integer $::DSx_settings(milk_s)]s}
add_de1_button "DSx_2_cal" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::DSx_settings(milk_s) 1 90 %x %y %x0 %y0 %x1 %y1; set_jug} 1600 440 2400 640 ""

###### DSx backup ########################################################################################
set ::done ""
set ::no_backup ""
set backup_instructions " The Backup button will copy the de1plus folder and its content to de1plusBackUpCopy \r any previous deplusBackUpCopy will be removed. "
set backup_recommend "Dont forget to backup before running updates, adding skins, or make other file changes"
add_de1_variable "DSx_7_backup" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Backup & Restore Page}
add_de1_image "DSx_7_backup" 880 1030 "[skin_directory_graphics]/icons/button7.png"
add_de1_image "DSx_7_backup" 1330 1030 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_7_backup" 1280 400 -text [translate "$backup_instructions"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center" -width [rescale_x_skin  2000]
add_de1_text "DSx_7_backup" 1280 580 -text [translate "$backup_recommend"] -font [DSx_font font 8] -fill "#5A9" -anchor "center" -width [rescale_x_skin  2000]
add_de1_text "DSx_7_backup" 1530 1130 -text [translate "Backup"] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center"
add_de1_variable "DSx_7_backup" 1280 750 -text "" -font [DSx_font font 12] -fill "#f00" -anchor "center" -justify "center" -textvariable {[translate "$::no_backup"]}
add_de1_variable "DSx_7_backup" 1280 850 -text "" -font [DSx_font font 12] -fill "#39C" -anchor "center" -justify "center" -textvariable {[translate "$::done"]}
add_de1_variable "DSx_7_backup" 1080 1130 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -width [rescale_x_skin 500] -textvariable {[translate $::skin_backup_button]}
add_de1_button "DSx_7_backup" {say [translate {restore}] $::settings(sound_button_in); skin_wait_message; restore_DSx_User_set } 890 1040 1260 1210
add_de1_button "DSx_7_backup" {say [translate {backup}] $::settings(sound_button_in); wait-message; after 500 {DSx_backup}} 1340 1040 1710 1210

###### DSx admin ########################################################################################
set ::DSx_language_slider 0
set ::DSx_languages_scrollbar [add_de1_widget "DSx_units" scale 1000 1000 {} -from 0 -to .50 -bigincrement 0.2 -background $::DSx_settings(font_colour) -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::DSx_language_slider -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::DSx_languages_widget $::DSx_language_slider}  -foreground $::DSx_settings(font_colour) -troughcolor $::DSx_settings(bg_colour) -borderwidth 0  -highlightthickness 0]
set ::DSx_skin_slider 0
set ::DSx_skin_scrollbar [add_de1_widget "DSx_admin_skin" scale 10000 1 {} -from 0 -to .90 -bigincrement 0.2 -background $::DSx_settings(font_colour) -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::DSx_skin_slider -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(DSx_tablet_styles_listbox) $::DSx_skin_slider}  -foreground $::DSx_settings(font_colour) -troughcolor $::DSx_settings(bg_colour) -borderwidth 0  -highlightthickness 0]

add_de1_widget "DSx_5_admin" checkbutton 1850 1180 {set ::DSx_5_admin_checkbutton_1 $widget} -text [translate "Backup before updating"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(backup_b4_update)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command save_DSx_settings

add_de1_image "DSx_descale_prepare" 1200 1450 "[skin_directory_graphics]/admin/cleanbuttonW.png"
add_de1_text "DSx_descale_prepare" 1490 1504 -text [translate "Clean now"] -font [DSx_font font 10] -fill "#444444" -anchor "center"
add_de1_button "DSx_descale_prepare" {say [translate {Clean}] $::settings(sound_button_in); start_cleaning} 1160 1200 1860 1600

add_de1_variable "DSx_5_admin" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Main Settings}
set ::de1(app_update_button_label) [translate "Update"]

# language & Units
add_de1_image "DSx_5_admin" 1530 240 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 1730 340 -text [translate "Language Units & Options"] -width [rescale_y_skin 380] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)" -justify "center" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Language}] $::settings(sound_button_in); set_next_page off DSx_units; page_show DSx_units; set_DSx_languages_scrollbar_dimensions;} 1540 240 1910 440

# skin
add_de1_image "DSx_5_admin" 1530 470 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 1730 570 -text [translate "Skin"] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Styles}] $::settings(sound_button_in); set_next_page off DSx_admin_skin; page_show DSx_admin_skin; DSx_preview_tablet_skin; set_DSx_skins_scrollbar_dimensions;} 1540 470 1910 670

# screen_saver
add_de1_image "DSx_5_admin" 1530 700 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 1730 800 -text [translate "Screen Saver"] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Screen Saver}] $::settings(sound_button_in); set_next_page off DSx_admin_saver; page_show DSx_admin_saver; DSx_scheduler_feature_hide_show_refresh;} 1540 700 1910 900

# firmware update
add_de1_image "DSx_5_admin" 1530 930 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_5_admin" 1730 1030 -text "" -width [rescale_y_skin 380] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -justify "center" -anchor "center" -textvariable {[check_firmware_update_is_available]FW [translate $::de1(firmware_update_button_label)]}
#add_de1_button "DSx_5_admin" {start_firmware_update} 1540 930 1910 1130
add_de1_button "DSx_5_admin" {set ::de1(in_fw_update_mode) 1; page_to_show_when_off firmware_update_1} 1540 930 1910 1130

# calibrate
add_de1_image "DSx_5_admin" 1950 240 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 2150 340 -text [translate "Machine Calibration"] -width [rescale_y_skin 380] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)"  -justify "center" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Calibrate}] $::settings(sound_button_in); calibration_gui_init; set_next_page off calibrate; page_show calibrate; }  1960 240 2330 440

# descale
add_de1_image "DSx_5_admin" 1950 470 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 2150 570 -text [translate "Clean & Descale"] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Descale}] $::settings(sound_button_in); set_next_page off DSx_descale_prepare; page_show DSx_descale_prepare;} 1960 470 2330 670

# transport
add_de1_image "DSx_5_admin" 1950 700 "[skin_directory_graphics]/icons/button7.png"
add_de1_text "DSx_5_admin" 2150 800 -text [translate "Transport"] -font [DSx_font font 9] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_button "DSx_5_admin" {say [translate {Transport}] $::settings(sound_button_in); set_next_page off DSx_travel_prepare; page_show DSx_travel_prepare; } 1960 700 2330 900

# app update
add_de1_image "DSx_5_admin" 1950 930 "[skin_directory_graphics]/icons/button7.png"
add_de1_variable "DSx_5_admin" 2150 1030 -text [translate "Update"] -width [rescale_y_skin 360] -font [DSx_font font 9] -fill $::DSx_settings(font_colour)  -justify "center" -anchor "center" -textvariable {App $::de1(app_update_button_label)}
add_de1_button "DSx_5_admin" {DSx_app_update} 1960 930 2330 1130

# data
add_de1_text "DSx_5_admin" 200 220 -text [translate "App Version       "][package version de1app] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_widget "DSx_5_admin" radiobutton 160 290  {set ::DSx_5_admin_version_radiobutton1 $widget} -value 0 -text [translate "stable"] -indicatoron true  -font [DSx_font font 8] -bg $::DSx_settings(bg_colour) -anchor ne -foreground $::DSx_settings(font_colour) -variable ::settings(app_updates_beta_enabled)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat
add_de1_widget "DSx_5_admin" radiobutton 360 290  {set ::DSx_5_admin_version_radiobutton2 $widget} -value 1 -text [translate "beta"] -indicatoron true  -font [DSx_font font 8] -bg $::DSx_settings(bg_colour) -anchor ne -foreground $::DSx_settings(font_colour) -variable ::settings(app_updates_beta_enabled)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat
add_de1_widget "DSx_5_admin" radiobutton 560 290  {set ::DSx_5_admin_version_radiobutton3 $widget} -value 2 -text [translate "nightly"] -indicatoron true  -font [DSx_font font 8] -bg $::DSx_settings(bg_colour) -anchor ne -foreground $::DSx_settings(font_colour) -variable ::settings(app_updates_beta_enabled)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat

add_de1_text "DSx_5_admin" 200 430 -text [translate {FW Version}] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "nw" -width [rescale_y_skin 1220] -justify "left"
add_de1_variable "DSx_5_admin" 200 500 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "nw" -width [rescale_y_skin 920] -justify "left" -textvariable {[de1_version_string]}
add_de1_text "DSx_5_admin" 200 640 -text [translate "Counters"] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_text "DSx_5_admin" 200 710 -text [translate "Espresso"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "nw"
add_de1_text "DSx_5_admin" 200 760 -text [translate "Steam"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "nw"
add_de1_text "DSx_5_admin" 200 810 -text [translate "Hot water"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "nw"
add_de1_variable "DSx_5_admin" 600 710 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "ne" -textvariable {[round_to_integer $::settings(espresso_count)]}
add_de1_variable "DSx_5_admin" 600 760 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "ne" -textvariable {[round_to_integer $::settings(steaming_count)]}
add_de1_variable "DSx_5_admin" 600 810 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "ne" -textvariable {[round_to_integer $::settings(water_count)]}

# bluetooth connect
add_de1_text "DSx_5_admin" 60 970 -text [translate "Bluetooth Connect"] -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_variable "DSx_5_admin" 980 1016 -text {} -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor "center"  -textvariable {[scanning_state_text]}
add_de1_button "DSx_5_admin" {say [translate {Search}] $::settings(sound_button_in); scanning_restart} 650 960 1260 1070
add_de1_text "DSx_5_admin" 60 1100 -text [translate "Espresso machine"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_text "DSx_5_admin" 680 1100 -text [translate "Scale"] -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_variable "DSx_5_admin" 1240 1100 -text \[[translate "Remove"]\] -font [DSx_font font 7] -fill "#bec7db" -justify "right" -anchor "ne" -textvariable {[if {$::settings(scale_bluetooth_address) != ""} { return \[[translate "Remove"]\]} else {return "" } ] }
add_de1_variable "DSx_5_admin" 900 1100 -font [DSx_font font 7] -fill "#bec7db" -justify "left" -anchor "nw" -textvariable {[if {$::settings(scale_bluetooth_address) != ""} { return [return_weight_measurement [ifexists ::de1(scale_weight_rate_raw)]] } else {return "" } ] }
add_de1_button "DSx_5_admin" {say [translate {Remove}] $::settings(sound_button_in);set ::settings(scale_bluetooth_address) ""; fill_peripheral_listbox} 960 1100 1250 1140 ""

add_de1_widget "DSx_5_admin settings_4" listbox 55 1150 {
    set ::ble_listbox_widget $widget
    bind $::ble_listbox_widget <<ListboxSelect>> ::change_bluetooth_device
    fill_ble_listbox
} -background #fbfaff -font [DSx_font font 9] -bd 0 -height 3 -width 15 -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground #c0c4e1 -yscrollcommand {scale_scroll_new $::ble_listbox_widget ::ble_slider}
add_de1_widget "DSx_5_admin settings_4" listbox 670 1150 {
    set ::ble_scale_listbox_widget $widget
    bind $widget <<ListboxSelect>> ::change_scale_bluetooth_device
    fill_peripheral_listbox
} -background #fbfaff -font [DSx_font font 9] -bd 0 -height 3 -width 15  -foreground #d3dbf3 -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground #c0c4e1 -yscrollcommand {scale_scroll_new $::ble_scale_listbox_widget ::ble_scale_slider}
set ::ble_slider 0
set ::ble_scrollbar [add_de1_widget "DSx_5_admin settings_4" scale 10000 1 {} -from 0 -to 1.0 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::ble_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::ble_listbox_widget $::ble_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]
set ::ble_scale_slider 0
set ::ble_scale_scrollbar [add_de1_widget "DSx_5_admin settings_4" scale 10000 1 {} -from 0 -to .90 -bigincrement 0.2 -background "#d3dbf3" -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 400] -width [rescale_y_skin 150] -variable ::ble_scale_slider -font Helv_10_bold -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::ble_scale_listbox_widget $::ble_scale_slider}  -foreground #FFFFFF -troughcolor "#f7f6fa" -borderwidth 0  -highlightthickness 0]
proc set_ble_scrollbar_dimensions {} {
    set_scrollbar_dimensions $::ble_scrollbar $::ble_listbox_widget
}
proc set_ble_scale_scrollbar_dimensions {} {
    set_scrollbar_dimensions $::ble_scale_scrollbar $::ble_scale_listbox_widget
}

###### Sub Pages ######
# "done" button for all these sub-pages.
add_de1_image "DSx_admin_saver DSx_units DSx_admin_skin" 1080 1210 "[skin_directory_graphics]/icons/button7.png"

add_de1_text "DSx_admin_saver DSx_units DSx_admin_skin" 1280 1310 -text [translate "Done"] -font [DSx_font font 10] -fill "#fAfBff" -anchor "center"
add_de1_button "DSx_admin_saver DSx_units DSx_admin_skin" {DSx_done_button} 980 1210 1580 1410 ""

### Skin
add_de1_text "DSx_admin_skin" 1280 60 -text [translate "Skin"] -font [DSx_font font 10] -width 1200 -fill $::DSx_settings(font_colour) -anchor "center" -justify "center"
set ::DSx_table_style_preview_image [add_de1_image "DSx_admin_skin" 1400 450 ""]
add_de1_widget "DSx_admin_skin" listbox 260 450 {
    set ::globals(DSx_tablet_styles_listbox) $widget
    DSx_fill_skin_listbox
    bind $::globals(DSx_tablet_styles_listbox) <<ListboxSelect>> ::DSx_preview_tablet_skin
} -background $::DSx_settings(bg_colour) -yscrollcommand {scale_scroll ::DSx_skin_slider} -font [DSx_font font 10] -bd 0 -height 10 -width 30 -foreground $::DSx_settings(font_colour) -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single -selectbackground $::DSx_settings(font_colour)

### Language Units & Options
# Language
add_de1_text "DSx_units" 1280 60 -text [translate "Language, Units & Options"] -font [DSx_font font 10] -width 1200 -fill $::DSx_settings(font_colour) -anchor "center" -justify "center"
add_de1_text "DSx_units" 260 300 -text [translate "Language"] -font [DSx_font font 8] -width 1200 -fill $::DSx_settings(font_colour) -anchor "nw" -justify "left"
add_de1_widget "DSx_units" listbox 260 390 {
    set ::DSx_languages_widget $widget
    bind $widget <<ListboxSelect>> ::load_DSx_language
    fill_DSx_languages_listbox
} -background $::DSx_settings(bg_colour) -yscrollcommand {scale_scroll ::DSx_language_slider} -font [DSx_font font 10] -bd 0 -height 6 -width 20 -foreground $::DSx_settings(font_colour) -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground $::DSx_settings(font_colour)
# Screen brightness
add_de1_image "DSx_units" 1480 260 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_units" 1880 360 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::settings(app_brightness)%}
add_de1_variable "DSx_units" 1880 480 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[translate "Screen brightness"]}
add_de1_button "DSx_units" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::settings(app_brightness) 0 100 %x %y %x0 %y0 %x1 %y1; save_settings;} 1480 260 2280 460 ""
#font size
add_de1_image "DSx_units" 1880 580 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_units" 2124 680 -text "" -font [DSx_font font 14] -fill $::DSx_settings(font_colour) -anchor "center"  -textvariable {$::settings(default_font_calibration)}
add_de1_variable "DSx_units" 2124 810 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -justify center -anchor "center"  -textvariable {[translate "Font size editor. Default = 0.5"]}
add_de1_button "DSx_units" {say "" $::settings(sound_button_in); horizontal_clicker 1 1 ::DSx_settings(font_size) 1 100 %x %y %x0 %y0 %x1 %y1; save_DSx_settings; DSx_font_cal;} 1880 580 2360 780 ""
# Options
add_de1_widget "DSx_units" checkbutton 1400 660 {} -text [translate "Fahrenheit"] -indicatoron true  -font [DSx_font font 10] -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(enable_fahrenheit)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa
add_de1_widget "DSx_units" checkbutton 1400 740 {} -text [translate "AM/PM"] -indicatoron true  -font [DSx_font font 10] -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(enable_ampm)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa
add_de1_widget "DSx_units" checkbutton 1400 820 {} -text [translate "1.234,56"] -indicatoron true  -font [DSx_font font 10] -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(enable_commanumbers)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa
add_de1_widget "DSx_units" checkbutton 1400 900 {set ::DSx_theme_checkbutton_2 $widget} -text [translate "Tare only on espresso start"] -indicatoron true  -font "[DSx_font font 10]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(tare_only_on_espresso_start)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command save_settings
add_de1_widget "DSx_units" checkbutton 1400 980 {} -text [translate "Save steam history"] -indicatoron true  -font "[DSx_font font 10]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::DSx_settings(save_DSx_steam_history)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command save_DSx_settings

# Water level
add_de1_text "DSx_units" 260 910  -text [translate "Refill level"] -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -justify "left" -anchor "nw"
add_de1_widget "DSx_units" scale 260 970 {} -from 3 -to 70 -background $::DSx_settings(bg_colour) -borderwidth 1 -bigincrement 1 -showvalue 0 -resolution 1 -length [rescale_x_skin 610] -width [rescale_y_skin 115] -variable ::settings(water_refill_point) -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground $::DSx_settings(font_colour) -troughcolor $::DSx_settings(bg_colour) -borderwidth 1  -highlightthickness 0
#add_de1_variable "DSx_units" 260 1100 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Refill at:"] [water_tank_level_to_milliliters $::settings(water_refill_point)] [translate mL] ($::settings(water_refill_point)[translate mm])}
add_de1_variable "DSx_units" 260 1100 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -width 800 -justify "left" -textvariable {[translate "Refill at:"] [water_tank_level_to_milliliters $::settings(water_refill_point)] [translate mL] ([expr {$::settings(water_refill_point) + $::de1(water_level_mm_correction)}][translate mm])}
add_de1_variable "DSx_units" 890 914 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "ne" -width [rescale_y_skin 1000] -justify "right" -textvariable {[translate "Now:"] [water_tank_level_to_milliliters $::de1(water_level)] [translate mL] ([round_to_integer $::de1(water_level)][translate mm])}

### Screen Saver Page
add_de1_text "DSx_admin_saver" 1280 60 -text [translate "Screen Saver"] -font [DSx_font font 10] -width 1200 -fill $::DSx_settings(font_colour) -anchor "center" -justify "center"
# Sleep timer
add_de1_image "DSx_admin_saver" 400 310 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_admin_saver" 800 410 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::settings(screen_saver_delay)min}
add_de1_variable "DSx_admin_saver" 800 530 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[translate "Sleep timer"]}
add_de1_button "DSx_admin_saver" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::settings(screen_saver_delay) 0 120 %x %y %x0 %y0 %x1 %y1; save_settings;} 400 310 1200 510 ""
# brightness
add_de1_image "DSx_admin_saver" 1400 310 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_admin_saver" 1800 410 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::settings(saver_brightness)%}
add_de1_variable "DSx_admin_saver" 1800 530 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[translate "Brightness"]}
add_de1_button "DSx_admin_saver" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::settings(saver_brightness) 0 100 %x %y %x0 %y0 %x1 %y1; save_settings;} 1400 310 2200 510 ""
# interval
add_de1_image "DSx_admin_saver" 1400 650 "[skin_directory_graphics]/icons/click.png"
add_de1_variable "DSx_admin_saver" 1800 750 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::settings(screen_saver_change_interval)min}
add_de1_variable "DSx_admin_saver" 1800 870 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[screen_saver_change_minutes $::settings(screen_saver_change_interval)]}
add_de1_button "DSx_admin_saver" {say "" $::settings(sound_button_in); horizontal_clicker_int 10 1 ::settings(screen_saver_change_interval) 0 120 %x %y %x0 %y0 %x1 %y1; save_settings;} 1400 650 2200 850 ""

# Clock
add_de1_widget "DSx_admin_saver" checkbutton 1480 970 {} -text [translate "Show screen saver clock"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(display_time_in_screen_saver)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command save_DSx_settings

# Histroy on saver
add_de1_widget "DSx_admin_saver" checkbutton 1480 1060 {} -text [translate "Show history icon on screen saver"] -indicatoron true  -font "[DSx_font font 8]" -bg $::DSx_settings(bg_colour) -justify left -anchor nw -foreground $::DSx_settings(font_colour) -variable ::settings(history_icon_screen_saver)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa  -relief flat -command {save_settings; restart_set;}
add_de1_variable "DSx_admin_saver" 1880 1146 -justify center -anchor center -font [DSx_font font 6] -fill $::DSx_settings(font_colour) -textvariable {requires a restart}


# scheduled power up/down
add_de1_widget "DSx_admin_saver" checkbutton 400 700 {} -text [translate "Scheduler"] -padx 0 -pady 0 -indicatoron true  -font [DSx_font font 8] -bg $::DSx_settings(bg_colour) -anchor nw -foreground $::DSx_settings(font_colour) -activeforeground #7f879a -variable ::settings(scheduler_enable)  -borderwidth 0 -selectcolor $::DSx_settings(bg_colour) -highlightthickness 0 -activebackground $::DSx_settings(bg_colour) -bd 0 -activeforeground #aaa -command DSx_scheduler_feature_hide_show_refresh -relief flat
set scheduler_widget_id1d [add_de1_widget "DSx_admin_saver" scale 400 750 {} -from 0 -to 85800 -background $::DSx_settings(bg_colour) -borderwidth 1 -bigincrement 3600 -showvalue 0 -resolution 600 -length [rescale_x_skin 800] -width [rescale_y_skin 120] -variable ::settings(scheduler_wake) -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground $::DSx_settings(font_colour) -troughcolor $::DSx_settings(bg_colour) -borderwidth 1  -highlightthickness 0 ]
set scheduler_widget_id2d [add_de1_variable "DSx_admin_saver" 400 870 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -textvariable {[translate "Heat up:"] [format_alarm_time $::settings(scheduler_wake)]}]
set scheduler_widget_id3d [add_de1_widget "DSx_admin_saver" scale 400 950 {} -from 0 -to 85800 -background $::DSx_settings(bg_colour) -borderwidth 1 -bigincrement 3600 -showvalue 0 -resolution 600 -length [rescale_x_skin 800] -width [rescale_y_skin 120] -variable ::settings(scheduler_sleep) -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -orient horizontal -foreground $::DSx_settings(font_colour) -troughcolor $::DSx_settings(bg_colour) -borderwidth 1  -highlightthickness 0 ]
set scheduler_widget_id4d [add_de1_variable "DSx_admin_saver" 400 1070 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -textvariable {[translate "Cool down:"] [format_alarm_time $::settings(scheduler_sleep)]}]
set scheduler_widget_id5d [add_de1_variable "DSx_admin_saver" 850 700 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor "nw" -width [rescale_y_skin 1000] -justify "left" -textvariable {It is [time_format [clock seconds]]}]
set ::DSx_scheduler_widgetids [list $scheduler_widget_id1d $scheduler_widget_id2d $scheduler_widget_id3d $scheduler_widget_id4d $scheduler_widget_id5d]
set_alarms_for_de1_wake_sleep

### Transport
add_de1_text "DSx_travel_prepare" 1280 120 -text [translate "Prepare your espresso machine for transport"] -font [DSx_font font 15] -fill "#a77171" -anchor "center" -width 1000
add_de1_text "DSx_travel_prepare" 1520 1000 -text [translate "After you press Ok, pull the water tank forward as shown in this photograph."] -font [DSx_font font 10] -fill "#a77171" -anchor "nw" -width 500
add_de1_text "DSx_travel_prepare" 280 1504 -text [translate "Cancel"] -font [DSx_font font 10] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_text "DSx_travel_prepare" 2300 1504 -text [translate "Ok"] -font [DSx_font font 10] -fill "$::DSx_settings(font_colour)" -anchor "center"
add_de1_button "DSx_travel_prepare" {say [translate {Cancel}] $::settings(sound_button_in);set_next_page off DSx_5_admin; page_show DSx_5_admin;} 0 1200 600 1600 ""
add_de1_button "DSx_travel_prepare" {say [translate {Ok}] $::settings(sound_button_in); set_next_page off off; start_air_purge} 1960 1200 2560 1600 ""

### Clean
add_de1_text "DSx_descale_prepare" 70 50 -text [translate "Prepare to descale"] -font [DSx_font font 20] -fill "#a77171" -anchor "nw" -width 1000
add_de1_text "DSx_descale_prepare" 1050 280 -text [translate "1) Remove the drip tray and its cover."] -font [DSx_font font 8] -fill "#a77171" -anchor "sw" -justify left -width 400
add_de1_text "DSx_descale_prepare" 1050 670 -text [translate "2) In the water tank, mix 1.5 liter hot water with 300g citric acid powder."] -font [DSx_font font 8] -fill "#a77171" -anchor "sw" -justify left -width 400
add_de1_text "DSx_descale_prepare" 1050 970 -text [translate "3) Put a blind basket in the portafilter."] -font [DSx_font font 8] -fill "#a77171" -anchor "sw" -justify left -width 400
add_de1_text "DSx_descale_prepare" 1050 1350 -text [translate "4) Push back the water tank.  Place the drip tray back without its cover."] -font [DSx_font font 8] -fill "#a77171" -anchor "sw" -justify left -width 400
add_de1_text "DSx_descale_prepare" 340 1504 -text [translate "Cancel"] -font [DSx_font font 10] -fill "#444444" -anchor "center"
add_de1_text "DSx_descale_prepare" 2233 1504 -text [translate "Descale now"] -font [DSx_font font 10] -fill "#444444" -anchor "center"
add_de1_button "DSx_descale_prepare" {say [translate {Cancel}] $::settings(sound_button_in);set_next_page off DSx_5_admin; page_show DSx_5_admin;} 0 1200 700 1600 ""
add_de1_button "DSx_descale_prepare" {say [translate {Ok}] $::settings(sound_button_in); start_decaling} 1860 1200 2560 1600 ""

###### DSx Coffee ########################################################################################
add_de1_variable "DSx_3_coffee" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {DSx coffee Setup Page}
add_de1_variable "DSx_3_coffee" 120 180 -justify left -anchor nw -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {Move-on-by-weight for profile steps\rStep names must be as shown below}
add_de1_image "DSx_3_coffee" 890 180 "[skin_directory_graphics]/icons/button4.png"
add_de1_variable "DSx_3_coffee" 1000 210 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {clear}
add_de1_variable "DSx_3_coffee" 1000 260 -justify center -anchor center -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -textvariable {all}
add_de1_button "DSx_3_coffee" {say [translate {clear}] $::settings(sound_button_in); DSx_moveon_clear} 890 180 1110 320
add_de1_image "DSx_3_coffee" 1130 180 "[skin_directory_graphics]/icons/button4.png"
add_de1_variable "DSx_3_coffee" 1240 210 -justify center -anchor center -font [DSx_font font 6] -fill $::DSx_settings(font_colour) -textvariable {set buttons}
add_de1_variable "DSx_3_coffee" 1240 260 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_tap_multiplier}
add_de1_button "DSx_3_coffee" {say [translate {multiplier}] $::settings(sound_button_in); DSx_tap_multiplier} 1130 180 1350 320
add_de1_variable "DSx_3_coffee" 650 380 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {flow}
add_de1_variable "DSx_3_coffee" 1130 380 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {mass}
add_de1_variable "DSx_3_coffee" 360 510 -justify center -anchor e -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_saturating}
add_de1_image "DSx_3_coffee" 400 410 "[skin_directory_graphics]/icons/click1.png"
add_de1_image "DSx_3_coffee" 880 410 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_3_coffee" 650 510 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_saturating_weight_rate]}
add_de1_variable "DSx_3_coffee" 1130 510 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_saturating_weight]}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(saturating_weight_rate) 0 5 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 400 410 870 610 ""
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(saturating_weight) 0 50 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 880 410 1350 610 ""
add_de1_variable "DSx_3_coffee" 360 720 -justify center -anchor e -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_pressurising}
add_de1_image "DSx_3_coffee" 400 620 "[skin_directory_graphics]/icons/click1.png"
add_de1_image "DSx_3_coffee" 880 620 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_3_coffee" 650 720 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_pressurising_weight_rate]}
add_de1_variable "DSx_3_coffee" 1130 720 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_pressurising_weight]}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(pressurising_weight_rate) 0 5 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 400 620 870 820 ""
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(pressurising_weight) 0 50 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 880 620 1350 820 ""
add_de1_variable "DSx_3_coffee" 360 930 -justify center -anchor e -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::DSx_step_extracting}
add_de1_image "DSx_3_coffee" 400 830 "[skin_directory_graphics]/icons/click1.png"
add_de1_image "DSx_3_coffee" 880 830 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_3_coffee" 650 930 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_extracting_weight_rate]}
add_de1_variable "DSx_3_coffee" 1130 930 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {[DSx_extracting_weight]}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(extracting_weight_rate) 0 5 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 400 830 870 1030 ""
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker_fast_tap 1 0.1 ::DSx_settings(extracting_weight) 0 50 %x %y %x0 %y0 %x1 %y1; DSx_update_saw; clear_saw_font;} 880 830 1350 1030 ""
add_de1_variable "DSx_3_coffee" 1950 220 -text "" -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -justify "center" -width [rescale_x_skin 510] -textvariable {$::settings(profile_title)}
add_de1_button "DSx_3_coffee" {say [translate {}] $::settings(sound_button_in); set ::DSx_coffee_to_settings_1 1; show_settings; after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off settings_1; page_show off; set ::settings(active_settings_tab) settings_1; set_profiles_scrollbar_dimensions} 1710 140 2210 300
add_de1_variable "DSx_3_coffee" 1880 650 -text "" -font [DSx_font font 8] -fill #ccc -anchor "nw" -justify left -textvariable {$::DSx_steps_output}
add_de1_variable "DSx_3_coffee" 2120 380 -justify center -anchor center -font [DSx_font font 9] -fill $::DSx_settings(font_colour) -textvariable {Temperature shift}
add_de1_image "DSx_3_coffee" 1880 410 "[skin_directory_graphics]/icons/click1.png"
add_de1_variable "DSx_3_coffee" 2130 510 -justify center -anchor center -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {$::Dsx_temperature_shift_amount[DSx_temp_steps]}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); horizontal_clicker 0.5 0.5 ::DSx_settings(temperature_adjustment) -1 1 %x %y %x0 %y0 %x1 %y1; DSx_coffee_temperature_adjust;} 1880 410 2350 610 ""
add_de1_variable "DSx_3_coffee" 875 1130 -justify center -anchor n -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -textvariable {DSx coffee templates}
add_de1_image "DSx_3_coffee" 530 1210 "[skin_directory_graphics]/icons/button4.png"
add_de1_variable "DSx_3_coffee" 635 1280 -justify center -anchor center -font [DSx_font font 9] -fill $::DSx_settings(font_colour) -textvariable {Fruity}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); load_DSx_coffee_fruity; DSx_update_saw; clear_saw_font;} 530 1210 750 1350 ""
add_de1_image "DSx_3_coffee" 780 1210 "[skin_directory_graphics]/icons/button4.png"
add_de1_variable "DSx_3_coffee" 885 1280 -justify center -anchor center -font [DSx_font font 9] -fill $::DSx_settings(font_colour) -textvariable {Smooth}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); load_DSx_coffee_smooth; DSx_update_saw; clear_saw_font;} 780 1210 1000 1350 ""
add_de1_image "DSx_3_coffee" 1030 1210 "[skin_directory_graphics]/icons/button4.png"
add_de1_variable "DSx_3_coffee" 1135 1280 -justify center -anchor center -font [DSx_font font 9] -fill $::DSx_settings(font_colour) -textvariable {Mocha}
add_de1_button "DSx_3_coffee" {say "" $::settings(sound_button_in); load_DSx_coffee_mocha; DSx_update_saw; clear_saw_font;} 1030 1210 1250 1350 ""
add_de1_variable "settings_2c" 1280 730 -text [translate ""] -font [DSx_font font 16] -fill $::DSx_settings(red) -justify "center" -anchor "n" -textvariable {[donotedit]}

rename ::save_profile ::skin::dsx::save_profile_orig
msg -INFO "DSx: rename ::save_profile ::skin::dsx::save_profile_orig"

proc ::save_profile {args} {

	no_save_DSx_coffee
	::skin::dsx::save_profile_orig {*}$args
}

###########################################################################################################################################

proc back_to_previous_page {} {
    if {$::DSx_workflow_to_settings_1 == 1} {
            set_next_page off DSx_4_workflow; page_show DSx_4_workflow; set ::DSx_workflow_to_settings_1 0;
        } elseif {$::DSx_coffee_to_settings_1 == 1} {
            set_next_page off DSx_3_coffee; page_show DSx_3_coffee; set ::DSx_coffee_to_settings_1 0; set ::Dsx_temperature_shift_amount 0;
        } else {
            set_next_page off off; page_show off; set ::DSx_coffee_to_settings_1 0;
        }

}


proc DSx_add_to_profile_settings_ok_button_enter {} {
    LRv2_preview
    DSx_graph_restore
    refresh_DSx_temperature
    if {[array_item_difference ::settings ::settings_backup "steam_temperature"] == 1 && $::settings(steam_temperature) > 130} {
        set ::DSx_settings(steam_temperature_backup) $::settings(steam_temperature);
    }
    if {[array_item_difference ::settings ::settings_backup "enable_fahrenheit language skin waterlevel_indicator_on waterlevel_indicator_blink display_rate_espresso display_espresso_water_delta_number display_group_head_delta_number display_pressure_delta_line display_flow_delta_line display_weight_delta_line allow_unheated_water"] == 1 } {
        set ::DSx_workflow_to_settings_1 0;
    }
}

proc DSx_add_to_profile_settings_ok_button_leave {} {
    back_to_previous_page
    DSx_graph_restore
    clear_profile_font
    off_cup
    saw_switch
}

add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" {save_settings_to_de1; set_alarms_for_de1_wake_sleep; say [translate {save}] $::settings(sound_button_in); save_settings; profile_has_changed_set_colors;
        DSx_add_to_profile_settings_ok_button_enter
        if {[ifexists ::profiles_hide_mode] == 1} {
            unset -nocomplain ::profiles_hide_mode
            fill_profiles_listbox
        }
        if {[ifexists ::settings_backup(calibration_flow_multiplier)] != [ifexists ::settings(calibration_flow_multiplier)]} {
            set_calibration_flow_multiplier $::settings(calibration_flow_multiplier)
        }
        if {[ifexists ::settings_backup(fan_threshold)] != [ifexists ::settings(fan_threshold)]} {
            set_fan_temperature_threshold $::settings(fan_threshold)
        }
        if {[ifexists ::settings_backup(water_refill_point)] != [ifexists ::settings(water_refill_point)]} {
            de1_send_waterlevel_settings
        }
        if {[array_item_difference ::settings ::settings_backup "steam_temperature steam_flow"] == 1} {
            # resend the calibration settings if they were changed
            de1_send_steam_hotwater_settings
            de1_enable_water_level_notifications
        }
        if {[array_item_difference ::settings ::settings_backup "enable_fahrenheit orientation screen_size_width saver_brightness use_finger_down_for_tap log_enabled hot_water_idle_temp espresso_warmup_timeout language skin waterlevel_indicator_on default_font_calibration waterlevel_indicator_blink display_rate_espresso display_espresso_water_delta_number display_group_head_delta_number display_pressure_delta_line display_flow_delta_line display_weight_delta_line allow_unheated_water display_time_in_screen_saver enabled_plugins plugin_tabs"] == 1  || [ifexists ::app_has_updated] == 1} {
            # changes that effect the skin require an app restart
            .can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
            .can itemconfigure $::message_button_label -text [translate "Wait"]

            set_next_page off message; page_show message
            after 200 app_exit

        } elseif {[ifexists ::settings_backup(scale_bluetooth_address)] == "" && [ifexists ::settings(scale_bluetooth_address)] != ""} {
            # if no scale was previously defined, and there is one now, then force an app restart
            # but if there was a scale previously, and now there is a new one, let that be w/o an app restart

            # changes that effect the skin require an app restart
            .can itemconfigure $::message_label -text [translate "Please quit and restart this app to apply your changes."]
            .can itemconfigure $::message_button_label -text [translate "Wait"]

            set_next_page off message; page_show message
            after 200 app_exit

        } else {

            if {[ifexists ::settings(settings_profile_type)] == "settings_2c2"} {
                # if they were on the LIMITS tab of the Advanced profiles, reset the ui back to the main tab
                set ::settings(settings_profile_type) "settings_2c"
            }

            #set_next_page off off; page_show off
            DSx_add_to_profile_settings_ok_button_leave
        }
    } 2016 1430 2560 1600

add_de1_button "settings_1 settings_2 settings_2a settings_2b settings_2c settings_2czoom settings_2c2 settings_3 settings_4" {if {[ifexists ::profiles_hide_mode] == 1} { unset -nocomplain ::profiles_hide_mode; fill_profiles_listbox }; array unset ::settings {\*}; array set ::settings [array get ::settings_backup]; update_de1_explanation_chart; fill_skin_listbox; profile_has_changed_set_colors; say [translate {Cancel}] $::settings(sound_button_in); back_to_previous_page; fill_advanced_profile_steps_listbox; restore_espresso_chart; LRv2_preview; DSx_graph_restore; save_settings_to_de1; fill_profiles_listbox; refresh_DSx_temperature; fill_extensions_listbox} 1505 1430 2015 1600

add_de1_widget "settings_1" graph 1330 300 {
    set ::DSx_preview_graph_advanced $widget
    update_de1_explanation_chart;
    LRv2_preview;
    $::DSx_preview_graph_advanced element create DSx_preview_line_espresso_flow_2x  -xdata DSx_espresso_elapsed_preview -ydata DSx_espresso_flow_preview_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #4e85f4 -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $::DSx_preview_graph_advanced element create DSx_preview_line_espresso_flow_weight_2x  -xdata DSx_espresso_elapsed_preview -ydata DSx_espresso_flow_weight_preview_2x -symbol none -label "" -linewidth [rescale_x_skin 8] -color #a2693d -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $::DSx_preview_graph_advanced element create DSx_preview_line2_espresso_pressure -xdata DSx_espresso_elapsed_preview -ydata DSx_espresso_pressure_preview -symbol none -label "" -linewidth [rescale_x_skin 8] -color #008c4c  -smooth $::settings(live_graph_smoothing_technique) -pixels 0;
    $::DSx_preview_graph_advanced axis configure x -color #5a5d75 -tickfont [DSx_font font 6] ;
    $::DSx_preview_graph_advanced axis configure y -color #5a5d75 -tickfont [DSx_font font 6] -min 0.0 -max 14 -stepsize 2 -majorticks {0 2 4 6 8 10 12 14} -title [translate "pressure"] -titlefont [DSx_font font 8] -titlecolor #5a5d75;
    $::DSx_preview_graph_advanced axis configure y2 -color #5a5d75 -tickfont [DSx_font font 6] -min 0.0 -max 7 -stepsize 2 -majorticks {0 1 2 3 4 5 6 7} -title [translate "flow"] -titlefont [DSx_font font 8] -titlecolor #5a5d75  -hide 0;
    bind $::DSx_preview_graph_advanced [platform_button_press] { after 500 update_de1_explanation_chart; say [translate {settings}] $::settings(sound_button_in); set_next_page off $::settings(settings_profile_type); page_show off; set ::settings(active_settings_tab) $::settings(settings_profile_type); fill_advanced_profile_steps_listbox }
} -plotbackground #F8F8F8 -width [rescale_x_skin 1050] -height [rescale_y_skin 450] -borderwidth 1 -background #FFFFFF -plotrelief raised

add_de1_variable "settings_1" 1560 230 -text [translate "Load a preset"] -font [DSx_font font 10] -fill "#7f879a" -justify "left" -anchor "nw" -textvariable {[LRv2_preview_text]}

###########################################################################################################################################


proc skins_page_change_due_to_de1_state_change { textstate } {
	page_change_due_to_de1_state_change $textstate

    if {$textstate == "Idle"} {
	    set ::DSx_timer_start 0
        set ::flush_counting 0
        set ::flush_run 0
        set ::DSx_steam_purge_state 0
        set ::DSx_steam_state_text "Steaming"
	} elseif {$textstate == "Steam"} {
		set ::DSx_steam_timing_text 1111
		set_next_page off off;
	} elseif {$textstate == "Espresso"} {
		set_next_page off off;

	} elseif {$textstate == "HotWater"} {
		set_next_page off off; 
	} elseif {$textstate == "HotWaterRinse"} {
		set_next_page off off;
        set ::DSx_timer_reset 1
        set ::DSx_flush_time2 0
        set ::flush_run 1
        DSx_loop
	}
}

### DSx Plugin UI###

add_de1_variable "DSx_plugin_UI" 1280 60 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {DSx Plugin UI page}
add_de1_variable "DSx_plugin_UI" 400 260 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Active plugins}

add_de1_widget "DSx_plugin_UI" listbox 40 330 {
	set ::globals(DSx_active_plugin_widget) $widget
	fill_DSx_active_plugin_listbox
	bind $widget <<ListboxSelect>> DSx_active_plugin_rename;
} -background $::DSx_settings(bg_colour) -yscrollcommand {scale_scroll ::DSx_active_plugin_slider} -font [DSx_font font 8] -bd 0 -height 14 -width 28 -foreground $::DSx_settings(font_colour) -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground $::DSx_settings(font_colour)

set ::DSx_active_plugin_slider 0
set ::DSx_active_plugin_scrollbar [add_de1_widget "DSx_plugin_UI" scale 644 330 {} -from 0 -to .50 -bigincrement 0.2 -background $::DSx_settings(font_colour) -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 800] -width [rescale_y_skin 120] -variable plugin_left -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(DSx_active_plugin_widget) $::DSx_active_plugin_slider}  -foreground #FFFFFF -troughcolor $::DSx_settings(bg_colour) -borderwidth 0  -highlightthickness 0]

add_de1_widget "DSx_plugin_UI" listbox 800 330 {
	set ::globals(DSx_inactive_plugin_widget) $widget
	fill_DSx_inactive_plugin_listbox
	bind $widget <<ListboxSelect>> DSx_inactive_plugin_rename;
} -background $::DSx_settings(bg_colour) -yscrollcommand {scale_scroll ::DSx_inactive_plugin_slider} -font [DSx_font font 8] -bd 0 -height 14 -width 28 -foreground $::DSx_settings(font_colour) -borderwidth 0 -selectborderwidth 0  -relief flat -highlightthickness 0 -selectmode single  -selectbackground $::DSx_settings(font_colour)

set ::DSx_inactive_plugin_slider 0
set ::DSx_inactive_plugin_scrollbar [add_de1_widget "DSx_plugin_UI" scale 1404 330 {} -from 0 -to .50 -bigincrement 0.2 -background $::DSx_settings(font_colour) -borderwidth 1 -showvalue 0 -resolution .01 -length [rescale_x_skin 800] -width [rescale_y_skin 120] -variable plugin_right -font [DSx_font font 10] -sliderlength [rescale_x_skin 125] -relief flat -command {listbox_moveto $::globals(DSx_inactive_plugin_widget) $::DSx_inactive_plugin_slider}  -foreground #FFFFFF -troughcolor $::DSx_settings(bg_colour) -borderwidth 0  -highlightthickness 0]

add_de1_variable "DSx_plugin_UI" 1160 260 -font [DSx_font font 10] -fill $::DSx_settings(font_colour) -anchor "center" -textvariable {Plugins}
add_de1_variable "DSx_plugin_UI" 1200 1320 -text "" -font [DSx_font font 8] -fill #ff574a -anchor center -justify center -textvariable {$::DSx_plugin_message}
add_de1_variable "DSx_plugin_UI" 2000 300 -text "" -font [DSx_font font 8] -fill $::DSx_settings(font_colour) -anchor center -justify center -textvariable {You can select a page to show when you tap\rthe left 1/2 of screen saver without waking\rthe machine. Allowing you to use plugins\rwhile the machine is sleeping}
add_de1_variable "DSx_plugin_UI" 2000 700 -text "" -font [DSx_font font 7] -fill $::DSx_settings(font_colour) -anchor center -justify center -textvariable {If you have activated/deactivated plugins on the left,\rthe list may not be current, please restart to update}
add_de1_image "DSx_plugin_UI" 1810 430 "[skin_directory_graphics]/icons/button8.png"
add_de1_variable "DSx_plugin_UI" 2000 530 -text "" -font [DSx_font font 8] -fill $::DSx_settings(orange) -anchor center -justify center -textvariable {$::DSx_settings(first_page_from_saver)}
add_de1_button "DSx_plugin_UI" {toggle_active_plugin_list} 1800 430 2200 630
fill_DSx_active_plugin_listbox

DSx_final_prep

if {$::settings(history_icon_screen_saver) == 1} {
    add_de1_image "saver" 20 20 "[skin_directory_graphics]/icons/history.png"
    add_de1_button "saver" {say [translate {}] $::settings(sound_button_in); history_prep;}  0 0 230 230
}
proc hide_android_keyboard {} {
	# make sure on-screen keyboard doesn't auto-pop up
	sdltk textinput off
	focus .can
}
