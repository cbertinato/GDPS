import qc
import numpy as np
import pandas as pd

gravityDataFile = 'Albany Flight Test Data 6May2015.dat'
lineFile = 'SCH_05062015_LINES.txt'

# read gravity data
df = qc.import_gravity_DgS_format(gravityDataFile)

# read line info
lines = pd.read_csv(lineFile)

# wrap around values (EXPERIMENTAL)
df['Grav_mod'] = (df['Gravity'] % 50000) * np.sign(df['Gravity'])

# generate QC plots
qc.plot_grav_qc(df,lines)