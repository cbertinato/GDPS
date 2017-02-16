# gravity.py module

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from ConfigParser import SafeConfigParser
import datetime
import os
import re
import fnmatch
import preprocess as pp

class Gravity:
	# TO DO: Setup exceptions for this class.

	# Class attributes

	# WGS-84

	# Semi-major axis
	_a = np.float64(6378137) # m

	# Semi-minor axis
	_b = np.float64(6356752.3141) # m

	# Flattening
	_f = (_a - _b) / _a

	# Earth rate of rotation
	_w = np.float64(7292115e-11) # rad/s

	# Equatorial gravity
	_gE = np.float64(9.7803267715) # m/s^2

	# Polar gravity
	_gP = np.float64(9.8321863685) # m/s^2

	# Eccentricity squared
	_e2 = np.float64(0.00669438002290)

	_mGal = np.float64(10e-5) # 1 mGal = 10^-5 m/s^2

	# ZLS
	_kF = np.float64(0.9899) # S-80 gravity meter scale factor
	_kB = np.float64(30) # mGal * m/V (S-80 beam derivative factor at 1 Hz)
	_kCA = np.float64(25.110) # mGal * m/V (S-80 cross accel scale factor)
	_kLA = np.float64(26.483) # mGal * m/V (S-80 long accel scale factor)

	_zls_file_format = {'line_name':10, 'gravity':8, 'spring_tension':8, \
		'cross_coupling':7, 'raw_beam':8, 'vcc':8, 'al':8, 'ax':8, 've2':8, 'ax2':8, \
		'xacc2':8, 'lacc2':8, 'xacc':8, 'lacc':8, 'par_port':8, 'platform_per':6}

	def __init__(self):

		# Conversion and calibration factors
		self.eD = np.float64(1.11585e5) # ?
		self.nD = np.float64(1.11369e5) # ?

		self.meter_model = None
		self.k_factor = None
		self.pre_static_reading = None
		self.post_static_reading = None
		self.gravity_tie = None

		# legacy
		self.time_shift = None
		self.filter_length = None
		self.filter_type = None

		# class instance dataframe
		self.df = None

	def read_DGS_meter_config(self, filepath):
		errors = []

		parser = SafeConfigParser()

		try:
			parser.read(filename)

		except OSError as why:
			errors.append(str(why))

		if not parser.has_section('Sensor'):
			print "Error: DGS config file missing Sensor section."
			return

		self.meter_model = parser.get('Sensor', 'Meter')
		self.k_factor = parser.get('Sensor', 'kfactor')

		# legacy
		self.time_shift = parser.get('Sensor', 'timeshift')
		self.filter_length = parser.get('Sensor', 'filtertime') # seconds
		self.filter_type = parser.get('Sensor', 'filtype')

		if not parser.has_section('Survey'):
			print "Error: DGS config file missing Survey section."
			return

		self.pre_static_reading = parser.get('Survey', 'PreStill')
		self.post_static_reading = parser.get('Survey', 'PostStill')
		self.gravity_tie = parser.get('Survey', 'TieGravity')

		if errors:
			raise Error(errors)

	# imports a single ZLS formatted file
	def read_ZLS_format_file(self, filepath):
		col_names = ['line_name', 'year', 'day', 'hour', 'minute', 'second',
						'gravity', 'spring_tension', 'cross_coupling',
						'raw_beam', 'vcc', 'al', 'ax', 've2', 'ax2', 'xacc2',
						'lacc2', 'xacc', 'lacc', 'par_port', 'platform_period']

		# not currently used
		col_subset = ['gravity', 'spring_tension', 'cross_coupling',
						'raw_beam', 'vcc', 'al', 'ax', 've2', 'ax2', 'xacc2',
						'lacc2', 'xacc', 'lacc', 'par_port', 'platform_period']

		col_widths = [10, 4, 3, 2, 2, 2, 8, 8, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
                        8, 6]

		time_columns = ['year','day','hour','minute','second']

		# read into dataframe
		df = pd.read_fwf(filepath, widths=col_widths, names=col_names)

		day_fmt = lambda x: '{:03d}'.format(x)
		time_fmt = lambda x: '{:02d}'.format(x)

		t = df['year'].map(str) + df['day'].map(day_fmt) + \
			df['hour'].map(time_fmt) + df['minute'].map(time_fmt) + \
			df['second'].map(time_fmt)

		# index by datetime
		df.index = pd.to_datetime(t, format='%Y%j%H%M%S')

		return df

	# parses ZLS file names into a datetime
	def parse_ZLS_file_name(self, filename):
		# split by underscore
		fname = [e.split('.') for e in filename.split('_')]

		# split hour from day and then flatten into one tuple
		b = [int(el) for fname_parts in fname for el in fname_parts]

		# generate datetime
		c = datetime.datetime(b[0], 1, 1) + datetime.timedelta(days=b[2]-1,
																hours=b[1])

		return c

	def import_ZLS_format_data(self, dirpath, begin_time=None, end_time=None,
								excludes=['.*']):

		if begin_time is not None and not isinstance(begin_time, datetime.datetime):
			print "Error: begin_time is not of type datetime."
			return

		if end_time is not None and not isinstance(end_time, datetime.datetime):
			print "Error: end_time is not of type datetime."
			return

		excludes = r'|'.join([fnmatch.translate(x) for x in excludes]) or r'$.'

		df = pd.DataFrame()

		# list files in directory
		files = [self.parse_ZLS_file_name(f) for f in os.listdir(dirpath)
                    if os.path.isfile(os.path.join(dirpath, f))
					if not re.match(excludes, f)]

		# sort files
		files = sorted(files)

		if begin_time is None and end_time is None:
			begin_time = files[0]
			end_time = files[-1]

		elif begin_time is None and end_time is not None:
			# validate end_time
			begin_time = files[0]
			if end_time < begin_time or end_time > files[-1]:
				print "Error: invalid end_time."
				return

		elif begin_time is not None and end_time is None:
			# validate begin_time
			end_time = files[-1]
			if begin_time > end_time or begin_time < files[0]:
				print "Error: invalid end_time."
				return

		# filter file list based on begin and end times
		files = filter(lambda x: x >= begin_time and x < end_time, files)

		# convert to file names
		files = [dt.strftime('%Y_%H.%j') for dt in files]

		for f in files:
			frame = self.read_ZLS_format_file(os.path.join(dirpath, f))
			df = pd.concat([df, frame])

		self.df = df

	def import_DGS_format_data(self, filepath, interval=0, filterdelay=0):
		# Read data
		self.df = pd.read_csv(filepath)

		# Label columns
		self.df.columns = ['Gravity','Long_accel', 'Cross_accel', \
                        'Beam', 'Sensor_temp', 'Status', 'Pressure', \
                        'E_temp', 'GPS_week', 'GPS_sow']

		# Index by datetime
		self.df.index =  pp.gps_to_utc('GPS_week', 'GPS_sow', self.df)

		# Check time interval
		# 	interval = 0 -> auto
		#	interval != 0 -> manual

		dt = (self.df.index[1] - self.df.index[0]).microseconds * 10**(-6)

		if interval == 0:
			print 'Interval auto-detect: {:.3f} seconds'.format(dt)

		else:
			if dt != interval:
				print 'Manual interval setting : Interval conflict : Detected {:d} second interval.'.format(dt)
				return

			dt = interval
			print 'Manual interval setting: {:d} seconds'.format(dt)

		# fill missing values with NaN
		# TO DO: Set resample frequency based on set interval.
		# NOTE: Assumes 10 Hz data.
		self.df = self.df.resample('100L')

		# Filter delay in seconds
		delay = filterdelay * dt

		# Apply filter delay
		self.df.index = self.df.index.shift(-delay, freq='S')

	def import_trajectory(self, filename, interval=0):

		# TO DO: Decimate if 200 Hz trajectory?
		df = pd.read_csv(filename)

		# Index by datetime
		df.index = pd.to_datetime(df['GPS Date'] + " " + df['GPS Time'])

		# Shift from GPS to UTC
		df.index = df.index.shift(-16, freq='S')

		# Check time interval
		# 	interval = 0 -> auto
		#	interval != 0 -> manual

		if interval == 0:
			dt = (df.index[1] - df.index[0]).seconds
		else:
			dt = interval

		# TO DO: Check for gaps and interpolate.
		# TO DO: Update to new trajectory file format.

		# Relabel columns
		df.columns = ['Date UTC','Time UTC','Lat', 'Lon', \
			'HEll', 'Num Sats', 'PDOP']

		return df

	################################

	def join_grav_traj(self, df1, df2):

		# print "Combining data sets."

		# Add position data to main dataframe
		df = pd.concat([df1, df2[df2.columns[2:]]], axis=1, join_axes=[df1.index])

		# Drop rows where there is no position data
		df = df[pd.notnull(df['Lat'])]

		return df

	################################

	def filter_gravity(self, df, window):

		print "Filtering gravity with a window of %d seconds." % window

		# Determine time interval
		dt = (df.index[1] - df.index[0]).seconds

		# Filter window in samples
		filterwindow = window / dt

		# Filter with moving average
		fieldname = 'Corr Gravity Filtered ' + str(window)
		df[fieldname] = pd.rolling_mean(df['Corr Gravity'], filterwindow)\

		return df

	################################

	def plot_grav_qc(self, df, lines):

		# setup pdf
		pp = PdfPages('multipage.pdf')

		# iterate through rows
		for index, row in lines.iterrows():

			lineID = row['Line_ID']
			startTime = row['Start_Time']
			endTime = row['End_Time']

			print lineID

			# extract subsets
			subset = df[pd.to_datetime(startTime) : pd.to_datetime(endTime)]

			statFormat = lambda x: '%15.2f' % x

			# compute statistics
			sensorMean = statFormat(subset['Gravity'].mean())
			sensorMin = statFormat(subset['Gravity'].min())
			sensorMax = statFormat(subset['Gravity'].max())
			sensorStd = statFormat(subset['Gravity'].std())

			longAccelMean = statFormat(subset['Long_accel'].mean())
			longAccelMin = statFormat(subset['Long_accel'].min())
			longAccelMax = statFormat(subset['Long_accel'].max())
			longAccelStd = statFormat(subset['Long_accel'].std())

			crossAccelMean = statFormat(subset['Cross_accel'].mean())
			crossAccelMin = statFormat(subset['Cross_accel'].min())
			crossAccelMax = statFormat(subset['Cross_accel'].max())
			crossAccelStd = statFormat(subset['Cross_accel'].std())

			plt.rc('figure', figsize=(11,8.5))

			fig1 = plt.figure()

			fig1.text(0.02,0.02,startTime + " - " + endTime)
			fig1.text(0.75,0.02,"Line ID: " + lineID)

			x = subset.index
			xLabels = (subset['Time'].tolist())[::120]

			ax1 = fig1.add_subplot(311)
			ax1.plot(x, subset['Gravity'])
			ax1.grid(True)
			ax1.set_title('Sensor', fontsize=12)
			ax1.set_xticks(x[::120])
			ax1.set_xticklabels(xLabels)
			ax1.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax1.set_xlim(x.min(), x.max())
			#ax1.set_ylim(-20000, 20000)
			ax1.set_ylabel('mGal', fontsize=10)

			ax2 = fig1.add_subplot(312)
			ax2.plot(x, subset['Long_accel'])
			ax2.grid(True)
			ax2.set_title('Long accel', fontsize=12)
			ax2.set_xticks(x[::120])
			ax2.set_xticklabels(xLabels)
			ax2.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax2.set_xlim(x.min(), x.max())
			ax2.set_ylabel('Gal', fontsize=10)

			ax3 = fig1.add_subplot(313)
			ax3.plot(x, subset['Cross_accel'])
			ax3.grid(True)
			ax3.set_title('Cross accel', fontsize=12)
			ax3.set_xticks(x[::120])
			ax3.set_xticklabels(xLabels)
			ax3.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax3.set_xlim(x.min(), x.max())
			ax3.set_ylabel('Gal', fontsize=10)
			ax3.set_xlabel('Time (UTC)', fontsize=10)

			fig1.subplots_adjust(hspace=.5)

			fig1.savefig(pp, format='pdf')
			plt.close()

			############################# histograms #############################
			fig2 = plt.figure()

			fig2.text(0.02,0.02,startTime + " - " + endTime)
			fig2.text(0.75,0.02,"Line ID: " + lineID)

			ax1 = fig2.add_subplot(311)
			subset['Gravity'].hist(bins=100)
			ax1.set_title('Sensor', fontsize=12)
			ax1.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax1.set_xlabel('mGal', fontsize=10)

			ax1.text(0.02,0.9,'Mean: ' + sensorMean + '\nMin: ' + sensorMin + \
			'\nMax: ' + sensorMax + \
			'\nStd: ' + sensorStd, \
			ha='left', va='top', transform=ax1.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))

			ax2 = fig2.add_subplot(312)
			subset['Long_accel'].hist(bins=100)
			ax2.set_title('Long accel', fontsize=12)
			ax2.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax2.set_xlabel('Gal', fontsize=10)

			ax2.text(0.02,0.9,'Mean: ' + longAccelMean + '\nMin: ' + longAccelMin + \
			'\nMax: ' + longAccelMax + \
			'\nStd: ' + longAccelStd, \
			ha='left', va='top', transform=ax2.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))

			ax3 = fig2.add_subplot(313)
			subset['Cross_accel'].hist(bins=100)
			ax3.set_title('Cross accel', fontsize=12)
			ax3.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
			bottom='off', left='off')
			ax3.set_xlabel('Gal', fontsize=10)

			ax3.text(0.02,0.9,'Mean: ' + crossAccelMean + '\nMin: ' + crossAccelMin + \
			'\nMax: ' + crossAccelMax + \
			'\nStd: ' + crossAccelStd, \
			ha='left', va='top', transform=ax3.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))

			fig2.subplots_adjust(hspace=.5)

			fig2.savefig(pp, format='pdf')
			plt.close()

		pp.close()

	################################

	def lever_arm_correction(self, lat, lon, height, pitch, roll, heading, dx, dy, dz):
		# Returns corrected latitude, longitude, and height

		dlam = (dl*sin(radians(heading)) + dx*cos(radians(heading))) / (_eD*cos(lat))
		dphi = (dl*cos(radians(heading)) - dx*sin(radians(heading))) / _nD
		dH = dh + dl*sin(radians(pitch)) + dx*sin(radians(roll))

		lam = lon + dlam
		phi = lat + dphi
		H = height + dH

		# (return what?)

	################################

	def eotvos_correction(self, lat, lon, height):

		# Radius of curvature of equatorial meridian
		CN = _a / (np.sqrt(1 - _e2 * (np.sin(np.deg2rad(lat)))**2))

		# Radius of curvature of prime meridian
		CM = a * (1 - _e2) / ((1 - _e2 * (np.sin(np.deg2rad(lat)))**2)**(3/2))

		# Easting velocity
		VE = (CN + height)*np.cos(np.deg2rad(lat))*np.gradient(lon)

		# Northing velocity
		VN = (CM + height)*np.gradient(lat)

		eotvos = (VN**2 / _a) * (1 - height / _a + _f * (2 - 3 * (np.sin(np.deg2rad(lat)))**2)) + \
		(VE**2 / _a) * (1 - height/_a - _f * (np.sin(np.deg2rad(lat)))**2) + \
		2 * w * VE * np.cos(np.deg2rad(lat))

		return eotvos * _mGal

	def lat_correction(self, lat):
		return np.float(-9.7803267715) * ((1 + np.float(0.00193185138639)*(np.sin(np.deg2rad(lat)))**2) \
		/ np.sqrt(1 - np.float(0.00669437999013)*(np.sin(np.deg2rad(lat)))**2)) * _mGal

	def free_air_correction(self, height):
		return 0.3086 * height * _mGal

	def vert_accel_correction(self, height):
	# From SciPy.org documentation:
	# 	"The gradient is computed using second order accurate central differences in the
	#	 interior and either first differences or second order accurate one-sides
	#	 (forward or backwards) differences at the boundaries. The returned gradient hence
	#	 has the same shape as the input array."

		return pd.Series(np.gradient(np.gradient(height)), index=height.index) * _mGal
