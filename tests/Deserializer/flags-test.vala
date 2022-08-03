const string csv = """my-flags,my-uint,my-enum
"MY_FLAGS_PARAM_1 | MY_FLAGS_PARAM_2","2","MY_ENUM_SOMETHING"
"MY_FLAGS_PARAM_3","17","MY_ENUM_SOMEWHERE"
"0x0","0","MY_ENUM_SOMETHING"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/test-func", test_func);

    return Test.run ();
}

public void test_func () {
    try {
        var deserializer = new Valentine.ObjectDeserializer<ExampleClass> ();
        ExampleClass[] array = deserializer.deserialize_from_string (csv);

        var serializer = new Valentine.ObjectSerializer<ExampleClass> ();
        foreach (var obj in array) {
            serializer.add_object (obj);
        }

        print ("Objects: \n%s", serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class ExampleClass : Object {
    public MyFlags my_flags { get; set; }
    public uint my_uint { get; set; }
    public MyEnum my_enum { get; set; }
}

[Flags]
public enum MyFlags {
    PARAM_1,
    PARAM_2,
    PARAM_3
}

public enum MyEnum {
    SOMETHING,
    SOMEWHERE
}
