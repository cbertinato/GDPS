import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

########## Constants ##########

# Semi-major axis
a = np.float64(6378137) # m

# Semi-minor axis
b = np.float64(6356752.3141) # m

# Flattening
f = (a - b) / a

# Earth rate of rotation
w = np.float64(7292115e-11) # rad/s

# Equatorial gravity
gE = np.float64(9.7803267715) # m/s^2

# Polar gravity
gP = np.float64(9.8321863685) # m/s^2

# Eccentricity squared
e2 = np.float64(0.00669438002290)

# Conversion and calibration factors
eD = np.float64(1.11585e5) # ?
nD = np.float64(1.11369e5) # ?
mGal = np.float64(10e-5) # 1 mGal = 10^-5 m/s^2

def importZbiasfile(filename):
    print "Importing gravity data from %s." % filename
    df = pd.read_csv(filename)

    # Label columns
	df.columns = [']
