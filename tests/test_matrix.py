from nose.tools import *
import numpy as np
import matrix

def test_quat_mult():
    q = np.array([1, 0, 1, 0])
    r = np.array([1, 0.5, 0.5, 0.75])
    got = matrix.quatmultiply(q, r)
    expect = np.array([0.5, 1.25, 1.5, 0.25])

    np.testing.assert_array_almost_equal(got, expect, decimal=8)

def test_quat2DCM():
    q = np.array([0.961798, -0.14565, 0.202665, 0.112505])
    expect = np.array([[0.89253884, 0.15737785, -0.42261829],
                       [-0.27545048, 0.9322572, -0.23457011],
                       [0.35707288, 0.32577341, 0.87542574]])
    got = matrix.quat2DCM(q)

    np.testing.assert_array_almost_equal(got, expect, decimal=8)

def test_DCM2quat():
    C = np.array([[0.892539, 0.157379, -0.422618],
                  [-0.275451, 0.932257, -0.234570],
                  [0.357073, 0.325773, 0.875426]])

    got = matrix.DCM2quat(C)
    expect = np.array([0.96179806, -0.14564986, 0.20266494, 0.11250543])

    np.testing.assert_array_almost_equal(got, expect, decimal=8)

def test_DCM2ypr():
    C = np.array([[0.303372, -0.0049418, 0.952859],
                  [-0.935315, 0.1895340, 0.298769],
                  [-0.182075, -0.9818620, 0.052877]])
    got = matrix.DCM2ypr(C, units='deg')
    expect = np.array([-0.93324118, -72.33726086, 79.96355666])

    np.testing.assert_array_almost_equal(got, expect, decimal=8)
