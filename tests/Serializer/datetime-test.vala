public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/date-time", date_time_func);
    Test.add_func ("/date-time-null", date_time_null_func);

    return Test.run ();
}

public void date_time_func () {
    DateObject[] objects = {
        new DateObject ("Diego") { date = new DateTime.now_local () },
        new DateObject ("Daniela") { date = new DateTime.now_local () },
        new DateObject ("Lucas") { date = new DateTime.now_local () },
        new DateObject ("Oscar") { date = new DateTime.now_local () },
        new DateObject ("Luna") { date = new DateTime.now_local () },
        new DateObject ("Octavio") { date = new DateTime.now_local () },
    };

    try {
        var serializer = new Valentine.ObjectSerializer <DateObject> ();
        for (int i = 0; i < objects.length; i++) {
            serializer.add_object (objects[i]);
        }

        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void date_time_null_func () {
    DateObject[] objects = {
        new DateObject ("Diego") { date = new DateTime.now_local () },
        new DateObject ("Daniela") { date = new DateTime.now_local () },
        new DateObject ("Lucas") { date = new DateTime.now_local () },
        new DateObject ("George"),
        new DateObject ("Oscar") { date = new DateTime.now_local () },
        new DateObject ("Luna") { date = new DateTime.now_local () },
        new DateObject ("Octavio") { date = new DateTime.now_local () },
    };

    try {
        var serializer = new Valentine.ObjectSerializer<DateObject> ();
        for (int i = 0; i < objects.length; i++) {
            serializer.add_object (objects[i]);
        }

        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
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
