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
import time

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

	# TO DO: Stores in JSON or YAML files?
	_dgs_col_names = {'Sensor':
						{'order': 1, 'name': 'Sensor'},
					  'Long_accel':
					 	{'order': 2, 'name': 'Long_accel'},
					  'Cross_accel':
					  	{'order': 3, 'name': 'Cross_accel'},
					  'Beam':
					  	{'order': 4, 'name': 'Beam'},
					  'Sensor_temp':
					  	{'order': 5, 'name': 'Sensor_temp'},
					  'Status':
					  	{'order': 6, 'name': 'Status'},
					  'Pressure':
					  	{'order': 7,'name': 'Pressure'},
					  'E_temp':
					  	{'order': 8, 'name': 'E_temp'},
					  'GPS_week':
					  	{'order': 9, 'name': 'GPS_week'},
					  'GPS_sow':
					  	{'order': 10, 'name': 'GPS_sow'}
					  }

	_zls_col_names = {'line_name': {'order': 1, 'name': 'line_name', 'width': 10},
					  'year': {'order': 2, 'name': 'year', 'width': 4},
					  'day': {'order': 3, 'name': 'day', 'width': 3},
					  'hour': {'order': 4, 'name': 'hour', 'width': 2},
					  'minute': {'order': 5, 'name': 'minute', 'width': 2},
					  'second': {'order': 6, 'name': 'second', 'width': 2},
				      'sensor': {'order': 7, 'name': 'sensor', 'width': 8},
					  'spring_tension': {'order': 8, 'name': 'spring_tension', 'width': 8},
					  'cross_coupling': {'order': 9, 'name': 'cross_coupling', 'width': 8},
					  'raw_beam': {'order': 10, 'name': 'raw_beam', 'width': 7},
					  'vcc': {'order': 11, 'name': 'vcc', 'width': 8},
					  'al': {'order': 12, 'name': 'al', 'width': 8},
					  'ax': {'order': 13, 'name': 'ax', 'width': 8},
					  've2': {'order': 14, 'name': 've2', 'width': 8},
					  'ax2': {'order': 15, 'name': 'ax2', 'width': 8},
					  'xacc2': {'order': 16, 'name': 'xacc2', 'width': 8},
					  'lacc2': {'order': 17, 'name': 'lacc2', 'width': 8},
					  'xacc': {'order': 18, 'name': 'xacc', 'width': 8},
					  'lacc': {'order': 19, 'name': 'lacc', 'width': 8},
					  'par_port': {'order': 20, 'name': 'par_port', 'width': 8},
					  'platform_period': {'order': 21, 'name': 'platform_period', 'width': 6}
					  }

	_zls_time_cols = [_zls_col_names['year']['name'],
					  _zls_col_names['day']['name'],
					  _zls_col_names['hour']['name'],
					  _zls_col_names['minute']['name'],
					  _zls_col_names['second']['name']
					  ]

	def __init__(self):

		# Conversion and calibration factors used in ZLS processing
		self.eD = np.float64(1.11585e5)
		self.nD = np.float64(1.11369e5)

		# class instance dataframes
		self.gravity = None
		self.trajectory = None

		# DGS k-factor: 1.0737027
		# ZLS k-factor: 0.9899
		self.attributes = {'k_factor' : 1,
						   'pre_static' : 0,
							'post_static' : 0,
							'gravity_tie' : 0,
							'drift_correction' : 0,
							'sensor_offset' : 0,
							'time_shift' : 0,
							'gravity_data_path' : None,
							'trajectory_data_path' : None,
							'begin_static_mean' : 0,
							'begin_static_spread' : 0,
							'begin_static_trend' : 0,
							'begin_static_stdev' : 0,
							'lines' : dict()
							}
		self.lines = {}
		# TO DO: Populate lines if lines attribute dictionary is not empty.
		# TO DO: The same for when a gravity h5 is loaded.

	""" @brief Removes a line
		@param label Label of line to be removed.
		@return None
	"""
	def remove_line(self, name):
		self.attributes['lines'].pop(name, None)
		self.lines.pop(name, None)

	""" @brief Adds a line defined by a label, start time, and end time.
		@param label Line label which serves as the dictionary key.
	    @param begin Start date and time in the format: YYYY-MM-DD HH:MM:SS
		@param end End date and time
	    @return Adds the line data to the attributes line dictionary.
	"""
	# TO DO: Add option for automatic detemination of begin and end of line given constraints on cross and long accel values.
	def add_line(self, name, begin, end):
		begin_dt = datetime.datetime.strptime(begin,'%Y-%m-%d %H:%M:%S')
		end_dt = datetime.datetime.strptime(end,'%Y-%m-%d %H:%M:%S')

		if begin_dt > end_dt:
			pp.message('add_line : begin time is after end time')
			return

		if pd.Timestamp(begin_dt) > max(self.gravity.index):
			 pp.message('add_line : line begin time is after end of data')
			 return

		if pd.Timestamp(end_dt) < min(self.gravity.index):
			pp.message('add_line : line end time is before begin of data')
			return

		# TO DO: Check whether dictionary entry already exists.
		self.attributes['lines'][name] = (begin_dt, end_dt)
		self.lines[name] = self.gravity[begin_dt:end_dt]

	""" @brief Compute a mean, spread, trend, and standard deviation of the Sensor field within the given period.
	    @param begin Start date and time in the format: YYYY-MM-DD HH:MM:SS
		@param end End date and time
	    @return Sets static_mean, static_spread, static_trend, static_stdev attributes
	"""
	# TO DO: Add option for automatic determination of static period given constraints on stdev, trend, etc.
	def compute_static(self, begin, end):
		if self.gravity is None:
			pp.message('compute_static : no gravity imported')
			return

		begin_dt = datetime.datetime.strptime(begin,'%Y-%m-%d %H:%M:%S')
		end_dt = datetime.datetime.strptime(end,'%Y-%m-%d %H:%M:%S')

		if pd.Timestamp(begin_dt) > max(self.gravity.index):
			 pp.message('compute static : static begin time is after end of data')
			 return

		if pd.Timestamp(end_dt) < min(self.gravity.index):
			pp.message('compute static : static end time is before begin of data')
			return

		static = self.gravity[begin_dt:end_dt]['Sensor']

		self.attributes['static_mean'] = static.mean()
		self.attributes['static_spread'] = abs(static.max() - static.min())
		self.attributes['static_trend'] = (static[len(static)-1] - static[0]) / (static.index(len(static)-1) - static.index(0))
		self.attributes['static_stdev'] = static.std()

	""" @brief Stores gravity dataframe and attributes dictionary in HDF5 file.
	    @param filepath(optional) Path of h5 file. Default: ./gravity_store.h5
		@param force(optional) Flag to overwrite an existing h5 file. Default: False
	    @return None
	"""
	def store_gravity(self, filepath='gravity_store.h5', force=False):
		# TO DO: Deal with Windows-style paths
		# TO DO: Implement force flag
		if self.gravity is None:
			pp.message('write_out_gravity : no gravity imported')
			return

		with pd.HDFStore(filepath) as store:
			store['gravity'] = self.gravity
			store.get_storer('gravity').attrs.attributes = self.attributes

	""" @brief Stores trajectory dataframe in HDF5 file.
	    @param filepath(optional) Path of h5 file. Default: ./gravity_store.h5
		@param force(optional) Flag to overwrite an existing h5 file. Default: False
	    @return None
	"""
	def store_trajectory(self, filepath='trajectory_store.h5', force=False):
		# TO DO: Deal with Windows-style paths
		# TO DO: Implement force flag
		if self.trajectory is None:
			pp.message('write_out_trajectory : no trajectory imported')
			return

		with pd.HDFStore(filepath) as store:
			store['trajectory'] = self.trajectory

	""" @brief Loads gravity dataframe and attributes dictionary from HDF5 file.
	    @param filepath(optional) Path of h5 file. Default: ./gravity_store.h5
		@param force(optional) Flag to overwrite an existing gravity dataframe and attributes dictionary. Default: False
	    @return Sets self.gravity and self.attributes
	"""
	def recover_gravity(self, filepath='gravity_store.h5', force=False):
		# TO DO: Deal with Windows-style paths
		# TO DO: Implement force flag
		with pd.HDFStore(filepath) as store:
			if 'gravity' in store:
				self.gravity = store['gravity']
				self.attributes = store.get_storer('gravity').attrs.attributes

	""" @brief Loads trajectory dataframe from HDF5 file.
	    @param filepath(optional) Path of h5 file. Default: ./trajectory_store.h5
		@param force(optional) Flag to overwrite an existing trajectory dataframe. Default: False
	    @return Sets self.trajectory
	"""
	def recover_trajectory(self, filepath='trajectory_store.h5', force=False):
		# TO DO: Deal with different Windows-style paths
		# TO DO: Implement force flag
		with pd.HDFStore(filepath) as store:
			if 'trajectory' in store:
				self.trajectory = store['trajectory']

	""" @brief Computes drift correction from static readings.
	    @param None
	    @return Sets self.drift_correction, self.sensor_offset, and generates Sensor_corr column.
	"""
	def drift_corr(self):
		self.attributes['drift_correction'] = self.attributes['pre_static'] - \
			self.attributes['post_static']

		# TO DO: Add offset calculation for ZLS
		if self.attributes['sensor_type'] == 'DGS':
			self.attributes['sensor_offset'] = self.attributes['gravity_tie'] - \
				self.attributes['k_factor'] * self.attributes['pre_static']

		elif self.attributes['sensor_type'] == 'ZLS':
			pp.message('sensor2grav_corr : not yet implemented for ZLS-type sensor')

		# TO DO: Set time to begin after pre-static period and end before post-static
		# TO DO: Create function linear in seconds instead?
		drift = pd.Series(np.nan, index=self.gravity.index)
		drift[0] = 0
		drift[-1] = self.attributes['pre_static'] - self.attributes['post_static']
		drift = drift.interpolate(method='time')

		self.gravity['Sensor_corr'] = self.gravity['Sensor'] - drift + self.attributes['sensor_offset']

	""" @brief Sets pre-survey static value
	    @param reading Relative gravity static value.
	    @return Sets self.attributes['pre_static']
	"""
	def set_pre_static_reading(self, reading):
		self.attributes['pre_static'] = np.float64(reading)
		self.drift_corr()

	""" @brief Sets post-survey static value
	    @param reading Relative gravity static value.
	    @return Sets self.attributes['post_static']
	"""
	def set_post_static_reading(self, reading):
		self.attributes['post_static'] = np.float64(reading)
		self.drift_corr()

	""" @brief Sets gravity tie value
	    @param reading Gravity tie value.
	    @return Sets self.attributes['gravity_tie']
	"""
	def set_tie_reading(self, reading):
		self.attributes['gravity_tie'] = np.float64(reading)
		self.drift_corr()

	def read_DGS_meter_config(self, filepath):
		errors = []

		parser = SafeConfigParser()

		try:
			parser.read(filename)

		except OSError as why:
			errors.append(str(why))

		if not parser.has_section('Sensor'):
			pp.message("read_DGS_meter_config : config file missing Sensor section")
			return

		self.meter_model = parser.get('Sensor', 'Meter')
		self.k_factor = parser.get('Sensor', 'kfactor')

		# legacy
		self.time_shift = parser.get('Sensor', 'timeshift')
		self.filter_length = parser.get('Sensor', 'filtertime') # seconds
		self.filter_type = parser.get('Sensor', 'filtype')

		if not parser.has_section('Survey'):
			pp.message("read_DGS_meter_config : config file missing Survey section")
			return

		self.attributes['pre_static'] = parser.get('Survey', 'PreStill')
		self.attributes['post_static'] = parser.get('Survey', 'PostStill')
		self.attributes['gravity_tie'] = parser.get('Survey', 'TieGravity')

		if errors:
			raise Error(errors)

	def _compute_ZLS_gravity(self):
		if self.attributes['sensor_type'] == 'ZLS':
			# beam derivative factor
			kB = 30 # mGal*m/V

			# compute beam derivative
			self.gravity['beam_derivative'] = np.gradient(self.gravity['raw_beam'])

			self.gravity['Sensor'] = (self.attributes['k_factor'] *
									  (self.gravity['spring_tension'] +
									   kB * self.gravity['beam_derivative'] +
									   self.gravity['cross_coupling']))
		else:
			pp.message('compute_ZLS_gravity : not ZLS sensor-type')

	# imports a single ZLS formatted file
	def _read_ZLS_format_file(self, filepath):
		col_names = ['line_name', 'year', 'day', 'hour', 'minute', 'second',
						'sensor_gravity', 'spring_tension', 'cross_coupling',
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
	def _parse_ZLS_file_name(self, filename):
		# split by underscore
		fname = [e.split('.') for e in filename.split('_')]

		# split hour from day and then flatten into one tuple
		b = [int(el) for fname_parts in fname for el in fname_parts]

		# generate datetime
		c = datetime.datetime(b[0], 1, 1) + datetime.timedelta(days=b[2]-1,
																hours=b[1])

		return c

	def import_ZLS_format_data(self, dirpath, begin_time=None, end_time=None,
								excludes=['.*'], force_path=False):

		if not os.path.isdir(dirpath):
			pp.message("import_ZLS_format_data : specified path is not a directory")
			return

		if self.attributes['gravity_data_path'] is not None and force_path \
			or self.attributes['gravity_data_path'] is None:

			self.attributes['gravity_data_path'] = dirpath

		if begin_time is not None and not isinstance(begin_time, datetime.datetime):
			pp.message("import_ZLS_format_data : begin_time is not of type datetime")
			return

		if end_time is not None and not isinstance(end_time, datetime.datetime):
			pp.message("import_ZLS_format_data : end_time is not of type datetime")
			return

		self.attributes['sensor_type'] = 'ZLS'

		excludes = r'|'.join([fnmatch.translate(x) for x in excludes]) or r'$.'

		df = pd.DataFrame()

		# list files in directory
		files = [self._parse_ZLS_file_name(f) for f in os.listdir(self.attributes['gravity_data_path'])
                    if os.path.isfile(os.path.join(self.attributes['gravity_data_path'], f))
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
				pp.message("import_ZLS_format_data : invalid end_time")
				return

		elif begin_time is not None and end_time is None:
			# validate begin_time
			end_time = files[-1]
			if begin_time > end_time or begin_time < files[0]:
				pp.message("import_ZLS_format_data : invalid end_time")
				return

		# filter file list based on begin and end times
		files = filter(lambda x: x >= begin_time and x < end_time, files)

		# convert to file names
		files = [dt.strftime('%Y_%H.%j') for dt in files]

		for f in files:
			frame = self._read_ZLS_format_file(os.path.join(dirpath, f))
			df = pd.concat([df, frame])

		self.gravity = df
		self._compute_ZLS_gravity()

	def import_DGS_format_data(self, filepath, interval=0, filterdelay=0,
								force_path=False, interp=False):
		# TO DO: Set different data types non-float columns to save space.

		if not os.path.isfile(filepath):
			pp.message('import_DGS_format_data : specified path is not a file')
			return

		if self.attributes['gravity_data_path'] is not None and force_path \
			or self.attributes['gravity_data_path'] is None:

			self.attributes['gravity_data_path'] = filepath

		pp.message('import_DGS_format_data : path = ' + filepath)

		self.attributes['sensor_type'] = 'DGS'

		# Read data
		self.gravity = pd.read_csv(filepath)

		# Label columns
		self.gravity.columns = ['Sensor','Long_accel', 'Cross_accel', \
                        'Beam', 'Sensor_temp', 'Status', 'Pressure', \
                        'E_temp', 'GPS_week', 'GPS_sow']

		# Index by datetime
		self.gravity.index =  pp.gps_to_utc('GPS_week', 'GPS_sow', self.gravity)

		# Check time interval
		# 	interval = 0 -> auto
		#	interval != 0 -> manual
		# TO DO: More rigorous interval check.
		dt = (self.gravity.index[1] - self.gravity.index[0]).seconds + \
			(self.gravity.index[1] - self.gravity.index[0]).microseconds * 10**(-6)

		# work around for rounding down issue
		dt = float('{:.6f}'.format(dt))

		if interval == 0:
			pp.message('import_DGS_format_data : detected interval {:.3f} s'.format(dt))

		else:
			pp.message('import_DGS_format_data : set interval {:.3f} s'.format(interval))
			dt = interval

		# fill missing values with NaN
		offset_str = '{:d}U'.format(int(dt*10**6))
		self.gravity = self.gravity.resample(offset_str).mean()

		if interp:
			# interpolate through NaNs
			pp.interp_nans(self.gravity['Sensor'])
			pp.interp_nans(self.gravity['Long_accel'])
			pp.interp_nans(self.gravity['Cross_accel'])
			pp.interp_nans(self.gravity['Beam'])
			pp.message('import_DGS_format_data : interpolated NaNs')

		# Filter delay in seconds
		delay = filterdelay * dt

		# Apply filter delay
		self.gravity.index = self.gravity.index.shift(-delay, freq='S')

		# TO DO: Report gaps.

	def import_trajectory(self, filepath, interval=0, gpstime=False, force_path=False, interp=False):
		# TO DO: Fill-in date and time data when interpolating

		if not os.path.isfile(filepath):
			pp.message('import_trajectory : specified path is not a file')
			return

		if self.attributes['trajectory_data_path'] is not None and force_path or\
			self.attributes['trajectory_data_path'] is None:

			self.attributes['trajectory_data_path'] = filepath

		pp.message("import_trajectory : path = " + filepath)

		self.trajectory = pd.read_csv(filepath, delim_whitespace=True, \
			header=None, engine='c', na_filter=False, skiprows=20)

		# Relabel columns
		self.trajectory.columns = ['MDY','SoD','HMS','unix','Lat', 'Lon', \
			'HEll', 'Pitch', 'Roll', 'Heading', 'Num Sats', 'PDOP']

		self.trajectory['Lon shift'] = abs(self.trajectory['Lon'])

		# Index by datetime
		pp.message("import_trajectory : creating index")
		self.trajectory.index = pd.to_datetime(self.trajectory['MDY'] + ' ' + \
			self.trajectory['HMS'], format="%m/%d/%Y %H:%M:%S.%f")

		# Shift from GPS to UTC
		# TO DO: Calculate shift based on date of first valid time
		if gpstime:
			shift = pp.gps_leapsecond(self.trajectory.index[0])
			self.trajectory.index = self.trajectory.index.shift(-shift, freq='S')

		# Check time interval
		# 	interval = 0 -> auto
		#	interval != 0 -> manual

		dt = (self.trajectory.index[1] - self.trajectory.index[0]).seconds + \
			(self.trajectory.index[1] - self.trajectory.index[0]).microseconds * 10**(-6)

		# work around for rounding down issue
		dt = float('{:.6f}'.format(dt))

		if interval == 0:
			pp.message('import_trajectory : detected interval at {:.3f} s'.format(dt))

		else:
			pp.message('import_trajectory : interval set to {:.3f} s'.format(interval))
			dt = interval

		# fill missing values with NaN
		pp.message("import_trajectory : resampling")
		offset_str = '{:d}U'.format(int(dt * 10**6))
		self.trajectory = self.trajectory.resample(offset_str).mean()

		# interpolate
		if interp:
			pp.interp_nans(self.trajectory['Lat'])
			pp.interp_nans(self.trajectory['Lon'])
			pp.interp_nans(self.trajectory['HEll'])
			pp.interp_nans(self.trajectory['Pitch'])
			pp.interp_nans(self.trajectory['Roll'])
			pp.interp_nans(self.trajectory['Heading'])
			pp.message('import_trajectory : interpolated NaNs')

		# TO DO: Report gaps.

	# TO DO: Handle join to dataframe that has already been joined with trajectory
	def join_grav_traj(self):
		if self.gravity is None:
			pp.message('join_grav_traj : gravity data not yet imported')
			return

		if self.trajectory is None:
			pp.message('join_grav_traj : trajectory not yet imported')
			return

		# Add trajectory data to gravity dataframe
		# TO DO: Use merge instead?
		df = pd.concat([self.gravity, \
			self.trajectory[self.trajectory.columns[2:]]], \
			axis=1, join_axes=[self.gravity.index])

		# Drop rows where there is no position data
		df = df[pd.notnull(df['Lat'])]

		if df.empty:
			pp.message('join_grav_traj : no common data')
		else:
			self.gravity = df

		dt = (self.gravity.index[1] - self.gravity.index[0]).seconds + \
			(self.gravity.index[1] - self.gravity.index[0]).microseconds * 10**(-6)

		# work around for rounding down issue
		dt = float('{:.6f}'.format(dt))

		# fill missing values with NaN
		offset_str = '{:d}U'.format(int(dt*10**6))
		self.gravity = self.gravity.resample(offset_str).mean()


	# def plot_grav_qc(self, df, lines):
	#
	# 	# setup pdf
	# 	pp = PdfPages('multipage.pdf')
	#
	# 	# iterate through rows
	# 	for index, row in lines.iterrows():
	#
	# 		lineID = row['Line_ID']
	# 		startTime = row['Start_Time']
	# 		endTime = row['End_Time']
	#
	# 		print lineID
	#
	# 		# extract subsets
	# 		subset = df[pd.to_datetime(startTime) : pd.to_datetime(endTime)]
	#
	# 		statFormat = lambda x: '%15.2f' % x
	#
	# 		# compute statistics
	# 		sensorMean = statFormat(subset['Gravity'].mean())
	# 		sensorMin = statFormat(subset['Gravity'].min())
	# 		sensorMax = statFormat(subset['Gravity'].max())
	# 		sensorStd = statFormat(subset['Gravity'].std())
	#
	# 		longAccelMean = statFormat(subset['Long_accel'].mean())
	# 		longAccelMin = statFormat(subset['Long_accel'].min())
	# 		longAccelMax = statFormat(subset['Long_accel'].max())
	# 		longAccelStd = statFormat(subset['Long_accel'].std())
	#
	# 		crossAccelMean = statFormat(subset['Cross_accel'].mean())
	# 		crossAccelMin = statFormat(subset['Cross_accel'].min())
	# 		crossAccelMax = statFormat(subset['Cross_accel'].max())
	# 		crossAccelStd = statFormat(subset['Cross_accel'].std())
	#
	# 		plt.rc('figure', figsize=(11,8.5))
	#
	# 		fig1 = plt.figure()
	#
	# 		fig1.text(0.02,0.02,startTime + " - " + endTime)
	# 		fig1.text(0.75,0.02,"Line ID: " + lineID)
	#
	# 		x = subset.index
	# 		xLabels = (subset['Time'].tolist())[::120]
	#
	# 		ax1 = fig1.add_subplot(311)
	# 		ax1.plot(x, subset['Gravity'])
	# 		ax1.grid(True)
	# 		ax1.set_title('Sensor', fontsize=12)
	# 		ax1.set_xticks(x[::120])
	# 		ax1.set_xticklabels(xLabels)
	# 		ax1.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax1.set_xlim(x.min(), x.max())
	# 		#ax1.set_ylim(-20000, 20000)
	# 		ax1.set_ylabel('mGal', fontsize=10)
	#
	# 		ax2 = fig1.add_subplot(312)
	# 		ax2.plot(x, subset['Long_accel'])
	# 		ax2.grid(True)
	# 		ax2.set_title('Long accel', fontsize=12)
	# 		ax2.set_xticks(x[::120])
	# 		ax2.set_xticklabels(xLabels)
	# 		ax2.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax2.set_xlim(x.min(), x.max())
	# 		ax2.set_ylabel('Gal', fontsize=10)
	#
	# 		ax3 = fig1.add_subplot(313)
	# 		ax3.plot(x, subset['Cross_accel'])
	# 		ax3.grid(True)
	# 		ax3.set_title('Cross accel', fontsize=12)
	# 		ax3.set_xticks(x[::120])
	# 		ax3.set_xticklabels(xLabels)
	# 		ax3.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax3.set_xlim(x.min(), x.max())
	# 		ax3.set_ylabel('Gal', fontsize=10)
	# 		ax3.set_xlabel('Time (UTC)', fontsize=10)
	#
	# 		fig1.subplots_adjust(hspace=.5)
	#
	# 		fig1.savefig(pp, format='pdf')
	# 		plt.close()
	#
	# 		############################# histograms #############################
	# 		fig2 = plt.figure()
	#
	# 		fig2.text(0.02,0.02,startTime + " - " + endTime)
	# 		fig2.text(0.75,0.02,"Line ID: " + lineID)
	#
	# 		ax1 = fig2.add_subplot(311)
	# 		subset['Gravity'].hist(bins=100)
	# 		ax1.set_title('Sensor', fontsize=12)
	# 		ax1.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax1.set_xlabel('mGal', fontsize=10)
	#
	# 		ax1.text(0.02,0.9,'Mean: ' + sensorMean + '\nMin: ' + sensorMin + \
	# 		'\nMax: ' + sensorMax + \
	# 		'\nStd: ' + sensorStd, \
	# 		ha='left', va='top', transform=ax1.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))
	#
	# 		ax2 = fig2.add_subplot(312)
	# 		subset['Long_accel'].hist(bins=100)
	# 		ax2.set_title('Long accel', fontsize=12)
	# 		ax2.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax2.set_xlabel('Gal', fontsize=10)
	#
	# 		ax2.text(0.02,0.9,'Mean: ' + longAccelMean + '\nMin: ' + longAccelMin + \
	# 		'\nMax: ' + longAccelMax + \
	# 		'\nStd: ' + longAccelStd, \
	# 		ha='left', va='top', transform=ax2.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))
	#
	# 		ax3 = fig2.add_subplot(313)
	# 		subset['Cross_accel'].hist(bins=100)
	# 		ax3.set_title('Cross accel', fontsize=12)
	# 		ax3.tick_params(axis='both', which='major', labelsize=8, right='off', top='off', \
	# 		bottom='off', left='off')
	# 		ax3.set_xlabel('Gal', fontsize=10)
	#
	# 		ax3.text(0.02,0.9,'Mean: ' + crossAccelMean + '\nMin: ' + crossAccelMin + \
	# 		'\nMax: ' + crossAccelMax + \
	# 		'\nStd: ' + crossAccelStd, \
	# 		ha='left', va='top', transform=ax3.transAxes, fontsize=10, bbox=dict(facecolor='white', alpha=1))
	#
	# 		fig2.subplots_adjust(hspace=.5)
	#
	# 		fig2.savefig(pp, format='pdf')
	# 		plt.close()
	#
	# 	pp.close()


	# def lever_arm_correction(self, lat, lon, height, pitch, roll, heading, dx, dy, dz):
	# 	# TO DO: Validate arguments.
	# 	# TO DO: Adapt to use dataframe.
	#
	# 	# Returns corrected latitude, longitude, and height
	#
	# 	dlam = (dl*sin(radians(heading)) + dx*cos(radians(heading))) / (_eD*cos(lat))
	# 	dphi = (dl*cos(radians(heading)) - dx*sin(radians(heading))) / _nD
	# 	dH = dh + dl*sin(radians(pitch)) + dx*sin(radians(roll))
	#
	# 	lam = lon + dlam
	# 	phi = lat + dphi
	# 	H = height + dH

		# (return what?)

	def eotvos_correction(self):
		# TO DO: Check if Lat, Lon, and HEll exist.

		# Radius of curvature of equatorial meridian
		CN = self._a / (np.sqrt(1 - self._e2 * (np.sin(np.deg2rad(self.gravity['Lat'])))**2))

		# Radius of curvature of prime meridian
		CM = self._a * (1 - self._e2) / ((1 - self._e2 * (np.sin(np.deg2rad(self.gravity['Lat'])))**2)**(3/2))

		# Easting velocity
		VE = (CN + self.gravity['HEll'])*np.cos(np.deg2rad(self.gravity['Lat']))*np.gradient(self.gravity['Lon shift'])

		# Northing velocity
		VN = (CM + self.gravity['HEll'])*np.gradient(self.gravity['Lat'])

		eotvos = (VN**2 / self._a) * (1 - self.gravity['HEll'] / self._a + self._f * (2 - 3 *
			(np.sin(np.deg2rad(self.gravity['Lat'])))**2)) + \
			(VE**2 / self._a) * (1 - self.gravity['HEll'] / self._a - \
			self._f * (np.sin(np.deg2rad(self.gravity['Lat'])))**2) + \
			2 * self._w * VE * np.cos(np.deg2rad(self.gravity['Lat']))

		self.gravity['Eotvos correction']  = eotvos * self._mGal

	def latitude_correction(self):
		self.gravity['Latitude correction'] = np.float(-9.7803267715) * \
			((1 + np.float(0.00193185138639)*(np.sin(np.deg2rad(self.gravity['Lat'])))**2) \
		/ np.sqrt(1 - np.float(0.00669437999013)*(np.sin(np.deg2rad(self.gravity['Lat'])))**2)) * self._mGal

	def free_air_correction(self):
		self.gravity['Free air correction'] = 0.3086 * self.gravity['HEll'] * self._mGal

	def vert_accel_correction(self):
	# From SciPy.org documentation:
	# 	"The gradient is computed using second order accurate central differences in the
	#	 interior and either first differences or second order accurate one-sides
	#	 (forward or backwards) differences at the boundaries. The returned gradient hence
	#	 has the same shape as the input array."
		# TO DO: Necessary to call pd.Series?
		self.gravity['Vert accel correction'] = pd.Series(np.gradient(np.gradient(self.gravity['HEll'])), \
			index=self.gravity.index) / self._mGal
