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

    var doc = new Valentine.Doc ();
    stdout.printf (doc.build_from_array ((Object[]) objects));
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

    var doc = new Valentine.Doc ();
    stdout.printf (doc.build_from_array ((Object[]) objects));
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
