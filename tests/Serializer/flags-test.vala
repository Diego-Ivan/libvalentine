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

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/enum-test", enum_test_func);
    Test.add_func ("/flags-test", flags_test_func);
    Test.add_func ("/flags-and-enum-test", flag_enum_test_func);

    return Test.run ();
}

public void flag_enum_test_func () {
    ExampleClass[] objects = {
        new ExampleClass () { my_flags = PARAM_1 | PARAM_2, my_uint = 2, my_enum = SOMETHING },
        new ExampleClass () { my_flags = PARAM_3, my_uint = 17, my_enum = SOMEWHERE },
        new ExampleClass ()
    };

    try {
        var serializer = new Valentine.ObjectSerializer<ExampleClass> ();
        for (int i = 0; i < objects.length; i++) {
            serializer.add_object (objects[i]);
        }

        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void enum_test_func () {
    EnumKlass[] objects = {
        new EnumKlass () { my_enum = SOMETHING },
        new EnumKlass () { my_enum = SOMEWHERE },
        new EnumKlass ()
    };

    try {
        var serializer = new Valentine.ObjectSerializer<EnumKlass> ();
        for (int i = 0; i < objects.length; i++) {
            serializer.add_object (objects[i]);
        }

        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void flags_test_func () {
    FlagKlass[] objects = {
        new FlagKlass () { my_flags = PARAM_1 | PARAM_3 },
        new FlagKlass () { my_flags = PARAM_2 },
        new FlagKlass ()
    };

    try {
        var serializer = new Valentine.ObjectSerializer<FlagKlass> ();
        for (int i = 0; i < objects.length; i++) {
            serializer.add_object (objects[i]);
        }

        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class EnumKlass : Object {
    public MyEnum my_enum { get; set; }
}

public class FlagKlass : Object {
    public MyFlags my_flags { get; set; }
}

public class ExampleClass : Object {
    public MyFlags my_flags { get; set; }
    public uint my_uint { get; set; }
    public MyEnum my_enum { get; set; }
}
