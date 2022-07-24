public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/basic-types", non_null_test);
    Test.add_func ("/basic-types-null", null_test);

    return Test.run ();
}

public void non_null_test () {
    try {
        var writer = new Valentine.ObjectWriter<BasicTypesClass> ();
        for (int i = 0; i < 10; i++) {
            writer.add_object (new BasicTypesClass () { str = "string", ch = 'c', uc = 'u', integer = i, uinteger = i+3, longint = long.MAX, longuint = ulong.MAX, db = 1.2413424, fl = (float) 1.243 });
        }

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }

}

public void null_test () {
    try {
        var writer = new Valentine.ObjectWriter<BasicTypesClass> ();
        for (int i = 0; i < 10; i++) {
            writer.add_object (new BasicTypesClass ());
        }

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
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
