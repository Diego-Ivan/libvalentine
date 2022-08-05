const string CSV ="""name,file
"DataDir","/var/home/diegoivan/.local/share"
"CacheDir","/var/home/diegoivan/.cache"
"(null)","(null)"
""";

public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/file-test", file_test_func);

    return Test.run ();
}

public void file_test_func () {
    var deserializer = new Valentine.ObjectDeserializer<FileObject> ();
    var array = deserializer.deserialize_from_string (CSV);

    var serializer = new Valentine.ObjectSerializer<FileObject> ();
    foreach (var obj in array) {
        serializer.add_object (obj);
    }
    print ("Created Objects\n%s", serializer.to_string ());
}

public class FileObject : Object {
    public string name { get; set; }
    public File file { get; set; }
}
