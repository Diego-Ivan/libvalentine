public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/dictionary", variant_test_func);
    Test.add_func ("/dictionary-null", variant_test_null_func);

    return Test.run ();
}

public void variant_test_func () {
    try {
        var serializer = new Valentine.ObjectSerializer<VariantObject> ();
	    for (int i = 0; i < 10; i++) {
            VariantBuilder builder = new VariantBuilder (new VariantType ("a{sv}"));
	        builder.add ("{sv}", "str1", new Variant.string ("str"));
	        builder.add ("{sv}", "str2", new Variant.int16 (10));
	        builder.add ("{sv}", "str4", new Variant.int32 (10));
	        builder.add ("{sv}", "str5", new Variant.int64 (10));

	        serializer.add_object (new VariantObject () {
	            name = i.to_string (),
	            variant = builder.end ()
	        });
	    }
        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void variant_test_null_func () {
    try {
        var serializer = new Valentine.ObjectSerializer<VariantObject> ();
	    for (int i = 0; i < 10; i++) {
            VariantBuilder builder = new VariantBuilder (new VariantType ("a{sv}"));
	        builder.add ("{sv}", "str1", new Variant.string ("str"));
	        builder.add ("{sv}", "str2", new Variant.int16 (10));
	        builder.add ("{sv}", "str4", new Variant.int32 (10));
	        builder.add ("{sv}", "str5", new Variant.int64 (10));

	        serializer.add_object (new VariantObject () {
	            name = i.to_string (),
	            variant = builder.end ()
	        });

	    }
	    serializer.add_object (new VariantObject ());
        stdout.printf (serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class VariantObject : Object {
    public string name { get; set; }
    public Variant variant { get; set; }
}
