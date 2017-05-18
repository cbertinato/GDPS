import numpy as np
from matrix import quatmultiply, quat2DCM, DCM2quat
from numpy.linalg import norm, inv

_mGal = np.float64(10e-5) # 1 mGal = 10^-5 m/s^2

# Semi-major axis
a = np.float64(6378137) # m

# Semi-minor axis
b = np.float64(6356752.3141) # m

# Flattening
f = (a - b) / a

# Earth rate of rotation
wE = np.float64(7292115e-11) # rad/s

# Equatorial gravity
gE = np.float64(9.7803267715) # m/s^2
gE_mGal = gE / _mGal

# Polar gravity
gP = np.float64(9.8321863685) # m/s^2

# Eccentricity squared
e2 = np.float64(0.00669438002290)


def CN(phi):
    return a / (np.sqrt(1 - e2 * (np.sin(np.deg2rad(phi)))**2))

def CM(phi):
    return a * (1 - e2) / ((1 - e2 * (np.sin(np.deg2rad(phi)))**2)**(3/2))

def RN(phi, h):
    return CN(phi) + h

def RE(phi, h):
    return CM(phi) + h

""" velocity in n-frame (NED) """
def v_NED(phi, lam, h):
    vN = (CM(phi) + h) * np.gradient(phi)
    vE = (CN(phi) + h) * np.cos(np.deg2rad(phi)) * np.gradient(lam)
    vD = -np.gradient(h)
    return np.array([vN, vE, vD])

""" angular velocity of n-frame wrt e-frame, in n-frame coordinates """
def _omega_n_en(v, phi, h):
    return np.array([v[1] / RE(phi, h),
                    -v[0] / RN(phi, h),
                    -v[1] * np.tan(np.deg2rad(phi)) / RE(phi, h)])

""" angular velocity of e-frame wrt i-frame, in n-frame coordinates """
def _omega_n_ie(phi):
    return wE * np.array([np.cos(np.deg2rad(phi)),
                         0,
                         -np.sin(np.deg2rad(phi))])

""" angular velocity update """
def _omega_update(wm, b, phi, h, v):
    wnEN = _omega_n_en(v, phi, h)
    wnIE = _omega_n_ie(phi)
    return wm - b - (wnIE + wnEN)

""" quaternion update """
def _q_update(q, wk, dt):
    x = wk * dt
    xnorm = norm(x)
    z = np.sin(0.5 * xnorm) * x / xnorm
    dq = np.array([np.cos(0.5 * xnorm)] + z.tolist())
    return quatmultiply(q, dq)

""" Coriolis acceleration """
def _a_Cor(v, phi, h):
    wnIE = _omega_n_ie(phi)
    wnEN = _omega_n_en(v, phi, h)
    return np.cross(-(2*wnIE + wnEN), v)

""" acceleration update """
def _f_update(qk, fm, b):
    C = quat2DCM(qk)
    return C * (fm - b)

def _gamma0(phi):
    return gE * (1 + 0.0052790414 * np.sin(phi)**2 +
                 2.32718 * 10e-5 * np.sin(phi)**4 +
                 1.262 * 10e-7 * np.sin(phi)**6 +
                 7 * 10e-10 * np.sin(phi)**8)

def _gamma(phi, h):
    return _gamma0(phi) - (0.30877 - 4.3 * 10e-4 * np.sin(phi)**2) * h + \
            7.2 * 10e-8 * h**2

""" gravity update """
def _g_update(phi, h, dg):
    return _gamma(phi, h) + dg

""" velocity update """
def _v_update(qk, fm, b, g, v, phi, h, dt):
    fk = _f_update(qk, fm, b)
    aCor = _a_Cor(v, phi, h)
    return v + (fk + g + aCor) * dt

""" latitude update """
def _phi_update(phi, v, vk, h, dt):
    return phi + 0.5 * (v[0] + vk[0]) * dt / RN(phi,h)

""" longitude update """
def _lam_update(lam, phi, phik, v, vk, h, dt):
    return lam + 0.5 * (v[1] + vk[1]) * dt / (RE(phi, h) * np.cos(phik))

""" height update """
def _h_update(h, v, vk, dt):
    return h - 0.5 * (v[2] - vk[2]) * dt

""" full navigation update """
def nav_update(g, w, q, v, phi, lam, h, wm, fm, dg, b, dt):
    gk = _g_update(phi, h, dg)
    wk = _omega_update(wm, b, phi, h, v)
    qk = _q_update(q, wk, dt)
    vk = _v_update(qk, fm, b, g, v, phi, h, dt)
    phik = _phi_update(phi, v, vk, h, dt)
    lamk = _lam_update(lam, phik, v, vk, h, dt)
    hk = _h_update(h, v, dt)

    return gk, wk, qk, vk, phik, lamk, hk

def _determine_static(pos, v_threshold, t_threshold):
    # assumes that ENU velocities are present in the dataframe

    # create dataframe with same index as pos
    # 'static' column indicates when epochs fall below the velocity threshold
    static = pos.apply(lambda x: np.sqrt(x['ve']**2 + x['vn']**2 + x['vd']**2)
                       < v_threshold, axis=1).to_frame()
    static.columns = ['static']

    # create column that indicates blocks of consecutive static epochs
    static['block'] = (static.static.shift(1) != static.static).astype(int).cumsum()

    # group consecutive epochs
    test = static.reset_index().groupby(['static','block'])['index'].apply(np.array)[1]

    # pick out static periods that are longer than the time threshold
    t_threshold = t_threshold / 0.1
    test = test.loc[test.apply(lambda x: len(x) >= t_threshold)]

    # return the first and last static periods
    pre_static = test[min(test.index)][0:t_threshold]
    post_static = test[max(test.index)][0:t_threshold]

    return (pre_static[0], pre_static[-1]), (post_static[0], post_static[-1])

def _coarse_align(static, imu, pos):
    w = np.array(imu[['gx', 'gy', 'gz']][static[0]:static[1]].mean())
    a = np.array(imu[['ax', 'ay', 'az']][static[0]:static[1]].mean())
    lat = np.deg2rad(pos[static[0]:static[1]]['lat'].mean())
    lon = np.deg2rad(pos[static[0]:static[1]]['lon'].mean())
    h = pos['h'][static[0]:static[1]].mean()
    v = np.array(pos[['vn', 've', 'vd']][static[0]:static[1]].mean())

    g = norm(a)

    M = inv(np.array([[0, 0, -g],
                     [wE * np.cos(lat), 0, -wE * np.sin(lat)],
                     [0, g * wE * np.cos(lat), 0]]))

    x = np.column_stack((a, w, np.cross(-a, w))).T
    C = np.dot(M, x)

    q = DCM2quat(C)

    return g, q, w, a, lat, lon, h, v
