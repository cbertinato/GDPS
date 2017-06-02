import numpy as np
from struct import unpack
import pandas as pd
import datetime
import timeutils
from matrix import ENU2NED
from fileutils import unpack_to_dict, store_as_HDF
from collections import defaultdict

version_metadata = {'description': 'Program version number (e.g., 8.60).',
                     'type': 'double',
                     'value': None}

delta_theta_metadata = {'description': ('Default is 1, which indicates that data to follow will '
                                        'delta theta, meaning angular increments (i.e., scale and '
                                        'divide by data_rate to get degrees/second). If the flag '
                                        'is set to 0, then the data will be read directly as '
                                        'scaled angular rates.'),
                        'type': 'int',
                        'value': None}

delta_v_metadata = {'description': ('Default is 1, which indicates the data to follow will be '
                                    'delta v\'s, meaning velocity increments (i.e., scale and '
                                    'divide by data_rate to get m/s^2). If the flag is set to '
                                    '0, then the data will be read directly as scaled '
                                    'accelerations.'),
                    'type': 'int',
                    'value': None}

data_rate_metadata = {'description': 'i.e., 100.0 records/second.',
                      'type': 'double',
                      'value': None}

gyro_scale_factor_metadata = {'description': ('Scale (multiply) the gyro measurements by this to '
                                              'get degrees/second if delta_theta = 0. Scale the '
                                              'gyros by this to get degrees if delta_theta = 1. '
                                              'The default behavior is to store the gyro data in '
                                              '0.01 arcsec or 0.01 arcsec/sec increments so that '
                                              'GYRO_SCALE = 360000.'),
                               'type': 'double',
                               'value': None}

accel_scale_factor_metadata = {'description': ('Scale (multiply) the accel measurements by this '
                                               'to get m/s^2 if delta_v = 0. Scale the accels by '
                                               'this to get m/s if delta_v = 1. The default '
                                               'behavior is to store the accel data in 1e-6 m/s '
                                               'or 1e-6 m/s^2 increments so that '
                                               'ACCEL_SCALE = 1000000.'),
                            'type': 'double',
                            'value': None}

utc_or_gps_time_metadata =  {'description': ('Defines the time tags as being in UTC or GPS. '
                                             '0 - Unknown (default is GPS), 1 - UTC, 2 - GPS.'),
                             'type': 'int',
                             'value': None}

rcv_time_or_corr_time_metadata = {'description': ('Defines whether the GPS time tags are on the '
                                                 'nominal top of the second or are corrected for '
                                                 'receiver time bias. 0 - do to know (default is '
                                                 'corrected time), 1 - receive time on the '
                                                 'nominal top of the epoch, 2 - corrected '
                                                 'time, i.e., corr_time = rcv_time - rcvr_clock_bias'),
                              'type': 'int',
                              'value': None}

time_tag_bias_metadata = {'description': ('Default is 0.0, but if you have a known '
                                          'millisecond-level bias in your GPS->INS time tags, '
                                          'then enter it here.'),
                          'type': 'double',
                          'value': None}

imu_name_metadata = {'description': 'Name or type of the inertial measurement unit.',
                     'type': 'char[32]',
                     'value': None}

reserved_metadata = {'description': 'Reserved for future use. Bytes should be zeroed.',
                     'type': 'char[354]',
                     'value': None}

program_name_metadata = {'description': 'Name of program that created the IMR file.',
                         'type': 'char[32]',
                         'value': None}

creation_time_metadata = {'description': 'Creation time.',
                          'type': 'char[12]',
                          'value': None}

lever_arm_valid_metadata = {'description': ('Set to true if the lever arm values are valid. '
                                            'Lever arm is from IMU to GPS phase center.'),
                            'type': 'bool',
                            'value': None}

x_lever_arm_metadata = {'description': 'X value of lever arm in millimeters.',
                        'type': 'long',
                        'value': None}

y_lever_arm_metadata = {'description': 'Y value of lever arm in millimeters.',
                        'type': 'long',
                        'value': None}

z_lever_arm_metadata = {'description': 'Z value of lever arm in millimeters.',
                        'type': 'long',
                        'value': None}

