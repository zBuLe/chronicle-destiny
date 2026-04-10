function Matrix4(_arr = undefined) constructor {
    Raw = _arr ?? matrix_build_identity();

    static Multiply = function(_other) {
        var _result = new Matrix4();
        matrix_multiply(Raw, _other.Raw, _result.Raw);
        return _result;
    };

    static MultiplySelf = function(_other) {
        matrix_multiply(Raw, _other.Raw, Raw);
        return self;
    };

    static Inverse = function() {
        var _result = new Matrix4();
        matrix_inverse(Raw, _result.Raw);
        return _result;
    };

    static InverseSelf = function() {
        matrix_inverse(Raw, Raw);
        return self;
    };

    static GetOrientation = function() {
        var m = Raw;
        return new Matrix3(
            new Vector3(m[0], m[1], m[2]),
            new Vector3(m[4], m[5], m[6]),
            new Vector3(m[8], m[9], m[10])
        );
    };

    static GetTranslation = function() {
        return new Vector3(Raw[12], Raw[13], Raw[14]);
    };

    static TransformPoint = function(_v) {
        var _res = matrix_transform_vertex(Raw, _v.X, _v.Y, _v.Z, 1);
        return new Vector3(_res[0], _res[1], _res[2]);
    };

    static TransformVector = function(_v) {
        var _res = matrix_transform_vertex(Raw, _v.X, _v.Y, _v.Z, 0);
        return new Vector3(_res[0], _res[1], _res[2]);
    };

    static BuildTransform = function(_pos, _rot_x, _rot_y, _rot_z, _sx, _sy, _sz) {
        matrix_build(_pos.X, _pos.Y, _pos.Z,
                     _rot_x, _rot_y, _rot_z,
                     _sx, _sy, _sz, Raw);
        return self;
    };
}