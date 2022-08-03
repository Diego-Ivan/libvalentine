deserializer_tests = [
  'basic_types',
  'custom_types',
  'datetime',
  'file',
  'flags',
  # 'string_array',
  # 'variant',
]

test_dependencies = [
  dependency('libadwaita-1'),
  valentine_dep
]

foreach name : deserializer_tests
  test (name, executable (name + '-test', name + '-test.vala', dependencies: test_dependencies), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach