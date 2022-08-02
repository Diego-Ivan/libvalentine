performance_tests = [
  'deserializer',
  'serializer'
]

performance_dependencies = [
  valentine_dep
]

foreach name : performance_tests
  test (name, executable (name + '-performance-test', name + '-performance-test.vala', dependencies: performance_dependencies), env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
endforeach