import numpy as np
import pandas as pd
import scipy.signal as signal

""" @brief Applies an FIR low-pass filter designed with a Blackman window.
    @param x Array of data to be filtered (array_like).
    @param Fs Sample frequency in Hz.
    @param filter_len Filter length in seconds.
    @return Filtered output with same shape as x (ndarray).
"""
def lp_filter(x, Fs, filter_len):
    # TO DO: Phase delay?

    Fc = 1.0/filter_len
    Ny = Fs/2.0
    Wn = Fc/Ny
    N = 2.0 * filter_len * Fs

    # design filter
    taps = signal.firwin(N, Wn, window='blackman')

    # apply filter
    filtered_x = signal.filtfilt(taps, 1.0, x)


def unbiased_pf(df):
    print "unbiased_pf"

def fill_NaNs(df):
    print "fill_NaNs"

    # construct unbiased prediction filter
    # convert to prediction error filter
    # determine begin and end of all gaps
    # setup computation windows

# NEEDS REVIEW
def standardize(self, data):
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

# NEEDS REVIEW
def gps_to_utc(self, week_num, seconds_of_week, df=None):

    def convert_to_utc(wk, sow):
        dt = datetime.datetime(1980,1,6) + datetime.timedelta(weeks=wk)

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

        sow = sow - leap_seconds
        dt = dt + datetime.timedelta(seconds=sow)

        return dt

    if isinstance(week_num, pd.Series) and isinstance(seconds_of_week, pd.Series):
        dt_list = []

        for (wk,sow) in zip(week_num, seconds_of_week):
            dt_list.append(convert_to_utc(wk, sow))

        return pd.DatetimeIndex(dt_list)

    # operating on the class instance dataframe
    elif isinstance(week_num, basestring) and isinstance(seconds_of_week, basestring):
        dt_list = []

        if df is None:
            print "Dataframe required for basestring argument type."
            return

        for index, row in df.iterrows():
            dt_list.append(convert_to_utc(row[week_num], row[seconds_of_week]))

        return pd.DatetimeIndex(dt_list)

    else:
        return convert_to_utc(week_num, seconds_of_week)
