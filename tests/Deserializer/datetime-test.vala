const string NON_NULL_CSV = """user,date
"Diego","2022-08-02T22:59:40.794761-05"
"Daniela","2022-08-02T22:59:40.794820-05"
"Lucas","2022-08-02T22:59:40.794828-05"
"Oscar","2022-08-02T22:59:40.794835-05"
"Luna","2022-08-02T22:59:40.794841-05"
"Octavio","2022-08-02T22:59:40.794848-05"
""";

const string NULL_CSV = """user,date
"Diego","2022-08-02T22:59:40.795632-05"
"Daniela","2022-08-02T22:59:40.795642-05"
"Lucas","2022-08-02T22:59:40.795650-05"
"George","(null)"
"Oscar","2022-08-02T22:59:40.795659-05"
"Luna","2022-08-02T22:59:40.795671-05"
"Octavio","2022-08-02T22:59:40.795679-05"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", non_null_test);
    Test.add_func ("/null", null_test);

    return Test.run ();
}

public void non_null_test () {
    var deserializer = new Valentine.ObjectDeserializer<DateObject> ();
    var array = deserializer.deserialize_from_string (NON_NULL_CSV);

    var serializer = new Valentine.ObjectSerializer<DateObject> ();
    foreach (var obj in array) {
        serializer.add_object (obj);
    }

    print ("Received Objects: \n");
    print (serializer.to_string ());
}

public void null_test () {
    var deserializer = new Valentine.ObjectDeserializer<DateObject> ();
    var array = deserializer.deserialize_from_string (NULL_CSV);

    var serializer = new Valentine.ObjectSerializer<DateObject> ();
    foreach (var obj in array) {
        serializer.add_object (obj);
    }

    print ("Received Objects: \n");
    print (serializer.to_string ());
}

public class DateObject : Object {
    public string user { get; set; }
    public DateTime date { get; set; }

    public DateObject (string u) {
        Object (
            user: u
        );
    }
}
