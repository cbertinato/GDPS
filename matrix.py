import numpy as np

ENU2NED = np.array([[0, 1, 0],
                    [1, 0, 0],
                    [0, 0, -1]])

def skew(v):
    return np.asarray([[0, -v(2), v(1)], [v(2), 0, -v(0)], [-v(1), v(0), 0]])

def quat2DCM(q):
    # TO DO: Check q shape
    C11 = q[0]**2 + q[1]**2 - q[2]**2 - q[3]**2
    C12 = 2*(q[1]*q[2] + q[0]*q[3])
    C13 = 2*(q[1]*q[3] - q[0]*q[2])
    C21 = 2*(q[1]*q[2] - q[0]*q[3])
    C22 = q[0]**2 - q[1]**2 + q[2]**2 - q[3]**2
    C23 = 2*(q[2]*q[3] + q[0]*q[1])
    C31 = 2*(q[1]*q[3] + q[0]*q[2])
    C32 = 2*(q[2]*q[3] - q[0]*q[1])
    C33 = q[0]**2 - q[1]**2 - q[2]**2 + q[3]**2

    return np.array([[C11, C12, C13], [C21, C22, C23], [C31, C32, C33]])

def quatmultiply(r, q):
    a = np.array([r[0]*q[0] - np.dot(r[1:4], q[1:4])])
    b = r[0]*q[1:4] + q[0]*r[1:4] + np.cross(r[1:4], q[1:4])
    return np.concatenate((a, b))

def DCM2ypr(C, units='rad'):
    if units == 'deg':
        conv = 180 / np.pi
    else:
        conv = 1

    r = np.arctan(C[1][2] / C[2][2]) * conv
    p = -np.arcsin(C[0][2]) * conv
    y = np.arctan(C[0][1] / C[0][0]) * conv

    return np.array([y, p, r])

def DCM2quat(C):
    q0 = 0.5 * np.sqrt(C[0][0] + C[1][1] + C[2][2] + 1)
    q1 = 0.25 * (C[1][2] - C[2][1]) / q0
    q2 = 0.25 * (C[2][0] - C[0][2]) / q0
    q3 = 0.25 * (C[0][1] - C[1][0]) / q0
    return np.array([q0, q1, q2, q3])
