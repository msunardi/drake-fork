add_executable(gravity_compensator_test gravity_compensator_test.cc)
target_link_libraries(gravity_compensator_test
    drakeSystemControllers
    drakeSystemFramework
    drakeRBSystem GTest::GTest GTest::Main)
drake_add_test(NAME gravity_compensator_test COMMAND gravity_compensator_test)

drake_add_cc_test(pid_controlled_system_test pid_controlled_system_test.cc)
target_link_libraries(pid_controlled_system_test
    drakeSystemControllers
    drakeSystemFramework)

drake_add_cc_test(pid_controller_test)
target_link_libraries(pid_controller_test drakeSystemControllers drakeSystemFramework)

drake_add_cc_test(linear_quadratic_regulator_test linear_quadratic_regulator_test.cc)
target_link_libraries(linear_quadratic_regulator_test drakeLinearControl)
