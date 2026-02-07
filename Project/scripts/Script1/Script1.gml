gml_release_mode(false);
#macro vMAJOR 0
#macro vMINOR 1
#macro vPATCH 0
#macro vBUILD 2
#macro vTAG "dev"
#macro VERSION string(vMAJOR)+"."+string(vMINOR)+"."+string(vPATCH) + (vTAG != "GOLD" ? "-" + vTAG + (vBUILD > 0 ? "." + string(vBUILD) : "") : "")
#macro nVERSION (vMAJOR*100000000 + vMINOR*1000000 + vPATCH*1000 + vBUILD)

#macro LOREM "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam et elementum risus. Etiam condimentum ligula eget purus euismod molestie. Etiam varius, orci dictum bibendum volutpat, lorem nunc congue sapien, eget rutrum arcu urna at dolor. Nam ornare dignissim arcu, quis accumsan dui. Duis rutrum non mi non pellentesque. Donec pharetra augue ante, eget semper tortor varius eu. Nullam quis rhoncus nisl. Curabitur in commodo odio, in laoreet sem."
#macro null undefined
#macro	c_random make_color_rgb(irandom(255),irandom(255),irandom(255))
#macro c_cornflowerblue #6495ed

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);
gpu_set_cullmode(cull_noculling);
gpu_set_texfilter(false);
gpu_set_texrepeat(true);