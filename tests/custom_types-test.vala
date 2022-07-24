public struct Person {
    public string name;
    public int age;
}

public class MyObject : Object {
    public Person person { get; set; }
    public bool hired { get; set; default = true; }
}

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/structs", custom_type_func);
    Test.add_func ("/structs-null", custom_type_and_null_func);

    return Test.run ();
}

public void custom_type_func () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 },
    };

    try {
        var writer = new Valentine.ObjectWriter<MyObject> ();
        for (int i = 0; i < people.length; i++) {
            writer.add_object (new MyObject () {
                person = people[i]
            });
        }

        writer.add_custom_parser_for_type (typeof(Person), conversion_func);
        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void custom_type_and_null_func () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 },
    };

    try {
        var writer = new Valentine.ObjectWriter<MyObject> ();

        for (int i = 0; i < people.length; i++) {
            writer.add_object (new MyObject () {
                person = people[i]
            });
        }
        writer.add_object (new MyObject ());

        writer.add_custom_parser_for_type (typeof(Person), conversion_func);
        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public string conversion_func (Value val) {
    var person = (Person) val;
    return "%s:%i".printf (person.name, person.age);
}
