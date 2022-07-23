valentine_tests = [
  'custom_types',
  'flags',
]

foreach name : valentine_tests
  test (name, executable (name + '-test', name + '-test.vala', dependencies: valentine_dep), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach