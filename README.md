# GDPS
*Gravity Data Processing System - A Python toolkit for processing gravity data*

__Work In Progress__

The system is designed around a single class that encapsulates the processing workflow, including:

* Import gravity and trajectory data
* Merge gravity and trajectory data
* Resample and decimate
* Create survey lines
* Fill gaps in data
* Produce plots
* Apply filters
* Apply corrections
  * Eötvös
  * latitude
  * kinematic acceleration
  * lever arm

## Install
*NOTE:* Tested only on Python 2.7.
1. Install HDF5 library.
2. Install supporting Python packages:
```shell
pip install -r requirements.txt
```

## License
MIT.
