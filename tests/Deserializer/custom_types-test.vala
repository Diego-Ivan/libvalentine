const string NON_NULL_CSV = """person,hired
"Diego:17","true"
"George:20","true"
"Lucas:29","true"
"Daniela:18","true"
"Luna:25","true"
""";

const string NULL_CSV = """person,hired
"Diego:17","true"
"George:20","true"
"Lucas:29","true"
"Daniela:18","true"
"Luna:25","true"
"(null):0","true"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", non_null_func);
    Test.add_func ("/null-func", null_func);

    return Test.run ();
}

public void non_null_func () {
    var deserializer = new Valentine.ObjectDeserializer<MyObject> ();
    deserializer.add_custom_parser_for_type (typeof (Person), serialization_func);
    var array = deserializer.deserialize_from_string (NON_NULL_CSV);

    print ("Objects deserialized: \n");

    var serializer = new Valentine.ObjectSerializer<MyObject> ();
    serializer.add_custom_parser_for_type (typeof (Person), conversion_func);

    foreach (var obj in array) {
        serializer.add_object (obj);
    }
    print (serializer.to_string ());
}

public void null_func () {
    var deserializer = new Valentine.ObjectDeserializer<MyObject> ();
    deserializer.add_custom_parser_for_type (typeof (Person), serialization_func);
    var array = deserializer.deserialize_from_string (NULL_CSV);

    print ("Objects deserialized: \n");

    var serializer = new Valentine.ObjectSerializer<MyObject> ();
    serializer.add_custom_parser_for_type (typeof (Person), conversion_func);

    foreach (var obj in array) {
        serializer.add_object (obj);
    }
    print (serializer.to_string ());
}

public string conversion_func (Value val) {
    var person = (Person) val;
    return "%s:%i".printf (person.name, person.age);
}

public Value serialization_func (string str) {
    string[] elements = str.split (":");
    // elements[0] will be the name and elements[1] will be the age

    Person person = Person ();
    person.name = elements[0];
    person.age = int.parse (elements[1]);

    Value val = Value (typeof (Person));
    val.set_boxed (&person);
    return val;
}

public struct Person {
    public string name;
    public int age;
}

public class MyObject : Object {
    public Person person { get; set; }
    public bool hired { get; set; default = true; }
}
