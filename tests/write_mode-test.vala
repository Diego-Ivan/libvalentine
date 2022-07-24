public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/all-quoted", all_quoted_test);
    Test.add_func ("/only-required", only_required_test);

    return Test.run ();
}

public void all_quoted_test () {
    var mode = Valentine.WriteMode.ALL_QUOTED;
    string[] tests = {
        """ My String """,
        """ "My Quoted String" """,
        """ My string, with commas """,
        """ "My Quoted String", "with commas" """
    };

    foreach (var test in tests) {
        stdout.printf ("%s : %s\n", test, mode.parse_string (test, ","));
    }
}

public void only_required_test () {
    var mode = Valentine.WriteMode.ONLY_REQUIRED_QUOTES;
    string[] tests = {
        """ My String """,
        """ "My Quoted String" """,
        """ My string, with commas """,
        """ "My Quoted String", "with commas" """
    };

    foreach (var test in tests) {
        stdout.printf ("%s : %s\n", test, mode.parse_string (test, ","));
    }
}
