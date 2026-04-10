/// Tmap — Tilemap mesh manager (singleton)
///
/// Auto-discovers all tilemap layers in the current room and converts
/// them to frozen vertex buffers for 3D rendering.
///
/// Setup:
///   #macro TMAP global.__tmap
///   TMAP = new Tmap();
///
/// Room Start event:
///   TMAP.Init();
///
/// Draw event:
///   TMAP.Draw();
///
/// Clean Up / Room End event:
///   TMAP.Destroy();


function Tmap() constructor {
    Layers = [];    // array of TmapLayer structs

    // ── Init ───────────────────────────────────────────────────
    /// @func Init()
    /// @desc Scans the current room for all tilemap layers and builds
    ///       a vertex buffer for each. Call on Room Start.
    static Init = function() {
        Destroy();  // clean up any previous room's data

        var _all_layers = layer_get_all();
        var _i = 0;
        repeat (array_length(_all_layers)) {
            var _layer_id = _all_layers[_i++];
            var _elements = layer_get_all_elements(_layer_id);

            if (array_length(_elements) == 0) continue;

            var _type = layer_get_element_type(_elements[0]);
            if (_type != layerelementtype_tilemap) continue;

            var _tilemap = layer_tilemap_get_id(_layer_id);
            if (_tilemap == -1) continue;

            var _entry = new TmapLayer(_layer_id, _tilemap);
            array_push(Layers, _entry);
        }
    };

    // ── Draw ───────────────────────────────────────────────────
    /// @func Draw()
    /// @desc Submits all visible tilemap meshes. Z-buffer handles
    ///       depth ordering since each layer sits at its own Z.
    static Draw = function() {
        var _i = 0;
        repeat (array_length(Layers)) {
            var _layer = Layers[_i++];
            if (_layer.Visible) {
                _layer.Draw();
            }
        }
    };

    // ── Visibility ─────────────────────────────────────────────
    /// @func SetVisible(_name, _visible)
    /// @desc Toggle a specific tilemap layer by name.
    /// @param {String} _name      Layer name (e.g. "Tiles_Roof")
    /// @param {Bool}   _visible   Show or hide
    static SetVisible = function(_name, _visible) {
        var _i = 0;
        repeat (array_length(Layers)) {
            if (Layers[_i].Name == _name) {
                Layers[_i].Visible = _visible;
                return;
            }
            _i++;
        }
    };

    /// @func GetLayer(_name)
    /// @desc Returns the TmapLayer struct for a given layer name,
    ///       or undefined if not found.
    static GetLayer = function(_name) {
        var _i = 0;
        repeat (array_length(Layers)) {
            if (Layers[_i].Name == _name) return Layers[_i];
            _i++;
        }
        return undefined;
    };

    // ── Cleanup ────────────────────────────────────────────────
    /// @func Destroy()
    /// @desc Frees all vertex buffers. Call on Room End / Clean Up.
    static Destroy = function() {
        var _i = 0;
        repeat (array_length(Layers)) {
            Layers[_i++].Destroy();
        }
        Layers = [];
    };
}


/// @func TmapLayer(_layer_id, _tilemap_id)
/// @desc A single tilemap layer converted to a 3D mesh.
///       Created internally by Tmap.Init().

