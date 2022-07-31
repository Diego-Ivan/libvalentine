public struct Person {
    public string name;
    public int age;
}

public class MyObject : Object {
    public Person person { get; set; }
    public bool hired { get; set; default = true; }
}

string base_dir;
public static int main (string[] args) {
    Test.init (ref args);

    base_dir = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_special_dir (DOCUMENTS), "Valentine Tests", "Custom Types Test");
    DirUtils.create_with_parents (base_dir, 0755);

    Test.add_func ("/structs", custom_type_func);
    Test.add_func ("/structs-null", custom_type_and_null_func);
    Test.add_func ("/unsupported", type_unsupported);


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

        File file = File.new_for_path (Path.build_filename (base_dir, "custom non-null.csv"));
        if (!file.query_exists ()) {
            file.create (NONE);
        }

        string output_serializer = writer.to_string ();
        print ("Expected Output from deserializer: \n%s", output_serializer);
        FileUtils.set_contents (file.get_path (), output_serializer);

        print ("Received input from deserializer: \n");

        var serializer = new Valentine.ObjectDeserializer<MyObject> ();
        serializer.add_custom_parser_for_type (typeof (Person), serialization_func);

        MyObject[] deserialized = serializer.deserialize_from_file (file.get_path ());

        var iwriter = new Valentine.ObjectWriter<MyObject> ();
        iwriter.add_custom_parser_for_type (typeof(Person), conversion_func);
        foreach (var obj in deserialized) {
            iwriter.add_object (obj);
        }

        print (iwriter.to_string ());
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
        var writer = new Valentine.ObjectWriter<MyObject> ();
        for (int i = 0; i < people.length; i++) {
            writer.add_object (new MyObject () {
                person = people[i]
            });
        }

        File file = File.new_for_path (Path.build_filename (base_dir, "custom unsupported.csv"));
        if (!file.query_exists ()) {
            file.create (NONE);
        }

        string output_serializer = writer.to_string ();
        print ("Expected Output from deserializer: \n%s", output_serializer);
        FileUtils.set_contents (file.get_path (), output_serializer);

        print ("Received input from deserializer: \n");

        var serializer = new Valentine.ObjectDeserializer<MyObject> ();

        MyObject[] deserialized = serializer.deserialize_from_file (file.get_path ());

        var iwriter = new Valentine.ObjectWriter<MyObject> ();
        foreach (var obj in deserialized) {
            iwriter.add_object (obj);
        }

        print (iwriter.to_string ());
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
        File file = File.new_for_path (Path.build_filename (base_dir, "custom null.csv"));
        if (!file.query_exists ()) {
            file.create (NONE);
        }

        string output_serializer = writer.to_string ();
        print ("Expected Output from deserializer: \n%s", output_serializer);
        FileUtils.set_contents (file.get_path (), output_serializer);

        print ("Received input from deserializer: \n");

        var serializer = new Valentine.ObjectDeserializer<MyObject> ();
        serializer.add_custom_parser_for_type (typeof (Person), serialization_func);

        MyObject[] deserialized = serializer.deserialize_from_file (file.get_path ());

        var iwriter = new Valentine.ObjectWriter<MyObject> ();
        iwriter.add_custom_parser_for_type (typeof(Person), conversion_func);
        foreach (var obj in deserialized) {
            iwriter.add_object (obj);
        }

        print (iwriter.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
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
