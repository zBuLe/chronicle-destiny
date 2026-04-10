draw_set_color(c_dkgrey);
draw_rectangle(0,0,SCREEN.width,SCREEN.height,false);
draw_set_color(c_ltgrey);
draw_rectangle(x1,y1,x2,y2,false);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

draw_set_font(fnt_default);
draw_set_color(c_black);
draw_text(lx,ly,label);

draw_set_color(c_blue);
draw_text(lx,ly,link);
