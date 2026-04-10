vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_color();
global.VFormat = vertex_format_end();

function VertexAdd(_vb, _x, _y, _z, _nx, _ny, _nz, _u, _v, _c, _a) {
    vertex_position_3d(_vb, _x, _y, _z);
    vertex_normal(_vb, _nx, _ny, _nz);
    vertex_texcoord(_vb, _u, _v);
    vertex_colour(_vb, _c, _a);
}