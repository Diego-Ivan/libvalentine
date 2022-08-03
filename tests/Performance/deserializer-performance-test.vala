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

     Adw.init ();

     // TODO: we're declaring variables here to avoid double frees that are generated in C code
     // I'm really not sure why this is happening, maybe generics? I don't know, I'll rewrite this
     // when I remove generics from the API
     Valentine.ObjectSerializer<Adw.Flap> serializer;
     Valentine.ObjectDeserializer<Adw.Flap> deserializer;
     Adw.Flap[] array;
     for (int i = 0; i < test_objects.length; i++) {
         var obj = test_objects[i];
         string csv = "";
         try {
             serializer = new Valentine.ObjectSerializer<Adw.Flap> ();
             for (int j = 0; j < obj.n_objects; j++) {
                 serializer.add_object (new Adw.Flap ());
             }
             csv = serializer.to_string ();
         }
         catch (Error e) {
             critical (e.message);
         }

         try {
             deserializer = new Valentine.ObjectDeserializer<Adw.Flap> ();
             Test.timer_start ();
             array = deserializer.deserialize_from_string (csv);
             obj.time_taken = Test.timer_elapsed ();
             debug ("Reached here");
         }
         catch (Error e) {
             critical (e.message);
         }

     }

    // foreach (PerformanceObject obj in test_objects) {
    //     try {
    //         var writer = new Valentine.ObjectSerializer<Adw.Flap> ();
    //         for (int i = 0; i < obj.n_objects; i++) {
    //             writer.add_object (new Adw.Flap ());
    //         }

    //         var deserializer = new Valentine.ObjectDeserializer<Adw.Flap> ();
    //         Test.timer_start ();
    //         Adw.Flap[] array = deserializer.deserialize_from_string (writer.to_string ());
    //         message (array.length.to_string ());
    //         obj.time_taken = Test.timer_elapsed ();
    //     }
    //     catch (Error e) {
    //         critical (e.message);
    //     }
    // }

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
