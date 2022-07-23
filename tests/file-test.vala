public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/file", file_test_func);

    return Test.run ();
}

public void file_test_func () {
    FileObject[] objects = {
        new FileObject () { file = File.new_for_path (Environment.get_user_data_dir ()), name = "DataDir" },
        new FileObject () { file = File.new_for_path (Environment.get_user_cache_dir ()), name = "CacheDir" },
        new FileObject ()
    };

    var doc = new Valentine.Doc ();
    stdout.printf (doc.build_from_array ((Object[]) objects));
}

public class FileObject : Object {
    public string name { get; set; }
    public File file { get; set; }
}
