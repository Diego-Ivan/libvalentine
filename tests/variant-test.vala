public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/dictionary", variant_test_func);
    Test.add_func ("/dictionary-null", variant_test_null_func);

    return Test.run ();
}

public void variant_test_func () {
    VariantObject[] objects = {};

	for (int i = 0; i < 10; i++) {
        VariantBuilder builder = new VariantBuilder (new VariantType ("a{sv}"));
	    builder.add ("{sv}", "str1", new Variant.string ("str"));
	    builder.add ("{sv}", "str2", new Variant.int16 (10));
	    builder.add ("{sv}", "str4", new Variant.int32 (10));
	    builder.add ("{sv}", "str5", new Variant.int64 (10));

	    objects += new VariantObject () {
	        name = i.to_string (),
	        variant = builder.end ()
	    };
	}

	var doc = new Valentine.Doc ();
	stdout.printf (doc.build_from_array ((Object[]) objects));
}

public void variant_test_null_func () {
    VariantObject[] objects = {};

	for (int i = 0; i < 10; i++) {
        VariantBuilder builder = new VariantBuilder (new VariantType ("a{sv}"));
	    builder.add ("{sv}", "str1", new Variant.string ("str"));
	    builder.add ("{sv}", "str2", new Variant.int16 (10));
	    builder.add ("{sv}", "str4", new Variant.int32 (10));
	    builder.add ("{sv}", "str5", new Variant.int64 (10));

	    objects += new VariantObject () {
	        name = i.to_string (),
	        variant = builder.end ()
	    };
	}

	objects += new VariantObject ();

	var doc = new Valentine.Doc ();
	stdout.printf (doc.build_from_array ((Object[]) objects));
}

public class VariantObject : Object {
    public string name { get; set; }
    public Variant variant { get; set; }
}
