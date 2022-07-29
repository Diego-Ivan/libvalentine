public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/test-func", test_func);

    return Test.run ();
}

public void test_func () {
    try {
        var deserializer = new Valentine.ObjectDeserializer<BasicTypesClass> ();
        deserializer.deserialize_from_file ("/var/home/diegoivan/basic-types.csv");
    }
    catch (Error e) {
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
