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

public void flag_test_func () {
    ExampleClass[] objects = {
        new ExampleClass () { my_flags = PARAM_1 | PARAM_2, my_uint = 2, my_enum = SOMETHING },
        new ExampleClass () { my_flags = PARAM_3, my_uint = 17, my_enum = SOMEWHERE }
    };

    var doc = new Valentine.Doc ();
    stdout.printf ("%s", doc.build_from_array ((Object[]) objects));
}

public class ExampleClass : Object {
    public MyFlags my_flags { get; set; }
    public uint my_uint { get; set; }
    public MyEnum my_enum { get; set; }
}
