public void collector_test () {
    Example[] examples = {
        new Example (), new Example () { name = "hola" }, new Example () { something = 2 }
    };

    var doc = new Valentine.Doc ();
    stdout.printf ("%s", doc.build_from_array ((Object[]) examples));
}

public class Example : Object {
    public string name { get; set; default = "hello"; }
    public int something { get; set; default = 1; }
    public bool booleano { private get; set; default = false; }
}
