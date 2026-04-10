draw_set_color(c_black);
draw_rectangle(0,0,SCREEN.width,SCREEN.height,false);
draw_set_color(c_blue);
draw_set_font(fnt_title)
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(SCREEN.topleft.x + 25, SCREEN.topleft.y + 25, "Chronicle Destiny");

//draw_set_color(c_blue);
//draw_rectangle(250,250,300,300,false);
//draw_set_font(fnt_menu)
//draw_set_halign(fa_left);
//draw_set_valign(fa_top);
//draw_set_color(c_aliceblue);
//draw_text(275,275,"Start");
var xx=mx;
var yy=my;

for (var i = 0; i < array_length(title_menu[0]); ++i) {
	var c_color=index==i?c_cornflower:c_blue;
	var width=index==i?200:150;
	draw_set_color(c_color);
	draw_rectangle(xx,yy,xx-width,yy+size,false);
	draw_set_font(fnt_menu)
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	c_color=index==i?c_white:c_aqua;
	draw_set_color(c_color);
	draw_text(xx-5,yy+(size/2),title_menu[0][i]);
	yy+=50
}
