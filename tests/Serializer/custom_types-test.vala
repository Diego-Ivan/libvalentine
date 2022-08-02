public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", custom_non_null);
    Test.add_func ("/null", custom_null);
    Test.add_func ("/unsupported", type_unsupported);

    return Test.run ();
}

public void custom_non_null () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 },
    };

    try {
        var serializer = new Valentine.ObjectSerializer<MyObject> ();
        for (int i = 0; i < people.length; i++) {
            serializer.add_object (new MyObject (){ person = people[i] });
        }

        serializer.add_custom_parser_for_type (typeof (Person), person_serialization_func);
        print (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void custom_null () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 },
    };

    try {
        var serializer = new Valentine.ObjectSerializer<MyObject> ();
        for (int i = 0; i < people.length; i++) {
            serializer.add_object (new MyObject (){ person = people[i] });
        }
        serializer.add_object (new MyObject ());

        serializer.add_custom_parser_for_type (typeof (Person), person_serialization_func);
        print (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void type_unsupported () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 },
    };

    try {
        var serializer = new Valentine.ObjectSerializer<MyObject> ();
        for (int i = 0; i < people.length; i++) {
            serializer.add_object (new MyObject (){ person = people[i] });
        }

        print (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public string person_serialization_func (Value val) {
    Person? person = (Person) val;
    if (person == null) {
        return "(null)";
    }
    return "%s:%i".printf (person.name, person.age);
}

public struct Person {
    public string name;
    public int age;
}

public class MyObject : Object {
    public Person person { get; set; }
    public bool hired { get; set; default = true; }

    public MyObject () {
    }
}
