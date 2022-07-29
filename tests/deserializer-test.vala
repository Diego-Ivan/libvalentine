public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/test-func", test_func);

    return Test.run ();
}

public void test_func () {
    try {
        var deserializer = new Valentine.ObjectDeserializer<BasicTypesClass> ();
        BasicTypesClass[] objects = deserializer.deserialize_from_file ("/var/home/diegoivan/basic-types.csv");

        var serializer = new Valentine.ObjectWriter<BasicTypesClass> ();
        foreach (var obj in objects) {
            serializer.add_object (obj);
        }

        print (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public enum MyEnum {
    VALUE_1,
    VALUE_2
}

[Flags]
public enum MyFlags {
    FLAG_1,
    FLAG_2,
    FLAG_3,
    FLAG_4
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
