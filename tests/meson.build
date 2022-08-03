valentine_tests = [
  'custom_types',
  'file',
  'basic_types',
  'write_mode',
  'deserializer'
]

test_dependencies = [
  dependency('libadwaita-1'),
  valentine_dep
]

foreach name : valentine_tests
  test (name, executable (name + '-test', name + '-test.vala', dependencies: test_dependencies), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach

subdir ('Serializer')
subdir ('Deserializer')
# subdir ('Performance')