function Vector3(_x = 0, _y = _x, _z = _x) constructor {
    X = _x;
    Y = _y;
    Z = _z;

    // ── Immutable operations (return new Vector3) ──────────────

    static Add = function(_v) {
        return new Vector3(X + _v.X, Y + _v.Y, Z + _v.Z);
    };

    static Sub = function(_v) {
        return new Vector3(X - _v.X, Y - _v.Y, Z - _v.Z);
    };

    static Mul = function(_v) {
        // component-wise vector * vector
        return new Vector3(X * _v.X, Y * _v.Y, Z * _v.Z);
    };

    static Div = function(_v) {
        return new Vector3(X / _v.X, Y / _v.Y, Z / _v.Z);
    };

    static Scale = function(_s) {
        // scalar multiply — separate from Mul for clarity
        return new Vector3(X * _s, Y * _s, Z * _s);
    };

    static Negate = function() {
        return new Vector3(-X, -Y, -Z);
    };

    static Normalize = function() {
        var _lenSq = X * X + Y * Y + Z * Z;
        if (_lenSq > math_get_epsilon()) {
            var _n = 1.0 / sqrt(_lenSq);
            return new Vector3(X * _n, Y * _n, Z * _n);
        }
        return new Vector3(X, Y, Z);
    };

    static Abs = function() {
        return new Vector3(abs(X), abs(Y), abs(Z));
    };

    static Floor = function() {
        return new Vector3(floor(X), floor(Y), floor(Z));
    };

    static Ceil = function() {
        return new Vector3(ceil(X), ceil(Y), ceil(Z));
    };

    static Round = function() {
        return new Vector3(round(X), round(Y), round(Z));
    };

    static Frac = function() {
        return new Vector3(frac(X), frac(Y), frac(Z));
    };

    static Min = function(_v) {
        return new Vector3(min(X, _v.X), min(Y, _v.Y), min(Z, _v.Z));
    };

    static Max = function(_v) {
        return new Vector3(max(X, _v.X), max(Y, _v.Y), max(Z, _v.Z));
    };

    static Clamp = function(_min, _max) {
        return new Vector3(
            clamp(X, _min.X, _max.X),
            clamp(Y, _min.Y, _max.Y),
            clamp(Z, _min.Z, _max.Z)
        );
    };

    static ClampLength = function(_min, _max) {
        var _len = sqrt(X * X + Y * Y + Z * Z);
        var _newLen = clamp(_len, _min, _max);
        var _n = _newLen / _len;
        return new Vector3(X * _n, Y * _n, Z * _n);
    };

    static Lerp = function(_v, _t) {
        return new Vector3(
            lerp(X, _v.X, _t),
            lerp(Y, _v.Y, _t),
            lerp(Z, _v.Z, _t)
        );
    };

    static Reflect = function(_normal) {
        var _dot2 = (X * _normal.X + Y * _normal.Y + Z * _normal.Z) * 2.0;
        return new Vector3(
            X - _dot2 * _normal.X,
            Y - _dot2 * _normal.Y,
            Z - _dot2 * _normal.Z
        );
    };

    static Project = function(_onto) {
        var _dot = X * _onto.X + Y * _onto.Y + Z * _onto.Z;
        var _lenSq = _onto.X * _onto.X + _onto.Y * _onto.Y + _onto.Z * _onto.Z;
        var _f = _dot / _lenSq;
        return new Vector3(_onto.X * _f, _onto.Y * _f, _onto.Z * _f);
    };

    static Cross = function(_v) {
        return new Vector3(
            Y * _v.Z - Z * _v.Y,
            Z * _v.X - X * _v.Z,
            X * _v.Y - Y * _v.X
        );
    };

    static Transform = function(_matrix) {
        var _res = matrix_transform_vertex(_matrix, X, Y, Z);
        return new Vector3(_res[0], _res[1], _res[2]);
    };

    // ── Mutable operations (modify self, return self) ──────────

    static AddSelf = function(_v) {
        X += _v.X; Y += _v.Y; Z += _v.Z;
        return self;
    };

    static SubSelf = function(_v) {
        X -= _v.X; Y -= _v.Y; Z -= _v.Z;
        return self;
    };

    static MulSelf = function(_v) {
        X *= _v.X; Y *= _v.Y; Z *= _v.Z;
        return self;
    };

    static DivSelf = function(_v) {
        X /= _v.X; Y /= _v.Y; Z /= _v.Z;
        return self;
    };

    static ScaleSelf = function(_s) {
        X *= _s; Y *= _s; Z *= _s;
        return self;
    };

    static NegateSelf = function() {
        X = -X; Y = -Y; Z = -Z;
        return self;
    };

    static NormalizeSelf = function() {
        var _lenSq = X * X + Y * Y + Z * Z;
        if (_lenSq > math_get_epsilon()) {
            var _n = 1.0 / sqrt(_lenSq);
            X *= _n; Y *= _n; Z *= _n;
        }
        return self;
    };

    static AbsSelf = function() {
        X = abs(X); Y = abs(Y); Z = abs(Z);
        return self;
    };

    static FloorSelf = function() {
        X = floor(X); Y = floor(Y); Z = floor(Z);
        return self;
    };

    static CeilSelf = function() {
        X = ceil(X); Y = ceil(Y); Z = ceil(Z);
        return self;
    };

    static RoundSelf = function() {
        X = round(X); Y = round(Y); Z = round(Z);
        return self;
    };

    static FracSelf = function() {
        X = frac(X); Y = frac(Y); Z = frac(Z);
        return self;
    };

    static MinSelf = function(_v) {
        X = min(X, _v.X); Y = min(Y, _v.Y); Z = min(Z, _v.Z);
        return self;
    };

    static MaxSelf = function(_v) {
        X = max(X, _v.X); Y = max(Y, _v.Y); Z = max(Z, _v.Z);
        return self;
    };

    static ClampSelf = function(_min, _max) {
        X = clamp(X, _min.X, _max.X);
        Y = clamp(Y, _min.Y, _max.Y);
        Z = clamp(Z, _min.Z, _max.Z);
        return self;
    };

    static ClampLengthSelf = function(_min, _max) {
        var _len = sqrt(X * X + Y * Y + Z * Z);
        var _n = clamp(_len, _min, _max) / _len;
        X *= _n; Y *= _n; Z *= _n;
        return self;
    };

    static LerpSelf = function(_v, _t) {
        X = lerp(X, _v.X, _t);
        Y = lerp(Y, _v.Y, _t);
        Z = lerp(Z, _v.Z, _t);
        return self;
    };

    static ReflectSelf = function(_normal) {
        var _dot2 = (X * _normal.X + Y * _normal.Y + Z * _normal.Z) * 2.0;
        X -= _dot2 * _normal.X;
        Y -= _dot2 * _normal.Y;
        Z -= _dot2 * _normal.Z;
        return self;
    };

    static CrossSelf = function(_v) {
        var _nx = Y * _v.Z - Z * _v.Y;
        var _ny = Z * _v.X - X * _v.Z;
        var _nz = X * _v.Y - Y * _v.X;
        X = _nx; Y = _ny; Z = _nz;
        return self;
    };

    static TransformSelf = function(_matrix) {
        var _res = matrix_transform_vertex(_matrix, X, Y, Z);
        X = _res[0]; Y = _res[1]; Z = _res[2];
        return self;
    };

    // ── Scalar queries (no allocation) ─────────────────────────

    static Dot = function(_v) {
        return X * _v.X + Y * _v.Y + Z * _v.Z;
    };

    static Length = function() {
        return sqrt(X * X + Y * Y + Z * Z);
    };

    static LengthSqr = function() {
        return X * X + Y * Y + Z * Z;
    };

    static DistanceTo = function(_v) {
        var _dx = X - _v.X, _dy = Y - _v.Y, _dz = Z - _v.Z;
        return sqrt(_dx * _dx + _dy * _dy + _dz * _dz);
    };

    static DistanceToSqr = function(_v) {
        var _dx = X - _v.X, _dy = Y - _v.Y, _dz = Z - _v.Z;
        return _dx * _dx + _dy * _dy + _dz * _dz;
    };

    static Equals = function(_v) {
        return (X == _v.X) && (Y == _v.Y) && (Z == _v.Z);
    };

    static MinComponent = function() {
        return min(X, Y, Z);
    };

    static MaxComponent = function() {
        return max(X, Y, Z);
    };

    // ── Utility ────────────────────────────────────────────────

    static Set = function(_x = 0, _y = _x, _z = _x) {
        X = _x; Y = _y; Z = _z;
        return self;
    };

    static Clone = function() {
        return new Vector3(X, Y, Z);
    };

    static Copy = function(_dest) {
        _dest.X = X; _dest.Y = Y; _dest.Z = Z;
        return self;
    };

    static ToArray = function(_arr = undefined, _i = 0) {
        _arr ??= array_create(3, 0);
        _arr[@ _i] = X;
        _arr[@ _i + 1] = Y;
        _arr[@ _i + 2] = Z;
        return _arr;
    };

    static FromArray = function(_arr, _i = 0) {
        X = _arr[_i]; Y = _arr[_i + 1]; Z = _arr[_i + 2];
        return self;
    };

    static toString = function() {
        return $"({X}, {Y}, {Z})";
    };
}

// warm up static methods
new Vector3(0);