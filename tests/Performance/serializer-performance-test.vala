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
        new PerformanceObject (5000),
        new PerformanceObject (10000),
    };

    Adw.init ();

    foreach (var obj in test_objects) {
        try {
            var writer = new Valentine.ObjectSerializer<Adw.Flap> ();
            for (int i = 0; i < obj.n_objects; i++) {
                writer.add_object (new Adw.Flap ());
            }

            Test.timer_start ();
            writer.to_string ();
            obj.time_taken = Test.timer_elapsed ();
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    try {
        var writer = new Valentine.ObjectSerializer<PerformanceObject> ();
        for (int i = 0; i < test_objects.length; i++) {
            writer.add_object (test_objects[i]);
        }
        stdout.printf (writer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class PerformanceObject : Object {
    public int n_objects { get; set; }
    public double time_taken { get; set; }

    public PerformanceObject (int n) {
        Object (n_objects: n);
    }
}
