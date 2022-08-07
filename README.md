# Libvalentine

A library that can convert a CSV file to GLib.Objects and viceversa. For example:

```vala
public class Example : Object {
    public string name { get; set; default = "hello"; }
    public int something { get; set; default = 1; }
    
    // This property is private read, therefore it won't appear in the CSV file
    public bool boolean { private get; set; default = false; }
}
Example[] examples = {
        new Example (), new Example () { name = "hola" }, new Example () { something = 2 }
};

var serializer = new Valentine.ObjectSerializer<Example> ();
example.add_object (new Example ());
example.add_object (new Example () { name = "Hola" });
example.add_object (new Example () { something = 2 });
```

Will have the following output:

```csv
name,something
"hello","1"
"hola","1"
"hello","2"
```

Parsing a CSV text is done in the following way:

```vala
string csv = """name,something
"Object 1,"45"
"Object 7","19"
"Object 9","13"
"""

var deserializer = new Valentine.ObjectDeserializer<Example> ();
List<Example> object_list = deserializer.deserialize_from_string (csv);

foreach (var object in Example) {
    print ("name: %s; something: "%i", object.name, object.something);
}

/*
 * Output:
 * name: Object 1; something: 45
 * name: Object 7; something: 19
 * name: Object 9; something: 13
*/
```

## Usage

Valentine provides a simple API that converts GLib.Objects into a CSV file.

```vala
var serializer = new Valentine.ObjectSerializer<Adw.Flap> ();
serializer.add_object (new Adw.Flap ());
serializer.add_object (new Adw.Flap ());

stdout.printf (serializer.to_string ());
```

It also provides an option to save the document directly to a file:
```vala
serializer.save_to_file ("/var/home/user/Documents/my_file.csv");
```

It also provides an API that converts CSV files to Object Lists

```vala
var deserializer = new Valentine.ObjectDeserializer<Adw.Flap> ();
List<Adw.Flap> list = deserializer.deserializer_from_file ("/path/to/csv/file.csv");
```

## Features

Support for property types:

- [x] Integers
- [x] Booleans
- [x] Strings
- [x] Chars
- [ ] Objects (Maybe also an option to not parse objects?)
- [x] UChars
- [x] Longs
- [X] DateTimes
- [x] Files
- [x] Uint
- [x] Floats
- [x] Doubles
- [X] Variants
- [x] Flags
- [x] Enums
- [x] Possibility to add user defined functions to parse other types (such as custom classes)

Other features:

- [x] Save directly to a file
- [x] Parse CSV file and create an object with an expected type
