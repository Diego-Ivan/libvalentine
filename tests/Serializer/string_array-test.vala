public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/array-test-required-quotes", array_only_required_func);
    Test.add_func ("/array-test-all-quoted", array_all_quoted);
    Test.add_func ("/array-test-required-null", array_only_required_null);
    Test.add_func ("/array-test-all-quoted-null", array_all_quoted_null);

    return Test.run ();
}

public void array_only_required_func () {
    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    serializer.write_mode = ONLY_REQUIRED_QUOTES;
    serializer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
    serializer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
    serializer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });

    stdout.printf (serializer.to_string ());
}

public void array_all_quoted () {
    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    serializer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
    serializer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
    serializer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });

    stdout.printf (serializer.to_string ());
}

public void array_only_required_null () {
    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    serializer.write_mode = ONLY_REQUIRED_QUOTES;
    serializer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
    serializer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
    serializer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });
    serializer.add_object (new ArrayObject () {name = "null"});
    serializer.add_object (new ArrayObject ());

    stdout.printf (serializer.to_string ());
}

public void array_all_quoted_null () {
    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    serializer.add_object (new ArrayObject () { name = "saludos", array = {"hola", "adios"}});
    serializer.add_object (new ArrayObject () { name = "numeros", array = {"uno", "dos", "tres"} });
    serializer.add_object (new ArrayObject () { name = "numbers", array = {"one", "two", "three"} });
    serializer.add_object (new ArrayObject () {name = "null"});
    serializer.add_object (new ArrayObject ());

    stdout.printf (serializer.to_string ());
}

public class ArrayObject : Object {
    public string name { get; set; }
    public string[] array { get; set; }
}
