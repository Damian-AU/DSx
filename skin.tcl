############# comment de1_skin_settings.tcl lines 130 & 140 to show SAW settings

#### Skin by Damian Brakel ####

set ::skindebug 0
package require de1plus 1.0
package ifneeded DSx_skin 1.0 [list source [file join "./skins/DSx/DSx_Code_Files/" DSx_skin.tcl]]
package require DSx_skin 1.0
