public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/performance", performance_func);

    return Test.run ();
}

public void performance_func () {
    PerformanceObject[] test_objects = {
        new PerformanceObject (500),
        new PerformanceObject (1000),
        new PerformanceObject (2000),
        new PerformanceObject (3000),
    };

    Valentine.ObjectSerializer<Adw.Flap>[] serializers = {};

    Adw.init ();

    foreach (var obj in test_objects) {
        var writer = new Valentine.ObjectSerializer<Adw.Flap> ();
        for (int i = 0; i < obj.n_objects; i++) {
            writer.add_object (new Adw.Flap ());
        }

        serializers += writer;
    }

    for (int i = 0; i < serializers.length; i++) {
        var deserializer = new Valentine.ObjectDeserializer<Adw.Flap> ();
        debug ("Got here");
        Test.timer_start ();
        deserializer.deserialize_from_string (serializers[i].to_string ());
        test_objects[i].time_taken = Test.timer_elapsed ();
    }

    var writer = new Valentine.ObjectSerializer<PerformanceObject> ();
    for (int i = 0; i < test_objects.length; i++) {
        writer.add_object (test_objects[i]);
    }
    stdout.printf (writer.to_string ());
}

public class PerformanceObject : Object {
    public int n_objects { get; set; }
    public double time_taken { get; set; }

    public PerformanceObject (int n) {
        Object (n_objects: n);
    }
}
