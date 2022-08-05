public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/flap-test", flap_test_func);

    return Test.run ();
}

public void flap_test_func () {
    Adw.init ();
    var writer = new Valentine.ObjectSerializer<Adw.Flap> ();
    for (int i = 0; i < 2000; i++) {
        writer.add_object (new Adw.Flap ());
    }

    message ("Timer Started");
    stdout.printf (writer.to_string ());
    message ("Timer Ended");
}
