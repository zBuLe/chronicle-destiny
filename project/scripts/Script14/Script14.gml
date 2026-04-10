function Interval(_min, _max) constructor {
    Min = _min;
    Max = _max;
}

function SATOverlap(_shape1, _shape2, _axis) {
    var _a = _shape1.GetInterval(_axis);
    var _b = _shape2.GetInterval(_axis);
    return (_b.Min <= _a.Max) && (_a.Min <= _b.Max);
}
function RayHitInfo() constructor {
    Shape    = undefined;
    Point    = undefined;
    Distance = infinity;
    Normal   = undefined;

    static Update = function(_dist, _shape, _point, _normal) {
        if (_dist < Distance) {
            Distance = _dist;
            Shape    = _shape;
            Point    = _point;
            Normal   = _normal;
        }
    };

    static Clear = function() {
        Shape    = undefined;
        Point    = undefined;
        Distance = infinity;
        Normal   = undefined;
    };
}

function ColAABB(_position, _half_extents) constructor {
    Position = undefined;
    HalfExtents = undefined;
    // cached derived properties
    PropMin = new Vector3();
    PropMax = new Vector3();
    PropRadius = 0;

    static Set = function(_pos = Position, _half = HalfExtents) {
        Position = _pos;
        HalfExtents = _half;
        // cache bounds — avoids allocating on every GetMin/GetMax call
        PropMin.Set(_pos.X - _half.X, _pos.Y - _half.Y, _pos.Z - _half.Z);
        PropMax.Set(_pos.X + _half.X, _pos.Y + _half.Y, _pos.Z + _half.Z);
        PropRadius = _half.Length();
        return self;
    };
    Set(_position, _half_extents);

    static CheckCollider = function(_collider) {
        return _collider.Shape.CheckAABB(self);
    };

    static CheckAABB = function(_other) {
        return PropMin.X <= _other.PropMax.X
            && PropMax.X >= _other.PropMin.X
            && PropMin.Y <= _other.PropMax.Y
            && PropMax.Y >= _other.PropMin.Y
            && PropMin.Z <= _other.PropMax.Z
            && PropMax.Z >= _other.PropMin.Z;
    };

    static CheckSphere = function(_sphere) {
        return _sphere.CheckAABB(self);
    };

    static CheckPlane = function(_plane) {
        var _n = _plane.Normal;
        var _h = HalfExtents;
        var _plen = abs(_n.X) * _h.X + abs(_n.Y) * _h.Y + abs(_n.Z) * _h.Z;
        var _dist = _n.Dot(Position) - _plane.Distance;
        return abs(_dist) <= _plen;
    };

    static CheckRay = function(_ray, _hit_info, _max_t = infinity) {
        var _min = PropMin, _max = PropMax;
        var _ox = _ray.Origin.X, _oy = _ray.Origin.Y, _oz = _ray.Origin.Z;
        var _dx = _ray.Direction.X, _dy = _ray.Direction.Y, _dz = _ray.Direction.Z;

        // avoid division by zero
        if (_dx == 0) _dx = 0.0001;
        if (_dy == 0) _dy = 0.0001;
        if (_dz == 0) _dz = 0.0001;

        var _t1 = (_min.X - _ox) / _dx;
        var _t2 = (_max.X - _ox) / _dx;
        var _t3 = (_min.Y - _oy) / _dy;
        var _t4 = (_max.Y - _oy) / _dy;
        var _t5 = (_min.Z - _oz) / _dz;
        var _t6 = (_max.Z - _oz) / _dz;

        var _tmin = max(min(_t1, _t2), min(_t3, _t4), min(_t5, _t6));
        var _tmax = min(max(_t1, _t2), max(_t3, _t4), max(_t5, _t6));

        if (_tmax < 0 || _tmin > _tmax) return false;

        var _t = (_tmin > 0) ? _tmin : _tmax;
        if (_t > _max_t) return false;

        var _contact = _ray.Origin.Add(_ray.Direction.Scale(_t));

        // determine hit normal from which slab was entered
        var _normal = new Vector3(0, 0, 0);
        if (_t == _t1) _normal.X = -1;
        else if (_t == _t2) _normal.X = 1;
        else if (_t == _t3) _normal.Y = -1;
        else if (_t == _t4) _normal.Y = 1;
        else if (_t == _t5) _normal.Z = -1;
        else if (_t == _t6) _normal.Z = 1;

        _hit_info.Update(_t, self, _contact, _normal);
        return true;
    };

    static NearestPoint = function(_v) {
        return new Vector3(
            clamp(_v.X, PropMin.X, PropMax.X),
            clamp(_v.Y, PropMin.Y, PropMax.Y),
            clamp(_v.Z, PropMin.Z, PropMax.Z)
        );
    };

    static DisplaceSphere = function(_sphere) {
        if (!CheckSphere(_sphere)) return undefined;
        var _nearest = NearestPoint(_sphere.Position);
        var _diff = _sphere.Position.Sub(_nearest);
        var _dist = _diff.Length();
        if (_dist == 0) {
            // sphere center is inside AABB — push out along shortest axis
            var _dx = PropMax.X - _sphere.Position.X;
            var _dy = PropMax.Y - _sphere.Position.Y;
            var _dz = PropMax.Z - _sphere.Position.Z;
            var _dxn = _sphere.Position.X - PropMin.X;
            var _dyn = _sphere.Position.Y - PropMin.Y;
            var _dzn = _sphere.Position.Z - PropMin.Z;
            var _min_dist = min(_dx, _dy, _dz, _dxn, _dyn, _dzn);
            var _push = new Vector3(0, 0, 0);
            if (_min_dist == _dxn) _push.X = -1;
            else if (_min_dist == _dx) _push.X = 1;
            else if (_min_dist == _dyn) _push.Y = -1;
            else if (_min_dist == _dy) _push.Y = 1;
            else if (_min_dist == _dzn) _push.Z = -1;
            else _push.Z = 1;
            return _nearest.Add(_push.Scale(_sphere.Radius));
        }
        var _normal = _diff.Scale(1 / _dist);
        return _nearest.Add(_normal.Scale(_sphere.Radius));
    };

    static GetMin = function() { return PropMin; };
    static GetMax = function() { return PropMax; };

    static GetInterval = function(_axis) {
        var _verts = GetVertices();
        var _imin = _axis.Dot(_verts[0]);
        var _imax = _imin;
        for (var _i = 1; _i < 8; _i++) {
            var _d = _axis.Dot(_verts[_i]);
            _imin = min(_imin, _d);
            _imax = max(_imax, _d);
        }
        return new Interval(_imin, _imax);
    };

    static GetVertices = function() {
        var _mn = PropMin, _mx = PropMax;
        return [
            new Vector3(_mn.X, _mx.Y, _mx.Z),
            new Vector3(_mn.X, _mx.Y, _mn.Z),
            new Vector3(_mn.X, _mn.Y, _mx.Z),
            new Vector3(_mn.X, _mn.Y, _mn.Z),
            new Vector3(_mx.X, _mx.Y, _mx.Z),
            new Vector3(_mx.X, _mx.Y, _mn.Z),
            new Vector3(_mx.X, _mn.Y, _mx.Z),
            new Vector3(_mx.X, _mn.Y, _mn.Z),
        ];
    };

    static DebugDraw = function(_col = c_white) {
        // line list wireframe — reuse your existing dbug_draw pattern
        // but with a static/cached vertex buffer rather than
        // creating and destroying every frame
    };
}