function Collider(_shape, _reference, _mask = 1, _group = 1) constructor {
    Shape     = _shape;
    Reference = _reference;
    Mask      = _mask;
    Group     = _group;

    static CheckCollider = function(_other) {
        if (_other == self) return false;
        if (Mask & _other.Group == 0) return false;
        return Shape.CheckCollider(_other);
    };

    static CheckRay = function(_ray, _hit_info, _group = 1) {
        if (Mask & _group == 0) return false;
        return Shape.CheckRay(_ray, _hit_info);
    };

    static DisplaceSphere = function(_sphere) {
        return Shape.DisplaceSphere(_sphere);
    };

    static GetMin = function() { return Shape.GetMin(); };
    static GetMax = function() { return Shape.GetMax(); };
    static DebugDraw = function(_col = c_white) { Shape.DebugDraw(_col); };
}

/// Accelerator interface contract:
///   Add(collider)
///   Remove(collider)
///   CheckCollider(collider) → collider | undefined
///   CheckRay(ray, hit_info, group) → bool

function BruteForceAccelerator() constructor {
    Contents = [];

    static Add = function(_collider) {
        array_push(Contents, _collider);
    };

    static Remove = function(_collider) {
        var _i = array_get_index(Contents, _collider);
        if (_i != -1) array_delete(Contents, _i, 1);
    };

    static CheckCollider = function(_collider) {
        var _i = 0;
        repeat (array_length(Contents)) {
            var _other = Contents[_i++];
            if (_other.CheckCollider(_collider)) {
                return _other;
            }
        }
        return undefined;
    };

    static CheckRay = function(_ray, _hit_info, _group = 1) {
        var _hit = false;
        var _i = 0;
        repeat (array_length(Contents)) {
            if (Contents[_i++].CheckRay(_ray, _hit_info, _group)) {
                _hit = true;
            }
        }
        return _hit;
    };
}

function ColWorld(_accelerator = new BruteForceAccelerator()) constructor {
    Accelerator = _accelerator;
    Planes = [];    // infinite planes stored separately

    static Add = function(_collider) {
        if (instanceof(_collider.Shape) == "ColPlane") {
            array_push(Planes, _collider);
        } else {
            Accelerator.Add(_collider);
        }
    };

    static Remove = function(_collider) {
        if (instanceof(_collider.Shape) == "ColPlane") {
            var _i = array_get_index(Planes, _collider);
            if (_i != -1) array_delete(Planes, _i, 1);
        } else {
            Accelerator.Remove(_collider);
        }
    };

    static CheckCollider = function(_collider) {
        // check planes first
        var _i = 0;
        repeat (array_length(Planes)) {
            if (Planes[_i].CheckCollider(_collider)) return Planes[_i];
            _i++;
        }
        return Accelerator.CheckCollider(_collider);
    };

    static CheckRay = function(_ray, _group = 1, _max_dist = infinity) {
        var _hit_info = new RayHitInfo();

        var _i = 0;
        repeat (array_length(Planes)) {
            Planes[_i++].CheckRay(_ray, _hit_info, _group);
        }

        Accelerator.CheckRay(_ray, _hit_info, _group);

        return (_hit_info.Distance <= _max_dist) ? _hit_info : undefined;
    };

    static DisplaceSphere = function(_sphere_collider, _attempts = 5) {
        var _original_pos = _sphere_collider.Shape.Position.Clone();
        var _sphere = _sphere_collider.Shape;

        repeat (_attempts) {
            // check planes first
            var _hit = undefined;
            var _i = 0;
            repeat (array_length(Planes)) {
                if (Planes[_i].Shape.CheckSphere(_sphere)) {
                    _hit = Planes[_i];
                    break;
                }
                _i++;
            }

            _hit ??= Accelerator.CheckCollider(_sphere_collider);
            if (_hit == undefined) break;

            var _displaced = _hit.Shape.DisplaceSphere(_sphere);
            if (_displaced == undefined) break;

            _sphere.Set(_displaced);
        }

        var _final_pos = _sphere.Position;
        if (_original_pos.Equals(_final_pos)) {
            _sphere.Set(_original_pos);
            return undefined;
        }
        _sphere.Set(_original_pos);
        return _final_pos;
    };
}