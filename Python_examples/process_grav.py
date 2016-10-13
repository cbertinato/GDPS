import qc
import numpy as np
import pandas as pd

gravitydatafile = 'van29_04.dat'
linefile = 'SCH_05062015_LINES.txt'
posfile = 'Position.txt'
k = np.float64(0.984048371556240)

# Hardware FIR filter delay
filterdelay = 7 # samples

# Moving average window
filterwindow = 150 # seconds

# read in gravity and position data
df = qc.import_gravity_DgS_format(gravitydatafile, filterdelay)
pos = qc.import_pos(posfile)

# join gravity and trajectory data frames
df = qc.join_grav_pos(df, pos)

# compute corrected gravity
df['Corr Gravity'] = k * df['Gravity'] + qc.vert_accel_correction(df['Proc Ell Ht']) + \
qc.free_air_correction(df['Proc Ell Ht']) + \
qc.lat_correction(df['Proc Lat']) + \
qc.eotvos_correction(df['Proc Lat'], df['Proc Lon'], df['Proc Ell Ht'])

#df['Corr Gravity'] = df['Gravity']

# filter with moving average
#df['Corr Gravity Filtered'] = pd.rolling_sum(df['Corr Gravity'], filterwindow)
df = qc.filter_gravity(df, filterwindow)

#df['Corr Gravity'] = df['Corr Gravity'] / qc.mGal

# write to csv
df.to_csv('van29_04_test.csv')

# read line info
#lines = pd.read_csv(linefile)

