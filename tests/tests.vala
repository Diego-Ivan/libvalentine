public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/collector", collector_test);

    return Test.run ();
}
