const string non_null = """name,variant
"0","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"1","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"2","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"3","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"4","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"5","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"6","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"7","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"8","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"9","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
""";

const string null_csv = """name,variant
"0","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"1","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"2","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"3","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"4","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"5","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"6","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"7","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"8","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"9","{'str1': <'str'>, 'str2': <int16 10>, 'str4': <10>, 'str5': <int64 10>}"
"(null)","(null)"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", non_null_func);
    Test.add_func ("/null", null_func);

    return Test.run ();
}

public void non_null_func () {
    try {
        var deserializer = new Valentine.ObjectDeserializer<VariantObject> ();
        VariantObject[] array = deserializer.deserialize_from_string (non_null);

        var serializer = new Valentine.ObjectSerializer<VariantObject> ();
        foreach (var obj in array) {
            serializer.add_object (obj);
        }

        print ("Results: %s\n", serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public void null_func () {
    try {
        var deserializer = new Valentine.ObjectDeserializer<VariantObject> ();
        VariantObject[] array = deserializer.deserialize_from_string (null_csv);

        var serializer = new Valentine.ObjectSerializer<VariantObject> ();
        foreach (var obj in array) {
            serializer.add_object (obj);
        }

        print ("Results: %s\n", serializer.to_string ());
    }
    catch (Error e) {
        critical (e.message);
    }
}

public class VariantObject : Object {
    public string name { get; set; }
    public Variant variant { get; set; }
}
