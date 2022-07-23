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

    return Test.run ();
}

public void custom_type_func () {
    Person[] people = {
        { "Diego", 17 },
        { "George", 20 },
        { "Lucas", 29 },
        { "Daniela", 18 },
        { "Luna", 25 }
    };

    MyObject[] objects = {};

    foreach (var person in people) {
        objects += new MyObject () {
            person = person
        };
    }

    var doc = new Valentine.Doc ();
    doc.add_custom_func_for_type (typeof(Person), conversion_func);

    stdout.printf (doc.build_from_array ((Object[]) objects));
}

public string conversion_func (Value val) {
    var person = (Person) val;
    return "%s:%i".printf (person.name, person.age);
}
