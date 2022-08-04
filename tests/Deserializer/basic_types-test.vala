const string NON_NULL_CSV ="""str,ch,uc,integer,uinteger,longint,longuint,db,fl
"string","c","117","0","3","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","1","4","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","2","5","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","3","6","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","4","7","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","5","8","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","6","9","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","7","10","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","8","11","9223372036854775807","18446744073709551615","1.2413424","1.243"
"string","c","117","9","12","9223372036854775807","18446744073709551615","1.2413424","1.243"
""";

const string NULL_CSV ="""str,ch,uc,integer,uinteger,longint,longuint,db,fl
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
"(null)","","0","0","0","0","0","0","0"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/non-null", non_null_func);
    Test.add_func ("/null-func", null_func);

    return Test.run ();
}

public void non_null_func () {
    var deserializer = new Valentine.ObjectDeserializer<BasicTypesClass> ();
    var array = deserializer.deserialize_from_string (NON_NULL_CSV);
    print ("%u objects were deserialized\n", array.length ());
}

public void null_func () {
    var deserializer = new Valentine.ObjectDeserializer<BasicTypesClass> ();
    var array = deserializer.deserialize_from_string (NULL_CSV);
    print ("%u objects were deserialized\n", array.length ());
}

public class BasicTypesClass : Object {
    public string str { get; set; }
    public char ch { get; set; }
    public uchar uc { get; set; }
    public int integer { get; set; }
    public uint uinteger { get; set; }
    public long longint { get; set; }
    public ulong longuint { get; set; }
    public double db { get; set; }
    public float fl { get; set; }
}
