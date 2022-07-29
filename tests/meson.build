valentine_tests = [
  'custom_types',
  'flags',
  'file',
  'variant',
  'datetime',
  'basic_types',
  'write_mode',
  'adw_flap',
  'performance',
  'string_array',
  'deserializer'
]

test_dependencies = [
  dependency('libadwaita-1'),
  valentine_dep
]

foreach name : valentine_tests
  test (name, executable (name + '-test', name + '-test.vala', dependencies: test_dependencies), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach