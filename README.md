# Libvalentine

A library that parses GLib.Objects and converts them into a readable CSV format by getting their readable properties and parsing them. For example, an array of objects like:

```vala
public class Example : Object {
    public string name { get; set; default = "hello"; }
    public int something { get; set; default = 1; }
    public bool boolean { private get; set; default = false; }
}
Example[] examples = {
        new Example (), new Example () { name = "hola" }, new Example () { something = 2 }
};
```

Will have the following output:

```csv
name,something
"hello","1"
"hola","1"
"hello","2"
```

## Usage

Valentine provides a simple API that converts objects to an string. In the future, it will be possible to save it directly to a file. `Valentine.Doc` currently parses objects with a single `Object[]` argument

```vala
var doc = new Valentine.Doc ();
string output = doc.build_from_array ({new Object (), new Object ()});
```

## Features

Support for property types:

- [x] Integers
- [x] Booleans
- [x] Strings
- [ ] Chars
- [ ] Objects (Maybe also an option to not parse objects?)
- [ ] UChars
- [ ] Longs
- [ ] DateTimes
- [ ] Files
- [x] Uint
- [ ] Floats
- [ ] Doubles
- [ ] Variants
- [x] Flags
- [x] Enums
- [x] Possibility to add user defined functions to parse other types (such as custom classes)

Other features:

- [ ] Save directly to a file
- [ ] Parse CSV file and create an object with an expected type
- [ ] Parse non-object classes by default
- [ ] Option to skip some properties from being written in the CSV file
