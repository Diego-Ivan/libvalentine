public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/array-test-required-quotes", array_only_required_func);
    Test.add_func ("/array-test-all-quoted", array_all_quoted);
    Test.add_func ("/array-test-required-null", array_only_required_null);
    Test.add_func ("/array-test-all-quoted-null", array_all_quoted_null);

    return Test.run ();
}

public void array_only_required_func () {
    try {
        var writer = new Valentine.ObjectWriter<ArrayObject> ();
        writer.write_mode = ONLY_REQUIRED_QUOTES;
        writer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
        writer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
        writer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void array_all_quoted () {
    try {
        var writer = new Valentine.ObjectWriter<ArrayObject> ();
        writer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
        writer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
        writer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void array_only_required_null () {
    try {
        var writer = new Valentine.ObjectWriter<ArrayObject> ();
        writer.write_mode = ONLY_REQUIRED_QUOTES;
        writer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
        writer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
        writer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });
        writer.add_object (new ArrayObject () {name = "null"});
        writer.add_object (new ArrayObject ());

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void array_all_quoted_null () {
    try {
        var writer = new Valentine.ObjectWriter<ArrayObject> ();
        writer.write_mode = ONLY_REQUIRED_QUOTES;
        writer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
        writer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
        writer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });
        writer.add_object (new ArrayObject () {name = "null"});
        writer.add_object (new ArrayObject ());

        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class ArrayObject : Object {
    public string name { get; set; }
    public string[] array { get; set; }
}
