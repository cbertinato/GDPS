# preprocess.py

import numpy as np
import pandas as pd
import scipy.signal as signal
import datetime
from timeutils import convert_to_utc

""" @brief Applies an FIR low-pass filter designed with a Blackman window.
    @param x Array of data to be filtered (array_like).
    @param Fs Sample frequency in Hz.
    @param filter_len Filter length in seconds.
    @return Filtered output with same shape as x (ndarray).
"""
def lp_filter(x, Fs, filter_len):
    # TO DO: Phase delay?
    # TO DO: Check x type.

    if not isinstance(x, pd.Series) or not isinstance(x, pd.DataFrame):
        print "Input data set must be type Series or DataFrame"
        return

    # cutoff frequency in Hz
    Fc = 1.0/filter_len

    # Nyquist frequency
    Ny = Fs/2.0

    # cutoff frequency in units of the Nyquist frequency
    Wn = Fc/Ny

    # filter order
    N = 2.0 * filter_len * Fs

    # design filter
    taps = signal.firwin(N, Wn, window='blackman')

    # apply filter
    filtered_x = signal.filtfilt(taps, 1.0, x)

    return filtered_x

def nan_helper(y):
    """Helper to handle indices and logical indices of NaNs.

    Input:
        - y, 1d numpy array or pandas Series with possible NaNs.
    Output:
        - nans, logical indices of NaNs.
        - index, a function with signature indices = index(logical_indices),
            to convert logical indices of NaNs to 'equivalent' indices.
    """

    return np.isnan(y), lambda z: z.nonzero()[0]

def interp_nans(y):
    nans, x = nan_helper(y)
    y[nans] = np.interp(x(nans), x(~nans), y[~nans])

def unbiased_pf(df):
    print "unbiased_pf"

def fill_NaNs(df):
    print "fill_NaNs"

    # construct unbiased prediction filter
    # convert to prediction error filter
    # determine begin and end of all gaps
    # setup computation windows

# REVIEW
def standardize(self, data):
# Transforms input data set into one with zero mean and unit variance.
# Z-score scaling method.
	mean = np.mean(data)
	std = np.std(data)

	if np.max(data) - np.min(data) != 0:
		# standardize
		reduced = (data - mean) / std

        # detrend
		reduced = signal.detrend(reduced)

	else:
		reduced = data - mean

	return reduced

# OBSOLETE?
def gps_leapsecond(dt):
    # dt = datetime.datetime(1980,1,6) + datetime.timedelta(weeks=wk)

    ls_table = [(1980,1,1,1981,7,1),\
                (1981,7,1,1982,7,1),\
                (1982,7,1,1983,7,1),\
                (1983,7,1,1985,7,1),\
                (1985,7,1,1988,1,1),\
                (1988,1,1,1990,1,1),\
                (1990,1,1,1991,1,1),\
                (1991,1,1,1992,7,1),\
                (1992,7,1,1993,7,1),\
                (1993,7,1,1994,7,1),\
                (1994,7,1,1996,1,1),\
                (1996,1,1,1997,7,1),\
                (1997,7,1,1999,1,1),\
                (1999,1,1,2006,1,1),\
                (2006,1,1,2009,1,1),\
                (2009,1,1,2012,7,1),\
                (2012,7,1,2015,7,1),\
                (2015,7,1,2017,1,1)]

    leap_seconds = 0
    for entry in ls_table:
        if dt >= datetime.datetime(entry[0],entry[1],entry[2]) and dt < datetime.datetime(entry[3],entry[4],entry[5]):
            break
        else:
            leap_seconds = leap_seconds + 1

    return leap_seconds

# REVIEW
def gps_to_utc(week_num, seconds_of_week, df=None):
    if isinstance(week_num, pd.Series) and isinstance(seconds_of_week, pd.Series):
        dt_list = []

        for (wk,sow) in zip(week_num, seconds_of_week):
            dt_list.append(convert_to_utc(sow, week=wk))

        return pd.DatetimeIndex(dt_list)

    # operating on the class instance dataframe
    elif isinstance(week_num, basestring) and isinstance(seconds_of_week, basestring):
        dt_list = []

        if df is None:
            print "Dataframe required for basestring argument type."
            return

        for index, row in df.iterrows():
            dt_list.append(convert_to_utc(row[seconds_of_week], week=row[week_num]))

        return pd.DatetimeIndex(dt_list)

    else:
        return convert_to_utc(seconds_of_week, week=week_num)

def message(text):
    st = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    print '[' + st + '] ' + text
