public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/basic-types", non_null_test);
    Test.add_func ("/basic-types-null", null_test);

    return Test.run ();
}

public void non_null_test () {
    BasicTypesClass[] objects = {};
    for (int i = 0; i < 10; i++) {
        objects += new BasicTypesClass () { str = "string", ch = 'c', uc = 'u', integer = i, uinteger = i+3, longint = long.MAX, longuint = ulong.MAX, db = 1.2413424, fl = (float) 1.243 };
    }

    var doc = new Valentine.Doc ();
    stdout.printf (doc.build_from_array ((Object[]) objects));
}

public void null_test () {
    BasicTypesClass[] objects = {};
    for (int i = 0; i < 10; i++) {
        objects += new BasicTypesClass ();
    }

    var doc = new Valentine.Doc ();
    stdout.printf (doc.build_from_array ((Object[]) objects));
}

public class BasicTypesClass : Object {
    public string str { get; set; }
    public char ch { get; set; }
    public uchar uc { get; set; }
    public int integer { get; set; }
    public uint uinteger { get; set; }
    public long longint { get; set; }
    public ulong longuint { get; set; }
    public double db { get; set; }
    public float fl { get; set; }
}
