import numpy as np
from struct import *
import pandas as pd
import datetime
import timeutils
from matrix import ENU2NED

imr_sig = '$IMURAW\0'
fmt_string = 'dIIdddIId32s?BBB32s12s?lll354s'

def import_imr(fname, begin_date, ref_frame='NED'):
# NOTE: iMAR data is exported to imr format in ENU frame

    if isinstance(begin_date, basestring):
        s = begin_date.split('_')
        if len(s) != 3:
            print 'begin_date not correctly formatted. expect MM-DD-YYYY'
            return

        date = datetime.datetime(s[2], s[0], s[1])
    elif isinstance(begin_date, datetime.datetime):
        date = begin_date
    else:
        print('incorrect type for begin_date. expect string '
              'or datetime.datetime')
        return

    '''
    The imr header is 512 bytes long. We read the first 9 bytes which are
    the signature and endianness indicator. Then we read the rest of the
    509 bytes of the header.
    '''
    with open(fname, 'rb') as f:
        # check imr signature
        sig = f.read(8)
        if sig != imr_sig:
            print 'Invalid imr signature'
            return

        # determine endianness
        endianness = ord(f.read(1))

        if endianness == 0:
            fmt = '<' + fmt_string
            # print 'Detected little endian byte order'
        elif endianness == 1:
            fmt = '>' + fmt_string
            # print 'Detected big endian byte order'
        else:
            print 'Invalid endianness value'
            return

        # read rest of header
        (version, delta_theta, delta_v, data_rate, gyro_scale_factor,
        accel_scale_factor, utc_or_gps_time, rcv_time_or_corr_time,
        time_tag_bias, imu_name, dir_valid, dir_x, dir_y, dir_z, program_name,
        creation_time, lever_arm_valud, x_lever_arm, y_lever_arm, z_lever_arm,
        reserved) = unpack(fmt, f.read(503))

        # read data
        dtype = np.dtype([('time', 'double'),('gx', 'int32'),('gy', 'int32'),
            ('gz', 'int32'), ('ax', 'int32'), ('ay', 'int32'), ('az', 'int32')])

        data = np.fromfile(f, dtype=dtype)

        # create dataframe
        df = pd.DataFrame(data, columns=data.dtype.names)

        # convert from utc to gps time?
        # if utc_or_gps_time == 2 or utc_or_gps_time == 0:
        #     is_utc = False
        # elif utc_or_gps_time == 1:
        #     is_utc = True

        # shift datetime to beginning of week
        # GPS weekday: Sunday = 0, Saturday = 6
        # datetime weekday(): Monday = 0, Sunday = 6
        # datetime isoweekday(): Monday = 1, Sunday = 7
        begin_week = date - datetime.timedelta(days=date.isoweekday())
        fr = pd.to_timedelta(df['time'][0], unit='s')
        if date.isoweekday() != (begin_week + fr).isoweekday():
            print("WARNING: begin_date day of week is not the same as that "
                  "for first timestamp (first: {first}, expected: {given})"
                  .format(first=(begin+fr).isoweekday(),
                          given=date.isoweekday()))

        df.index = begin_week + pd.to_timedelta(df['time'], unit='s')

        # scale data
        if delta_theta == 1:
            # default value; data given as angular increments
            ang_rate = ((df[['gx','gy','gz']] * np.float64(gyro_scale_factor))
                        / data_rate) * np.pi / 180
        elif delta_theta == 0:
            # data given as angular rate in arcsec/s
            ang_rate = (df[['gx','gy','gz']] * np.float64(gyro_scale_factor)
                        * np.pi / 180)
        else:
            print "Invalid value for delta_theta"
            return

        if delta_v == 1:
            # default value; data given as velocity increments
            accel = ((df[['ax','ay','az']] * np.float64(accel_scale_factor))
                        / data_rate)
        elif delta_v == 0:
            # data given as accelerations in m/s^2
            accel = (df[['ax','ay','az']] * np.float64(accel_scale_factor))
        else:
            print "Invalid value for delta_v"
            return

        # transform to NED frame if given in ENU
        if ref_frame == 'ENU':
            ang_rate_col = ang_rate.columns
            ang_rate = ang_rate.dot(ENU2NED)
            ang_rate.columns = ang_rate_col

            accel_col = accel.columns
            accel = accel.dot(ENU2NED)
            accel.columns = accel_col

    return pd.concat([ang_rate, accel], axis=1).resample('4000U').mean()

def import_gps(fname, ref_frame='ENU'):
    df = pd.read_csv(fname, delim_whitespace=True, header=None, engine='c',
                      na_filter=False, skiprows=17)

    df.columns = ['GPS_sow', 'GPS_week', 'GPS_hms', 'GPS_date', 'lat', 'lon',
                  'h', 'vn', 've', 'vu']

    df.index = pd.to_datetime(df['GPS_date'] + df['GPS_hms'],
                              format="%m/%d/%Y%H:%M:%S.%f")

    df = df.drop(['GPS_sow', 'GPS_week', 'GPS_hms', 'GPS_date'], axis=1)

    # transform to NED frame if given in ENU
    if ref_frame == 'ENU':
        v = df[['ve', 'vn', 'vu']].dot(ENU2NED)
        v.columns = ['vn', 've', 'vd']
        df = df.drop(['ve', 'vn', 'vu'], axis=1)
        df = pd.concat([df, v], axis=1)

    return df
