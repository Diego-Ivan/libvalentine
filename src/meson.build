conf = configuration_data()
conf.set('prefix', get_option('prefix'))
conf.set('libdir', get_option ('libdir'))
conf.set('PROJECT_NAME', 'libvalentine')
conf.set('PROJECT_VERSION', meson.project_version ())
conf.set('API_VERSION', API_VERSION)

sources = files([
  'AbstractWriter.vala',
  'enums.vala',
  'delegates.vala',
  'ObjectDeserializer.vala',
  'ObjectSerializer.vala',
  'SerializerLine.vala',
  'Deserializer.vala',
  'DeserializerLine.vala',
  'Parser.vala',
  'structs.vala',
  'TypeParser.vala',
  ])

libvalentine = library('libvalentine-' + API_VERSION,
  sources,
  vala_header: 'libvalentine.h',
  vala_vapi: 'libvalentine-' + API_VERSION + '.vapi',
  vala_gir: 'Valentine-' + API_VERSION + '.gir',
  dependencies : dependencies,
  vala_args: [
    '--abi-stability'
    ],
  install: true,
  install_dir: [
    true,
    get_option('includedir') / 'libvalentine-' + API_VERSION / 'libvalentine',
    vapidir,
    g_ir_compiler.found()
  ]
)

valentine_dep = declare_dependency(
  link_with: libvalentine,
  dependencies: dependencies,
  include_directories: [include_directories('.')],
)

if g_ir_compiler.found()
  custom_target('libvalentine-typelib',
    command: [
      g_ir_compiler,
      '--shared-library', 'libvalentine-@0@.so'.format (API_VERSION),
      '--output', '@OUTPUT@',
      meson.current_build_dir() / 'Valentine-' + API_VERSION + '.gir'
    ],
    output: 'Valentine-' + API_VERSION + '.typelib',
    depends: libvalentine,
    install: true,
    install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
endif

pkgconfig.generate(libvalentine,
  subdirs: 'libvalentine-' + API_VERSION,
  version: API_VERSION,
  name: 'libvalentine',
  filebase: 'libvalentine-' + API_VERSION,
  requires: PKGCONFIG_DEPS,
  description: 'A small library to manipulate CSV files')

if get_option('enable_valadoc')
  valadoc = find_program('valadoc')
  libvalentine_docs = custom_target('libvalentine_apidocs',
    input: sources,
    install: true,
    # FIXME: Installing to tmp, so the target will be built
    #        the problem is we cannot access a subfolder of the
    #        buildtarget via the output parameter.
    #        Find a nicer solution
    install_dir: get_option('datadir') / 'devhelp' / 'books',
    command: [
      valadoc,
      '--pkg=glib-2.0',
      '--pkg=gobject-2.0',
      '--pkg=gio-2.0',
      '--pkg=gee-0.8',
      '-o', meson.current_build_dir() / 'Valentine-' + API_VERSION,
      '--doclet',
      'devhelp',
      '@INPUT@',
      '--force'
    ],
    output: 'Valentine-' + API_VERSION)

  install_subdir(meson.current_build_dir() / 'Valentine-' + API_VERSION / 'Valentine-' + API_VERSION,
    install_dir: get_option('datadir') / 'devhelp' / 'books')
endif
