const string non_null = """name,array
"saludos","[""hola"", ""adios""]"
"numeros","[""uno"", ""dos"", ""tres""]"
"numbers","[""one"", ""two"", ""three""]"
""";

const string null_csv = """name,array
"saludos","[""hola"", ""adios""]"
"numeros","[""uno"", ""dos"", ""tres""]"
"numbers","[""one"", ""two"", ""three""]"
"null","NULL"
"(null)","NULL"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", non_null_func);
    Test.add_func ("/null", null_func);

    return Test.run ();
}

public void non_null_func () {
    var deserializer = new Valentine.ObjectDeserializer<ArrayObject> ();
    var array = deserializer.deserialize_from_string (non_null);

    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    foreach (var obj in array) {
        serializer.add_object (obj);
    }

    print ("Result: \n%s", serializer.to_string ());
}

public void null_func () {
    var deserializer = new Valentine.ObjectDeserializer<ArrayObject> ();
    var array = deserializer.deserialize_from_string (null_csv);

    var serializer = new Valentine.ObjectSerializer<ArrayObject> ();
    foreach (var obj in array) {
        serializer.add_object (obj);
    }

    print ("Result: \n%s", serializer.to_string ());
}

public class ArrayObject : Object {
    public string name { get; set; }
    public string[] array { get; set; }
}
