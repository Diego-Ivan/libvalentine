public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/collector", collector_test);
    Test.add_func ("/flags", flag_test_func);

    return Test.run ();
}