dir_valid_metadata = {'description': '',
                      'type': 'bool',
                      'value': None}

dir_x_metadata = {'description': '',
                  'type': 'uchar',
                  'value': None}

dir_y_metadata = {'description': '',
                  'type': 'uchar',
                  'value': None}

dir_z_metadata = {'description': '',
                  'type': 'uchar',
                  'value': None}
header = dict()
header['version'] = version_metadata
header['delta_theta'] = delta_theta_metadata
header['delta_v'] = delta_v_metadata
header['data_rate'] = data_rate_metadata
header['gyro_scale_factor'] = gyro_scale_factor_metadata
header['accel_scale_factor'] = accel_scale_factor_metadata
header['utc_or_gps_time'] = utc_or_gps_time_metadata
header['rcv_time_or_corr_time'] = rcv_time_or_corr_time_metadata
header['time_tag_bias'] = time_tag_bias_metadata
header['imu_name'] = imu_name_metadata
header['dir_valid'] = dir_valid_metadata
header['dir_x'] = dir_x_metadata
header['dir_y'] = dir_y_metadata
header['dir_z'] = dir_z_metadata
header['program_name'] = program_name_metadata
header['creation_time'] = creation_time_metadata
header['lever_arm_valid'] = lever_arm_valid_metadata
header['x_lever_arm'] = x_lever_arm_metadata
header['y_lever_arm'] = y_lever_arm_metadata
header['z_lever_arm'] = z_lever_arm_metadata
header['reserved'] = reserved_metadata

imr_sig = '$IMURAW\0'
fmt_string = 'dIIdddIId32s?BBB32s12s?lll354s'

def convert_imr_to_HDF(imrpath, begin_date, hdfpath):
    attributes, dataframe = import_imr(imrpath, begin_date, raw=True)
    store_as_HDF(dataframe, hdfpath, attr=attributes)

def import_imr(fname, begin_date, input_ref_frame='NED', raw=False):
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

        # TO DO: Refashion all of this header stuff into something less ugly.
        header_fields = ['version', 'delta_theta', 'delta_v', 'data_rate',
                         'gyro_scale_factor', 'accel_scale_factor',
                         'utc_or_gps_time', 'rcv_time_or_corr_time',
                         'time_tag_bias', 'imu_name', 'dir_valid', 'dir_x',
                         'dir_y', 'dir_z', 'program_name', 'creation_time',
                         'lever_arm_valid', 'x_lever_arm', 'y_lever_arm',
                         'z_lever_arm', 'reserved']

        header_vals = unpack_to_dict(header_fields, fmt, f.read(503))
        for k, v in header_vals.iteritems():
            header[k]['value'] = v

        data_types = {'ax': 'int32', 'ay': 'int32', 'az': 'int32',
                      'gx': 'int32', 'gy': 'int32', 'gz': 'int32'}
        metadata = {'header': header, 'data': data_types}

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
        if raw:
            metadata = {'header': header, 'data_types': data_types}
            return metadata, df
        else:
            # scale data
            if header['delta_theta']['value'] == 1:
                # default value; data given as angular increments
                ang_rate = ((df[['gx','gy','gz']] * np.float64(header['gyro_scale_factor']['value']))
                            / header['data_rate']) * np.pi / 180
            elif header['delta_theta']['value'] == 0:
                # data given as angular rate in arcsec/s
                ang_rate = (df[['gx','gy','gz']] * np.float64(header['gyro_scale_factor']['value'])
                            * np.pi / 180)
            else:
                print "Invalid value for delta_theta"
                return

            if header['delta_v']['value'] == 1:
                # default value; data given as velocity increments
                accel = ((df[['ax','ay','az']] * np.float64(header['accel_scale_factor']['value']))
                            / header['data_rate'])
            elif header['delta_v']['value'] == 0:
                # data given as accelerations in m/s^2
                accel = (df[['ax','ay','az']] * np.float64(header['accel_scale_factor']['value']))
            else:
                print "Invalid value for delta_v"
                return

            # transform to NED frame if given in ENU
            if input_ref_frame == 'ENU':
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