function TmapLayer(_layer_id, _tilemap_id) constructor {
    LayerID = _layer_id;
    Name    = layer_get_name(_layer_id);
    Depth   = layer_get_depth(_layer_id);
    Visible = layer_get_visible(_layer_id);
    VBuffer = undefined;
    Texture = undefined;

    // tileset info
    var _tileset = tilemap_get_tileset(_tilemap_id);
    var _ts_info = tileset_get_info(_tileset);

    TileW   = _ts_info.tile_width;
    TileH   = _ts_info.tile_height;
    Columns = _ts_info.tile_columns;
    MapW    = tilemap_get_width(_tilemap_id);
    MapH    = tilemap_get_height(_tilemap_id);
    Texture = tileset_get_texture(_tileset);

    // texel math (computed once, used during Build)
    var _tex     = Texture;
    var _uvs     = tileset_get_uvs(_tileset);
    UVOriginX    = _uvs[0];
    UVOriginY    = _uvs[1];
    TileUVW      = texture_get_texel_width(_tex)  * TileW
                 + (2 * _ts_info.tile_horizontal_separator) * texture_get_texel_width(_tex);
    TileUVH      = texture_get_texel_height(_tex) * TileH
                 + (2 * _ts_info.tile_vertical_separator)   * texture_get_texel_height(_tex);

    // build immediately
    Build(_tilemap_id);

    // ── Build ──────────────────────────────────────────────────
    /// @func Build(_tilemap_id)
    /// @desc Constructs the vertex buffer from tilemap data.
    ///       Handles tile mirror, flip, and rotate transforms.
    static Build = function(_tilemap_id) {
        if (VBuffer != undefined) {
            vertex_delete_buffer(VBuffer);
        }

        var _z   = Depth;
        var _tw  = TileW;
        var _th  = TileH;
        var _col = Columns;
        var _uvw = TileUVW;
        var _uvh = TileUVH;
        var _uox = UVOriginX;
        var _uoy = UVOriginY;

        VBuffer = vertex_create_buffer();
        vertex_begin(VBuffer, global.VFormat);

        for (var _i = 0; _i < MapW; _i++) {
            for (var _j = 0; _j < MapH; _j++) {
                var _data  = tilemap_get(_tilemap_id, _i, _j);
                var _index = tile_get_index(_data);
                if (_index == 0) continue;

                var _ix = _index mod _col;
                var _iy = _index div _col;

                // base UV rect
                var _u0 = _uox + _uvw * _ix;
                var _v0 = _uoy + _uvh * _iy;
                var _u1 = _u0 + _uvw;
                var _v1 = _v0 + _uvh;

                // per-corner UVs: TL, TR, BR, BL
                var _cu0 = _u0, _cv0 = _v0;  // TL
                var _cu1 = _u1, _cv1 = _v0;  // TR
                var _cu2 = _u1, _cv2 = _v1;  // BR
                var _cu3 = _u0, _cv3 = _v1;  // BL

                // mirror (horizontal flip — swap left/right columns)
                if (tile_get_mirror(_data)) {
                    var _t;
                    _t = _cu0; _cu0 = _cu1; _cu1 = _t;  _t = _cv0; _cv0 = _cv1; _cv1 = _t;
                    _t = _cu2; _cu2 = _cu3; _cu3 = _t;  _t = _cv2; _cv2 = _cv3; _cv3 = _t;
                }

                // flip (vertical flip — swap top/bottom rows)
                if (tile_get_flip(_data)) {
                    var _t;
                    _t = _cu0; _cu0 = _cu3; _cu3 = _t;  _t = _cv0; _cv0 = _cv3; _cv3 = _t;
                    _t = _cu1; _cu1 = _cu2; _cu2 = _t;  _t = _cv1; _cv1 = _cv2; _cv2 = _t;
                }

                // rotate (90° clockwise — cycle corners: TL←BL←BR←TR←TL)
                if (tile_get_rotate(_data)) {
                    var _t0 = _cu0, _t1 = _cv0;
                    _cu0 = _cu3; _cv0 = _cv3;
                    _cu3 = _cu2; _cv3 = _cv2;
                    _cu2 = _cu1; _cv2 = _cv1;
                    _cu1 = _t0;  _cv1 = _t1;
                }

                // quad corners
                var _x0 = _tw * _i;
                var _y0 = _th * _j;
                var _x1 = _x0 + _tw;
                var _y1 = _y0 + _th;

                // tri 1: TL, TR, BR
                VertexAdd(VBuffer, _x0, _y0, _z,  0, 0, -1,  _cu0, _cv0,  c_white, 1);
                VertexAdd(VBuffer, _x1, _y0, _z,  0, 0, -1,  _cu1, _cv1,  c_white, 1);
                VertexAdd(VBuffer, _x1, _y1, _z,  0, 0, -1,  _cu2, _cv2,  c_white, 1);
                // tri 2: BR, BL, TL
                VertexAdd(VBuffer, _x1, _y1, _z,  0, 0, -1,  _cu2, _cv2,  c_white, 1);
                VertexAdd(VBuffer, _x0, _y1, _z,  0, 0, -1,  _cu3, _cv3,  c_white, 1);
                VertexAdd(VBuffer, _x0, _y0, _z,  0, 0, -1,  _cu0, _cv0,  c_white, 1);
            }
        }

        vertex_end(VBuffer);
        vertex_freeze(VBuffer);

        // hide the GM tilemap layer — we're rendering it ourselves now
        layer_set_visible(LayerID, false);
    };

    // ── Draw ───────────────────────────────────────────────────
    static Draw = function() {
        vertex_submit(VBuffer, pr_trianglelist, Texture);
    };

    // ── Cleanup ────────────────────────────────────────────────
    static Destroy = function() {
        if (VBuffer != undefined) {
            vertex_delete_buffer(VBuffer);
            VBuffer = undefined;
        }
    };

    // ── Utility ────────────────────────────────────────────────
    static TileToWorld = function(_tx, _ty) {
        return new Vector3(
            _tx * TileW + TileW * 0.5,
            _ty * TileH + TileH * 0.5,
            Depth
        );
    };

    static WorldToTile = function(_wx, _wy) {
        return new Vector3(floor(_wx / TileW), floor(_wy / TileH), 0);
    };
}
