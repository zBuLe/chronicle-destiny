function Matrix3(_x, _y, _z) constructor {
    // each is a Vector3 representing one axis
    X = _x;     // right / local X
    Y = _y;     // forward / local Y
    Z = _z;     // up / local Z

    static ToArray = function() {
        return [
            X.X, Y.X, Z.X,
            X.Y, Y.Y, Z.Y,
            X.Z, Y.Z, Z.Z,
        ];
    };

    static ToAxes = function() {
        return [X, Y, Z];
    };

    static ToMatrix4 = function() {
        return new Matrix4([
            X.X, X.Y, X.Z, 0,
            Y.X, Y.Y, Y.Z, 0,
            Z.X, Z.Y, Z.Z, 0,
            0,   0,   0,   1
        ]);
    };

    static FromArray = function(_arr) {
        X.Set(_arr[0], _arr[3], _arr[6]);
        Y.Set(_arr[1], _arr[4], _arr[7]);
        Z.Set(_arr[2], _arr[5], _arr[8]);
        return self;
    };
}