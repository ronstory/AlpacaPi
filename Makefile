######################################################################################
#	Make file for alpaca driver
#	written by hand by Mark Sproul
#	(C) 2019 by Mark Sproul
#
#		sudo apt-get install build-essential
#		sudo apt-get install libusb-1.0-0-dev
#		sudo apt-get install libudev-dev
#		sudo apt-get install libopencv-dev
#		sudo apt-get install libi2c-dev
#		sudo apt-get install libjpeg-dev
#		sudo apt-get install libcfitsio-dev
#
#		sudo apt-get install wiringpi
#
#		sudo apt-get install libnova-dev		<<<< required for TSC
#
#		sudo apt-get install git-gui
#
#	https://www.gnu.org/software/make/manual/make.html
#
#	https://github.com/TheNextLVL/wiringPi
######################################################################################
#	Edit History
######################################################################################
#++	Apr  9,	2019	<MLS> Started on alpaca driver
#++	Apr 29,	2019	<MLS> Added openCV support
#++	May  7,	2019	<MLS> Added smate build option
#++	May 24,	2019	<MLS> Added wx build option
#++	Jun 25,	2019	<MLS> Added jetson build option
#++	Aug 20,	2019	<MLS> Added ATIK support
#++	Jan  9,	2020	<MLS> Added ToupTek support
#++	Jan 24,	2020	<MLS> Moved _ENABLE_FITS_ to Makefile
#++	Feb 11,	2020	<MLS> Added shutter
#++	Apr  3,	2020	<MLS> Added _ENABLE_FLIR_
#++	Apr 16,	2020	<MLS> Added _ENABLE_PWM_SWITCH_
#++	Apr 22,	2020	<MLS> Added flir to build flir camera on ubuntu
#++	Jun  8,	2020	<MLS> Added video controller
#++	Jun 23,	2020	<MLS> Added preview controller
#++	Jul 16,	2020	<MLS> Added pi64 for 64 bit Raspberry Pi OS
#++	Dec 12,	2020	<MLS> Moved _ENABLE_REMOTE_SHUTTER_ into Makefile
#++	Jan 13,	2021	<MLS> Added build commands for touptech cameras
#++	Mar 18,	2021	<MLS> Updating Makefile to use AtikCamerasSDK_2020_10_19
#++	Mar 18,	2021	<MLS> Updating QHY camera support
#++	Apr 20,	2021	<MLS> Added _ENABLE_TELESCOPE_RIGEL_
#++	Apr 26,	2021	<MLS> Added _ENABLE_FILTERWHEEL_ZWO_
#++	Apr 26,	2021	<MLS> Added _ENABLE_FILTERWHEEL_ATIK_
#++	Jan  6,	2022	<MLS> Added _ENABLE_REMOTE_SQL_  & _ENABLE_REMOTE_GAIA_
#++	Jan 13,	2022	<MLS> Added _ENABLE_ASTERIODS_
#++	Jan 18,	2022	<MLS> Added fitsview to makefile
#++	Mar 24,	2022	<MLS> Added -fPIE to compile options
#++	Mar 25,	2022	<MLS> Added _ENABLE_TELESCOPE_SERVO_
#++	Mar 26,	2022	<MLS> Added make_checkplatform.sh
#++	Mar 26,	2022	<MLS> Added make_checkopencv.sh
#++	Mar 26,	2022	<MLS> Added make_checksql.sh
#++	May  2,	2022	<MLS> Added IMU source directory (src_imu)
#++	May  2,	2022	<MLS> Added _ENABLE_IMU_
#++	May  2,	2022	<MLS> Added make moonlite for stand alone moonlite focuser driver
#++	May  4,	2022	<MLS> Added camera simulator (make camerasim)
#++	May 19,	2022	<MLS> Updated Makefile to reflect RNS filename changes
#++	Jun 30,	2022	<MLS> Added dumpfits to makefile
#++	Oct 17,	2022	<MLS> Added _ENABLE_FOCUSER_MOONLITE_
#++	Oct 17,	2022	<MLS> Added _ENABLE_FILTERWHEEL_USIS_
######################################################################################
#	Cr_Core is for the Sony camera
######################################################################################

#PLATFORM			=	x86
#PLATFORM			=	x64
#PLATFORM			=	armv7

###########################################
#	lets try to determine platform
MACHINE_TYPE		=	$(shell uname -m)
PLATFORM			=	$(shell ./make_checkplatform.sh)
OPENCV_VERSION		=	$(shell ./make_checkopencv.sh)
SQL_VERSION			=	$(shell ./make_checksql.sh)

###########################################
# default settings for Desktop Linux build
USR_HOME			=	$(HOME)/
GCC_DIR				=	/usr/bin/
INCLUDE_BASE		=	/usr/include/
LIB_BASE			=	/usr/lib/

#	/usr/local/lib/pkgconfig/opencv.pc
OPENCV_COMPILE		=	$(shell pkg-config --cflags $(OPENCV_VERSION))
OPENCV_LINK			=	$(shell pkg-config --libs $(OPENCV_VERSION))

PHASEONE_INC		=	/usr/local/include/phaseone/include/
PHASEONE_LIB		=	/usr/local/lib/

SRC_DIR				=	./src/
SRC_IMGPROC			=	./src_imageproc/
SRC_DISCOVERY		=	./src_discovery/
SRC_MOONRISE		=	./src_MoonRise/
SRC_SERVO			=	./src_servo/
MLS_LIB_DIR			=	./src_mlsLib/
OBJECT_DIR			=	./Objectfiles/
SRC_IMU				=	./src_imu/


GD_DIR				=	../gd/
ASI_LIB_DIR			=	./ASI_lib
ASI_INCLUDE_DIR		=	./ASI_lib/include
EFW_LIB_DIR			=	./EFW_linux_mac_SDK

############################################
#	as of Mar 18, 2021, supporting the AtikCamerasSDK_2020_10_19 version of ATIK
ATIK_DIR			=	./AtikCamerasSDK
ATIK_LIB_MASTER_DIR	=	$(ATIK_DIR)/lib
ATIK_INCLUDE_DIR	=	$(ATIK_DIR)/include
ATIK_INCLUDE_DIR2	=	$(ATIK_DIR)/inc
#ATIK_LIB_DIR		=	$(ATIK_LIB_MASTER_DIR)/linux/x64/NoFlyCapture
ATIK_LIB_DIR		=	$(ATIK_LIB_MASTER_DIR)/linux/64/NoFlyCapture
#ATIK_LIB_DIR_V129	=	$(ATIK_LIB_MASTER_DIR)/ARM/pi/pi3/x86/NoFlyCapture
ATIK_LIB_DIR_ARM32	=	$(ATIK_LIB_MASTER_DIR)/ARM/32/NoFlyCapture
ATIK_LIB_DIR_ARM64	=	$(ATIK_LIB_MASTER_DIR)/ARM/64/NoFlyCapture

ATIK_PLATFORM		=	unknown

ifeq ($(PLATFORM),  x64)
	ATIK_PLATFORM	=	linux/64
endif
ifeq ($(PLATFORM),  armv7)
	ATIK_PLATFORM	=	ARM/32
endif
ifeq ($(PLATFORM),  armv8)
	ATIK_PLATFORM	=	ARM/64
endif
ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/$(ATIK_PLATFORM)/NoFlyCapture

############################################
TOUP_DIR			=	./toupcamsdk
TOUP_INCLUDE_DIR	=	$(TOUP_DIR)/inc
TOUP_LIB_DIR		=	$(TOUP_DIR)/linux/x64

############################################
FLIR_INCLUDE_DIR	=	/usr/include/spinnaker


############################################
SONY_INCLUDE_DIR	=	./SONY_SDK/CRSDK
SONY_LIB_DIR		=	./SONY_SDK/lib

############################################
#	QHY support
QHY_INCLUDE_DIR		=	./QHY/include

############################################
#	QSI support
QSI_INCLUDE_DIR		=	./qsiapi-7.6.0

#DEFINEFLAGS		=	-D_GENERATE_GRAPHICS_
#DEFINEFLAGS		+=	-D_USE_WEB_GRAPH_
DEFINEFLAGS		+=	-D_INCLUDE_HTTP_HEADER_
DEFINEFLAGS		+=	-D_INCLUDE_ALPACA_EXTENSIONS_
DEFINEFLAGS		+=	-D_ALPACA_PI_

CFLAGS			=	-Wall -Wno-multichar -Wno-unknown-pragmas -Wstrict-prototypes
CFLAGS			+=	-Wextra
#CFLAGS			+=	-Werror
CFLAGS			+=	-Wmissing-prototypes
#CFLAGS			+=	-trigraphs
CFLAGS			+=	-g
#CFLAGS			+=	-Wno-unused-but-set-variable
#CFLAGS			+=	-Wstrict-prototypes
#CFLAGS			+=	-mx32
CFLAGS			+=	-fPIE
CFLAGS			+=	-Wno-implicit-fallthrough

CPLUSFLAGS		=	-Wall -Wno-multichar -Wno-unknown-pragmas
CPLUSFLAGS		+=	-Wextra
CPLUSFLAGS		+=	-Wno-unused-parameter
#CPLUSFLAGS		+=	-Wno-class-memaccess
#CPLUSFLAGS		+=	-O2
#CPLUSFLAGS		+=	-trigraphs
CPLUSFLAGS		+=	-g
#CPLUSFLAGS		+=	-Wno-unused-but-set-variable
CPLUSFLAGS		+=	-fPIE
CPLUSFLAGS		+=	-Wno-format-overflow
CPLUSFLAGS		+=	-Wno-implicit-fallthrough


COMPILE			=	gcc -c $(CFLAGS) $(DEFINEFLAGS) $(OPENCV_COMPILE)
COMPILEPLUS		=	g++ -c $(CPLUSFLAGS) $(DEFINEFLAGS) $(OPENCV_COMPILE)
LINK			=	g++


INCLUDES		=	-I/usr/include					\
					-I/usr/local/include			\
					-I$(SRC_DIR)					\
					-I$(EFW_LIB_DIR)				\
					-I$(ASI_INCLUDE_DIR)			\
					-I$(ATIK_INCLUDE_DIR)			\
					-I$(ATIK_INCLUDE_DIR2)			\
					-I$(TOUP_INCLUDE_DIR)			\
					-I$(FLIR_INCLUDE_DIR)			\
					-I$(MLS_LIB_DIR)				\
					-I$(QHY_INCLUDE_DIR)			\
					-I$(SRC_IMGPROC)				\



#					-I/usr/include/opencv2			\
#					-I/usr/local/include/opencv2	\
#					-I/usr/include/opencv4			\
#					-I/usr/local/include/opencv4	\


######################################################################################
ASI_CAMERA_OBJECTS=												\
				$(ASI_LIB_DIR)/lib/$(PLATFORM)/libASICamera2.a	\


######################################################################################
ZWO_EFW_OBJECTS=												\
				$(EFW_LIB_DIR)/lib/$(PLATFORM)/libEFWFilter.a	\



######################################################################################
SOCKET_OBJECTS=												\
				$(OBJECT_DIR)socket_listen.o				\
				$(OBJECT_DIR)json_parse.o					\
				$(OBJECT_DIR)sendrequest_lib.o				\


######################################################################################
DISCOVERY_LIB_OBJECTS=										\
				$(OBJECT_DIR)discovery_lib.o				\



######################################################################################
# CPP objects
CPP_OBJECTS=												\
				$(OBJECT_DIR)alpacadriver.o					\
				$(OBJECT_DIR)alpacadriver_templog.o			\
				$(OBJECT_DIR)alpacadriver_helper.o			\
				$(OBJECT_DIR)alpaca_discovery.o				\
				$(OBJECT_DIR)alpacadriverLogging.o			\
				$(OBJECT_DIR)cpu_stats.o					\
				$(OBJECT_DIR)discoverythread.o				\
				$(OBJECT_DIR)domedriver.o					\
				$(OBJECT_DIR)domeshutter.o					\
				$(OBJECT_DIR)domedriver_rpi.o				\
				$(OBJECT_DIR)eventlogging.o					\
				$(OBJECT_DIR)HostNames.o					\
				$(OBJECT_DIR)JsonResponse.o					\
				$(OBJECT_DIR)linuxerrors.o					\
				$(OBJECT_DIR)lx200_com.o					\
				$(OBJECT_DIR)managementdriver.o				\
				$(OBJECT_DIR)observatory_settings.o			\
				$(OBJECT_DIR)readconfigfile.o				\
				$(OBJECT_DIR)sidereal.o						\
				$(OBJECT_DIR)shutterdriver.o				\
				$(OBJECT_DIR)shutterdriver_arduino.o		\
				$(OBJECT_DIR)serialport.o					\
				$(OBJECT_DIR)telescopedriver.o				\
				$(OBJECT_DIR)telescopedriver_comm.o			\
				$(OBJECT_DIR)telescopedriver_lx200.o		\
				$(OBJECT_DIR)telescopedriver_Rigel.o		\
				$(OBJECT_DIR)telescopedriver_servo.o		\
				$(OBJECT_DIR)telescopedriver_skywatch.o		\

LIVE_WINDOW_OBJECTS=										\
				$(OBJECT_DIR)controller.o					\
				$(OBJECT_DIR)controller_image.o				\
				$(OBJECT_DIR)opencv_utils.o					\
				$(OBJECT_DIR)windowtab.o					\
				$(OBJECT_DIR)windowtab_about.o				\
				$(OBJECT_DIR)windowtab_image.o				\


#				$(OBJECT_DIR)controllerAlpaca.o				\

######################################################################################
#	Driver Objects
DRIVER_OBJECTS=												\
				$(OBJECT_DIR)calibrationdriver.o			\
				$(OBJECT_DIR)calibrationdriver_rpi.o		\
				$(OBJECT_DIR)cameradriver.o					\
				$(OBJECT_DIR)cameradriverAnalysis.o			\
				$(OBJECT_DIR)cameradriver_ASI.o				\
				$(OBJECT_DIR)cameradriver_ATIK.o			\
				$(OBJECT_DIR)cameradriver_fits.o			\
				$(OBJECT_DIR)cameradriver_FLIR.o			\
				$(OBJECT_DIR)cameradriver_jpeg.o			\
				$(OBJECT_DIR)cameradriver_livewindow.o		\
				$(OBJECT_DIR)cameradriver_opencv.o			\
				$(OBJECT_DIR)cameradriver_png.o				\
				$(OBJECT_DIR)cameradriver_QHY.o				\
				$(OBJECT_DIR)cameradriver_QSI.o				\
				$(OBJECT_DIR)cameradriver_SONY.o			\
				$(OBJECT_DIR)cameradriver_save.o			\
				$(OBJECT_DIR)cameradriver_sim.o				\
				$(OBJECT_DIR)cameradriver_TOUP.o			\
				$(OBJECT_DIR)commoncolor.o					\
				$(OBJECT_DIR)filterwheeldriver.o			\
				$(OBJECT_DIR)filterwheeldriver_ATIK.o		\
				$(OBJECT_DIR)filterwheeldriver_ZWO.o		\
				$(OBJECT_DIR)focuserdriver.o				\
				$(OBJECT_DIR)focuserdriver_nc.o				\
				$(OBJECT_DIR)julianTime.o					\
				$(OBJECT_DIR)moonlite_com.o					\
				$(OBJECT_DIR)multicam.o						\
				$(OBJECT_DIR)moonphase.o					\
				$(OBJECT_DIR)MoonRise.o						\
				$(OBJECT_DIR)obsconditionsdriver.o			\
				$(OBJECT_DIR)obsconditionsdriver_rpi.o		\
				$(OBJECT_DIR)rotatordriver.o				\
				$(OBJECT_DIR)rotatordriver_nc.o				\
				$(OBJECT_DIR)slittracker.o					\
				$(OBJECT_DIR)switchdriver.o					\
				$(OBJECT_DIR)switchdriver_rpi.o				\

######################################################################################
# Camera objects
CAMERA_OBJECTS=												\
				$(OBJECT_DIR)cameradriver.o					\
				$(OBJECT_DIR)cameradriverAnalysis.o			\
				$(OBJECT_DIR)cameradriver_ASI.o				\
				$(OBJECT_DIR)cameradriver_ATIK.o			\
				$(OBJECT_DIR)cameradriver_fits.o			\
				$(OBJECT_DIR)cameradriver_FLIR.o			\
				$(OBJECT_DIR)cameradriver_jpeg.o			\
				$(OBJECT_DIR)cameradriver_livewindow.o		\
				$(OBJECT_DIR)cameradriver_opencv.o			\
				$(OBJECT_DIR)cameradriver_png.o				\
				$(OBJECT_DIR)cameradriver_QHY.o				\
				$(OBJECT_DIR)cameradriver_QSI.o				\
				$(OBJECT_DIR)cameradriver_SONY.o			\
				$(OBJECT_DIR)cameradriver_save.o			\
				$(OBJECT_DIR)cameradriver_sim.o				\
				$(OBJECT_DIR)cameradriver_TOUP.o			\

######################################################################################
# Filterwheel objects
FITLERWHEEL_OBJECTS=										\
				$(OBJECT_DIR)filterwheeldriver.o			\
				$(OBJECT_DIR)filterwheeldriver_ATIK.o		\
				$(OBJECT_DIR)filterwheeldriver_ZWO.o		\


######################################################################################
TEST_OBJECTS=												\
				$(OBJECT_DIR)calibration_Alnitak.o			\
				$(OBJECT_DIR)cameradriver_PhaseOne.o		\

######################################################################################
#	Camera Objects
IMAGEPROC_OBJECTS=											\
				$(OBJECT_DIR)imageprocess_orb.o				\


CLIENT_OBJECTS=												\
				$(OBJECT_DIR)json_parse.o					\
				$(OBJECT_DIR)discoveryclient.o				\

HELPER_OBJECTS=												\
				$(OBJECT_DIR)helper_functions.o				\


######################################################################################
#	Roll Off Roof Objects
ROR_OBJECTS=												\
				$(OBJECT_DIR)alpacadriver.o					\
				$(OBJECT_DIR)alpacadriver_helper.o			\
				$(OBJECT_DIR)alpacadriverLogging.o			\
				$(OBJECT_DIR)alpaca_discovery.o				\
				$(OBJECT_DIR)cpu_stats.o					\
				$(OBJECT_DIR)discoverythread.o				\
				$(OBJECT_DIR)domedriver.o					\
				$(OBJECT_DIR)domedriver_ror_rpi.o			\
				$(OBJECT_DIR)eventlogging.o					\
				$(OBJECT_DIR)HostNames.o					\
				$(OBJECT_DIR)JsonResponse.o					\
				$(OBJECT_DIR)linuxerrors.o					\
				$(OBJECT_DIR)managementdriver.o				\
				$(OBJECT_DIR)observatory_settings.o			\
				$(OBJECT_DIR)raspberrypi_relaylib.o			\

######################################################################################
# CPP objects
IMU_OBJECTS=												\
				$(OBJECT_DIR)imu_lib.o						\
				$(OBJECT_DIR)i2c_bno055.o					\

######################################################################################
#pragma mark make help
help:
	#################################################################################
	# The AlpacaPi project consists of two main parts, drivers and clients
	#    Driver make options
	#        make alpacapi   Driver for x86 linux
	#        make camerasim  Camera simulator
	#        make dome       Raspberry pi version to control dome using DC motor controller
	#        make jetson     Version to run on nvidia jetson board, this is an armv8
	#        make moonlite   Driver for moonlite focusers ONLY
	#        make nocamera   Build without the camera support
	#        make noopencv   Camera driver for ZWO WITHOUT opencv
	#        make pi         Version for Raspberry Pi
	#        make picv4      Version for Raspberry Pi using OpenCV 4 or later
	#        make piqhy      Camera driver for QHY cameras only for Raspberry-Pi
	#        make qsi        Camera driver for QSI cameras
	#        make wx         Version that uses the R-Pi sensor board
	#
	#
	# Telescope drivers,
	# As of May 2022, the telescope driver is still in development,
	# There are several options that are in progress
	#        make tele      Makes a version which speaks LX200 over a TCP/IP connection
	#        make rigel     Makes a special version for a user that uses a rigel controller
	#        make eq6       A version to control eq6 style mounts
	#        make servo     A telescope controller based on servo motors using LM628/629
	#
	# Miscellaneous
	#        make clean      removes all binaries
	#        make help       this message
	#
	#    Client make options
	#       SkyTravel is an all in one client program, it has all of the controllers built in
	#       with full Alpaca Discovery support and generates a list of available devices
	#
	#       make sky         makes SkyTravel with openCV 3.3.1 or earlier
	#       make skysql      same as sky but with SQL database support
	#>      make skycv4      makes SkyTravel with newer Versions after 3.3.1
	#>      make skycv4sql   same as skycv4 with SQL database support
	#
	#   Some of the clients can also be built separately
	#       make camera
	#       make domectrl
	#       make focuser
	#       make switch
	#
	# Once everything is converted to openCV4, the opencv3 options will go away
	# MACHINE_TYPE  =$(MACHINE_TYPE)
	# PLATFORM      =$(PLATFORM)
	# OPENCV_VERSION=$(OPENCV_VERSION)
	# SQL_VERSION   =$(SQL_VERSION)
	# ATIK_PLATFORM =$(ATIK_PLATFORM)
	#################################################################################



#	Debug                     Makefile
#        smate      Build a version to run on a Stellarmate running smate OS



######################################################################################
#pragma mark make alpacapi  C++ linux-x86
alpacapi		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
alpacapi		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
#alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_LX200_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
alpacapi		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
alpacapi		:	$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR)/			\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-lqhyccd					\
					-o alpacapi

######################################################################################
#        make camerasim  Camera simulator
camerasim		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
camerasim		:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
camerasim		:	DEFINEFLAGS		+=	-D_SIMULATE_CAMERA_
camerasim		:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
camerasim		:	DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
camerasim		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
camerasim		:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
camerasim		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
camerasim		:	DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
camerasim		:	$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o camerasim


######################################################################################
#pragma mark make picv4
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
picv4		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
picv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
picv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
#picv4		:		OPENCV_COMPILE	=	$(shell pkg-config --cflags opencv4)
#picv4		:		OPENCV_LINK		=	$(shell pkg-config --libs opencv4)
#picv4		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
picv4		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
#picv4		:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
picv4		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi

#					-lwiringPi					\
#					-latikcameras				\
#					-L$(ATIK_LIB_DIR_ARM32)/	\




######################################################################################
#pragma mark make moonlite
moonlite		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
moonlite		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
moonlite		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
moonlite		:	$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-o alpaca-moonlite


######################################################################################
#pragma mark make piqhy
#	make qhy
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
piqhy		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
piqhy		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
#piqhy		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
piqhy		:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
piqhy		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\

		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-lqhyccd					\
					-o alpacapi


######################################################################################
#pragma mark make qsi
qsi		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
qsi		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
qsi		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
qsi		:		DEFINEFLAGS		+=	-D_ENABLE_QSI_
qsi		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
qsi		:		INCLUDES		+=	-I$(QSI_INCLUDE_DIR)
qsi		:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\

		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-lcfitsio					\
					-lqsiapi					\
					-lftd2xx					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi

######################################################################################
#pragma mark make qsicv4
qsicv4		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
qsicv4		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
qsicv4		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
qsicv4		:		DEFINEFLAGS		+=	-D_ENABLE_QSI_
qsicv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
qsicv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
qsicv4		:		INCLUDES		+=	-I$(QSI_INCLUDE_DIR)
qsicv4		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\

		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-lcfitsio					\
					-lqsiapi					\
					-lftd2xx					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi

######################################################################################
#pragma mark make qsiimu
qsiimu		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
qsiimu		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
qsiimu		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
qsiimu		:		DEFINEFLAGS		+=	-D_ENABLE_QSI_
qsiimu		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
qsiimu		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
qsiimu		:		INCLUDES		+=	-I$(QSI_INCLUDE_DIR)
qsiimu		:		INCLUDES		+=	-I$(SRC_IMU)
qsiimu		:		DEFINEFLAGS		+=	-D_ENABLE_IMU_
qsiimu		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\

		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(IMU_OBJECTS)				\
					-lcfitsio					\
					-lqsiapi					\
					-lftd2xx					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi



######################################################################################
#pragma mark make allcam
#	this is primarily for development, all cameras are enabled
allcam		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_SONY_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
allcam		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
allcam		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
#allcam		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_LX200_
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
#allcam		:		INCLUDES		+=	-I$(SONY_INCLUDE_DIR)
allcam		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
allcam		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR)/			\
					-L$(TOUP_LIB_DIR)/			\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-ltoupcam					\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-lqhyccd					\
					-o alpacapi

#					-lSpinnaker_C				\


######################################################################################
#pragma mark make tele  C++ linux-x86
tele		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_ROR_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#tele		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
tele	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_LX200_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_LX200_COM_
tele	:		DEFINEFLAGS		+=	-D_ENABLE_IMU_
tele	:		INCLUDES		+=	-I$(SRC_IMU)
#tele	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_SKYWATCH_
tele	:			$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(IMU_OBJECTS)				\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lusb-1.0					\
					-lcfitsio					\
					-lpthread					\
					-o alpacapi-telescope


#					-ludev						\


######################################################################################
#pragma mark make telecv4  C++ linux-x86
telecv4	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_ROR_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#telecv4		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
telecv4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_LX200_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_LX200_COM_
telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_IMU_
telecv4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
telecv4	:		INCLUDES		+=	-I$(SRC_IMU)
#telecv4	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_SKYWATCH_
telecv4	:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(IMU_OBJECTS)				\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lusb-1.0					\
					-lcfitsio					\
					-lpthread					\
					-o alpacapi-telescope



######################################################################################
#pragma mark make eq6
eq6		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
eq6		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
#eq6	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_LX200_
#eq6	:		DEFINEFLAGS		+=	-D_ENABLE_LX200_COM_
eq6		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_SKYWATCH_
eq6		:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-o alpacapi-eq6



######################################################################################
#pragma mark make wo71
#	this is for my William Optics 71 configuration
wo71		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
wo71		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
wo71		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
wo71		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
wo71		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi


#					-lqhyccd					\
#					-L$(ATIK_LIB_DIR)/			\
#					-latikcameras				\


######################################################################################
#pragma mark make wo102
#	this is for my William Optics 102 configuration
wo102		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
wo102		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
wo102		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
wo102		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
wo102		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-ljpeg						\
					-lqhyccd					\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi


######################################################################################
TELESCOPE_OBJECTS=											\
				$(OBJECT_DIR)alpacadriver.o					\
				$(OBJECT_DIR)alpacadriver_helper.o			\
				$(OBJECT_DIR)alpacadriver_templog.o			\
				$(OBJECT_DIR)alpaca_discovery.o				\
				$(OBJECT_DIR)alpacadriverLogging.o			\
				$(OBJECT_DIR)discoverythread.o				\
				$(OBJECT_DIR)eventlogging.o					\
				$(OBJECT_DIR)HostNames.o					\
				$(OBJECT_DIR)JsonResponse.o					\
				$(OBJECT_DIR)linuxerrors.o					\
				$(OBJECT_DIR)managementdriver.o				\
				$(OBJECT_DIR)observatory_settings.o			\
				$(OBJECT_DIR)readconfigfile.o				\
				$(OBJECT_DIR)serialport.o					\
				$(OBJECT_DIR)sidereal.o						\
				$(OBJECT_DIR)telescopedriver.o				\
				$(OBJECT_DIR)telescopedriver_comm.o			\
				$(OBJECT_DIR)telescopedriver_Rigel.o		\
				$(OBJECT_DIR)telescopedriver_servo.o		\
				$(OBJECT_DIR)cpu_stats.o					\
				$(OBJECT_DIR)helper_functions.o				\


######################################################################################
#pragma mark make rigel
rigel		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
rigel		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
rigel		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_RIGEL_
rigel		:		$(TELESCOPE_OBJECTS)		\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(TELESCOPE_OBJECTS)		\
					-lpthread					\
					-o alpacapi-rigel

######################################################################################
SERVO_OBJECTS=										\
				$(OBJECT_DIR)servo_mount_cfg.o		\
				$(OBJECT_DIR)servo_time.o			\
				$(OBJECT_DIR)servo_motion.o			\
				$(OBJECT_DIR)servo_motion_cfg.o		\
				$(OBJECT_DIR)servo_mount.o			\
				$(OBJECT_DIR)servo_observ_cfg.o		\
				$(OBJECT_DIR)servo_rc_utils.o		\
				$(OBJECT_DIR)servo_mc_core.o		\


######################################################################################
#pragma mark make servo
servo		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
servo		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
servo		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_SERVO_
servo		:		INCLUDES		+=	-I$(SRC_SERVO)
servo		:		$(TELESCOPE_OBJECTS)		\
					$(SOCKET_OBJECTS)			\
					$(SERVO_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(TELESCOPE_OBJECTS)		\
					$(SERVO_OBJECTS)			\
					-lpthread					\
					-o alpacapi-servo


######################################################################################
#pragma mark make servoimu
servoimu	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
servoimu	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
servoimu	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_SERVO_
servoimu	:		DEFINEFLAGS		+=	-D_ENABLE_IMU_
servoimu	:		INCLUDES		+=	-I$(SRC_IMU)
servoimu	:		INCLUDES		+=	-I$(SRC_SERVO)
servoimu	:		$(TELESCOPE_OBJECTS)		\
					$(SOCKET_OBJECTS)			\
					$(SERVO_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(TELESCOPE_OBJECTS)		\
					$(SERVO_OBJECTS)			\
					$(IMU_OBJECTS)				\
					-lpthread					\
					-o alpacapi-servo

######################################################################################
#pragma mark make toup
toup	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
toup	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
toup	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#toup		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#toup	:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
toup	:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
toup	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
toup	:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
toup	:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-L$(TOUP_LIB_DIR)/			\
					-ltoupcam					\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-o alpacapi

######################################################################################
#pragma mark make touppi
touppi	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
touppi	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
touppi	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#touppi		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#touppi	:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
touppi	:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
touppi	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
touppi	:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-L$(TOUP_LIB_DIR)/			\
					-ltoupcam					\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-o alpacapi



######################################################################################
#pragma mark C++ linux-x86
Release		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#Release		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
#Release		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#Release		:		DEFINEFLAGS		+=	-D_ENABLE_QHY_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
Release		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#Release		:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
#Release		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
Release		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
Release		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR)/			\
					-L$(TOUP_LIB_DIR)/			\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-ltoupcam					\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-lqhyccd					\
					-o bin/Release/alpaca



######################################################################################
#pragma mark Flir version for x86
#make flir
flir		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
flir		:		DEFINEFLAGS		+=	-D_ENABLE_FLIR_
flir		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
flir		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
flir		:		DEFINEFLAGS		+=	-D_ENABLE_IMU_
flir		:		INCLUDES		+=	-I$(SRC_IMU)
flir		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
flir		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
flir		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(IMU_OBJECTS)				\
					-lSpinnaker_C				\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-o alpacapi

######################################################################################
#pragma mark phaseone version for x86
#make phaseone
phaseone	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
phaseone	:		DEFINEFLAGS		+=	-D_ENABLE_PHASEONE_
phaseone	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
phaseone	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
phaseone	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
phaseone	:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
phaseone	:		DEFINEFLAGS		+=	-D_ENABLE_PHASEONE_
phaseone	:		INCLUDES		+=	-I$(PHASEONE_INC)
phaseone	:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(TEST_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(TEST_OBJECTS)				\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					-L$(PHASEONE_LIB)			\
					-lCameraSdkCpp				\
					-lpthread					\
					-lcfitsio					\
					-o alpacapi

#					-lusb-1.0					\
#					-ludev						\



######################################################################################
#pragma mark imu
#make imu
imu		:			DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
imu		:			DEFINEFLAGS		+=	-D_ENABLE_ASI_
imu		:			DEFINEFLAGS		+=	-D_ENABLE_FITS_
imu		:			DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
imu		:			DEFINEFLAGS		+=	-D_ENABLE_IMU_
imu		:			INCLUDES		+=	-I$(SRC_IMU)
imu		:			DEFINEFLAGS		+=	-D_USE_OPENCV_
imu		:			DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
imu		:			$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(IMU_OBJECTS)				\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(IMU_OBJECTS)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-o imu


#					-ludev						\

######################################################################################
#pragma mark nousb -C++ linux-x86
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#nousb		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
nousb		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
nousb		:		DEFINEFLAGS		+=	-D_ENABLE_SHUTTER_
nousb		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lpthread					\
					-lcfitsio					\
					-o alpacapi

######################################################################################
#pragma mark dome
#make dome
#dome		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
dome		:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
dome		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_REMOTE_
dome		:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_SHUTTER_
dome		:	DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
dome		:				$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\

				$(LINK)  								\
							$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							-lusb-1.0					\
							-lpthread					\
							-lwiringPi					\
							-o domecontroller

#							-ludev						\
#							$(ASI_CAMERA_OBJECTS)		\


######################################################################################
#pragma mark dome
#make dometest
#dometest		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
dometest		:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
dometest		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_REMOTE_
dometest		:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_SHUTTER_
dometest		:	DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
dometest		:			$(CPP_OBJECTS)				\
							$(SOCKET_OBJECTS)			\
							$(HELPER_OBJECTS)			\

				$(LINK)  								\
							$(CPP_OBJECTS)				\
							$(SOCKET_OBJECTS)			\
							$(HELPER_OBJECTS)			\
							-lpthread					\
							-o domecontroller


######################################################################################
#pragma mark ROR
#make rortest
#rortest	:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
rortest		:	DEFINEFLAGS		+=	-D_ENABLE_ROR_
rortest		:					$(ROR_OBJECTS)			\
								$(SOCKET_OBJECTS)		\

				$(LINK)  								\
							$(ROR_OBJECTS)				\
							$(SOCKET_OBJECTS)			\
							-lpthread					\
							-o ror

######################################################################################
#pragma mark rorpi
#rorpi		:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
rorpi		:	DEFINEFLAGS		+=	-D_ENABLE_ROR_
rorpi		:	DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
rorpi		:	DEFINEFLAGS		+=	-D_ENABLE_4REALY_BOARD
rorpi		:				$(ROR_OBJECTS)				\
							$(SOCKET_OBJECTS)			\

				$(LINK)  								\
							$(SOCKET_OBJECTS)			\
							$(ROR_OBJECTS)				\
							-lpthread					\
							-lwiringPi					\
							-o ror

######################################################################################
#pragma mark rorpi2
#rorpi2		:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
rorpi2		:	DEFINEFLAGS		+=	-D_ENABLE_ROR_
rorpi2		:	DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
rorpi2		:	DEFINEFLAGS		+=	-D_ENABLE_4REALY_BOARD
rorpi2		:	DEFINEFLAGS		+=	-D_TEST_DISCOVERQUERY_
rorpi2		:				$(ROR_OBJECTS)				\
							$(SOCKET_OBJECTS)			\

				$(LINK)  								\
							$(SOCKET_OBJECTS)			\
							$(ROR_OBJECTS)				\
							-lpthread					\
							-lwiringPi					\
							-o ror2

######################################################################################
#pragma mark make pi
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
pi		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
pi		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
#pi		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
pi		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
pi		:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
pi		:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR_ARM32)/	\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#pragma mark Raspberry pi - calibration
#make calib
calib		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_RPI_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
calib		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
calib		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
#calib		:		DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
calib		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lwiringPi					\
					-lcfitsio					\
					-lpthread					\
					-lusb-1.0					\
					-o alpacapi-calib

#					$(OPENCV_LINK)				\
#					$(ASI_CAMERA_OBJECTS)		\
#					-lcfitsio					\
#					-lusb-1.0					\
#					-ludev						\


######################################################################################
#pragma mark Raspberry pi - calibration
#make calibcv4
calibcv4	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_RPI_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
calibcv4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
calibcv4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
calibcv4	:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
calibcv4	:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lwiringPi					\
					-lcfitsio					\
					-lpthread					\
					-lusb-1.0					\
					-o alpacapi-calib

#					$(OPENCV_LINK)				\
#					$(ASI_CAMERA_OBJECTS)		\
#					-lcfitsio					\
#					-lusb-1.0					\
#					-ludev						\

######################################################################################
#pragma mark Alnitak - calibration
#make alnitak
alnitak		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
alnitak		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
alnitak		:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_ALNITAK_
alnitak		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(TEST_OBJECTS)				\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(TEST_OBJECTS)				\
					-lpthread					\
					-lusb-1.0					\
					-o alpacapi-alnitak





######################################################################################
#pragma mark Raspberry pi - switch
#make piswitch4
piswitch4	:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_CALIBRATION_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_4REALY_BOARD
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
#piswitch4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
#piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
piswitch4	:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
piswitch4	:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
piswitch4	:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#	Camera Objects
SONY_OBJECTS=												\
				$(OBJECT_DIR)cameradriver_SONY.o			\

######################################################################################
#make sony
sony		:		DEFINEFLAGS		+=	-D_ENABLE_SONY_
sony		:		DEFINEFLAGS		+=	-D_INCLUDE_SONY_MAIN_
sony		:		CPLUSFLAGS		+=	-fsigned-char
sony		:		CPLUSFLAGS		+=	-std=gnu++17
sony		:		CPLUSFLAGS		+=	-O3 -DNDEBUG -std=c++17
sony		:		INCLUDES		+=	-I$(SONY_INCLUDE_DIR)
sony		:		$(SONY_OBJECTS)

		$(LINK)  								\
					$(SONY_OBJECTS)				\
					-L$(SONY_LIB_DIR)			\
					-lCr_Core					\
					-o sony

######################################################################################
#pragma mark make pi64
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
pi64		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
pi64		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
pi64		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
pi64		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
#pi64		:		DEFINEFLAGS		+=	-D_ENABLE_SONY_
#pi64		:		DEFINEFLAGS		+=	-D_INCLUDE_EXIT_COMMAND_
pi64		:		CPLUSFLAGS		+=	-fsigned-char
pi64		:		CPLUSFLAGS		+=	-std=gnu++17
#pi64		:		INCLUDES		+=	-I$(SONY_INCLUDE_DIR)

pi64		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-L$(ATIK_LIB_DIR)			\
					-latikcameras				\
					-lcfitsio					\
					-lusb-1.0					\
					-lpthread					\
					-o alpacapi

#					-ludev						\
#					-L$(SONY_LIB_DIR)/			\
#					$(ZWO_EFW_OBJECTS)			\
#					-ltoupcam					\
#					-lwiringPi					\

######################################################################################
#pragma mark C++ Raspberry pi zwo only
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
pizwo		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
pizwo		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
#pizwo		:		DEFINEFLAGS		+=	-D_ENABLE_TOUP_
#pizwo		:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
pizwo		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-o alpacapi

######################################################################################
#pragma mark Management only
#make manag
manag		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
manag		:		$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					-lpthread					\
					-o alpacapi

######################################################################################
#make newt16
#pragma mark Newt 16 C++ Raspberry pi
newt16		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
#newt16		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
newt16		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
newt16		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
newt16		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
newt16		:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/ARM/x86/NoFlyCapture
newt16		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-ljpeg						\
					-lpthread					\
					-o alpacapi

#					-lwiringPi					\

######################################################################################
#pragma mark ZWO
zwo		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_DISCOVERY_QUERRY_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#zwo		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
zwo		:		DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
zwo		:			$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-ljpeg						\
					-lpthread					\
					-o alpacapi

#					-lwiringPi					\



######################################################################################
#pragma mark Switch - C++ Raspberry pi
#	make finder
finder		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
finder		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
finder		:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_

finder		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR_ARM32)/	\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-lqhyccd					\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi

######################################################################################
#pragma mark Switch - C++ Raspberry pi
#	make findercv4
findercv4		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_ASI_
findercv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
findercv4		:	DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_

findercv4		:	$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR_ARM32)/	\
					$(ASI_CAMERA_OBJECTS)		\
					$(ZWO_EFW_OBJECTS)			\
					-latikcameras				\
					-lqhyccd					\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#pragma mark Switch - C++ Raspberry pi64
piswitch64		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
piswitch64		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
#piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_PWM_SWITCH_
piswitch64		:		DEFINEFLAGS		+=	-D_ENABLE_4REALY_BOARD
piswitch64		:		CPLUSFLAGS		+=	-std=gnu++17

piswitch64		:	$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#pragma mark make shutter
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_SHUTTER_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_STATUS_SWITCH_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
shutter		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
shutter		:		DEFINEFLAGS		+=	-D_USE_OPENCV_

shutter		:		$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(LIVE_WINDOW_OBJECTS)		\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#pragma mark make shuttercv4
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_SHUTTER_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_STATUS_SWITCH_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_WIRING_PI_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
shuttercv4		:		DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
shuttercv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
shuttercv4		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_

shuttercv4		:	$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(LIVE_WINDOW_OBJECTS)		\


		$(LINK)  								\
					$(DRIVER_OBJECTS)			\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(HELPER_OBJECTS)			\
					$(OPENCV_LINK)				\
					$(ASI_CAMERA_OBJECTS)		\
					$(LIVE_WINDOW_OBJECTS)		\
					-lcfitsio					\
					-lusb-1.0					\
					-ludev						\
					-lwiringPi					\
					-lpthread					\
					-o alpacapi


######################################################################################
#pragma mark linux-x86 - No opencv
#make noopencv
#noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
#noopencv		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
noopencv		:		DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
noopencv		:		$(DRIVER_OBJECTS)			\
						$(CPP_OBJECTS)				\
						$(SOCKET_OBJECTS)			\
						$(ASI_CAMERA_OBJECTS)		\
						$(ZWO_EFW_OBJECTS)			\

		$(LINK)  									\
						$(DRIVER_OBJECTS)			\
						$(CPP_OBJECTS)				\
						$(SOCKET_OBJECTS)			\
						$(ASI_CAMERA_OBJECTS)		\
						$(ZWO_EFW_OBJECTS)			\
						-lcfitsio					\
						-ludev						\
						-lpthread					\
						-lusb-1.0					\
						-ljpeg						\
						-o alpacapi


######################################################################################
#pragma mark Debug linux-x86
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_ROTATOR_
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_SAFETYMONITOR_
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_SWITCH_
#Debug		:		DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
Debug			:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#Debug			:		DEFINEFLAGS		+=	-D_ENABLE_DOME_
Debug			:		DEFINEFLAGS		+=	-D_ENABLE_MULTICAM_
Debug			:		DEFINEFLAGS		+=	-D_ENABLE_ASI_
Debug			:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
Debug			:		DEFINEFLAGS		+=	-D_USE_OPENCV_
Debug			:		$(CPP_OBJECTS)				\
					$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(SOCKET_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR)/			\
					$(ASI_CAMERA_OBJECTS)		\
					-lusb-1.0					\
					-ludev						\
					-lpthread					\
					-latikcameras				\
					-lcfitsio					\
					-o bin/Debug/alpaca



######################################################################################
#	Camera Objects
JETSON_OBJECTS=												\
				$(OBJECT_DIR)startextrathread.o				\


######################################################################################
#pragma mark make jetson
jetson		:	DEFINEFLAGS		+=	-D_JETSON_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
jetson		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#jetson		:	DEFINEFLAGS		+=	-D_ENABLE_JPEGLIB_
#jetson		:	DEFINEFLAGS		+=	-D_ENABLE_ASI_
#jetson		:	DEFINEFLAGS		+=	-D_ENABLE_TOUP_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_FLIR_
#jetson		:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
jetson		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_LIVE_CONTROLLER_
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_STAR_SEARCH_
jetson		:	DEFINEFLAGS		+=	-D_PLATFORM_STRING_=\"Nvidia-jetson\"
jetson		:	DEFINEFLAGS		+=	-D_ENABLE_IMU_
jetson		:	INCLUDES		+=	-I$(SRC_IMU)
jetson		:	TOUP_LIB_DIR	=	$(TOUP_DIR)/linux/arm64
jetson		:				$(DRIVER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(CPP_OBJECTS)				\
							$(IMAGEPROC_OBJECTS)		\
							$(JETSON_OBJECTS)			\
							$(IMU_OBJECTS)				\
							$(LIVE_WINDOW_OBJECTS)		\


				$(LINK)  								\
							$(DRIVER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(CPP_OBJECTS)				\
							$(IMAGEPROC_OBJECTS)		\
							$(JETSON_OBJECTS)			\
							$(IMU_OBJECTS)				\
							$(LIVE_WINDOW_OBJECTS)		\
							$(OPENCV_LINK)				\
							-lcfitsio					\
							-lpthread					\
							-lSpinnaker_C				\
							-o alpacapi



######################################################################################
#pragma mark wx
#make wx
#wx			:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#wx			:	DEFINEFLAGS		+=	-D_ENABLE_DOME_
wx			:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
wx			:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_MOONLITE_
wx			:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
wx			:	DEFINEFLAGS		+=	-D_ENABLE_PI_HAT_SESNSOR_BOARD_
wx			:				$(DRIVER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\


				$(LINK)  								\
							$(DRIVER_OBJECTS)			\
							$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(ASI_CAMERA_OBJECTS)		\
							$(ZWO_EFW_OBJECTS)			\
							$(OPENCV_LINK)				\
							-lRTIMULib					\
							-lusb-1.0					\
							-lpthread					\
							-lwiringPi					\
							-o alpacapi


######################################################################################
#pragma mark smate
smate		:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
smate		:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ZWO_
smate		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
smate		:	DEFINEFLAGS		+=	-D_ENABLE_OBSERVINGCONDITIONS_
smate		:	DEFINEFLAGS		+=	-D_ENABLE_TELESCOPE_
smate		:				$(DRIVER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\

				$(LINK)  								\
							$(DRIVER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(ASI_CAMERA_OBJECTS)		\
							$(ZWO_EFW_OBJECTS)			\
							$(OPENCV_LINK)				\
							-lusb-1.0					\
							-lpthread					\
							-ludev						\
							-o alpacapi



######################################################################################
# ATIK objects
ATIK_OBJECTS=												\
				$(OBJECT_DIR)alpacadriver.o					\
				$(OBJECT_DIR)alpacadriver_helper.o			\
				$(OBJECT_DIR)alpacadriverLogging.o			\
				$(OBJECT_DIR)alpaca_discovery.o				\
				$(OBJECT_DIR)cpu_stats.o					\
				$(OBJECT_DIR)discoverythread.o				\
				$(OBJECT_DIR)json_parse.o					\
				$(OBJECT_DIR)filterwheeldriver_ATIK.o		\
				$(OBJECT_DIR)cameradriver.o					\
				$(OBJECT_DIR)cameradriverAnalysis.o			\
				$(OBJECT_DIR)cameradriver_fits.o			\
				$(OBJECT_DIR)cameradriver_save.o			\
				$(OBJECT_DIR)cameradriver_opencv.o			\
				$(OBJECT_DIR)cameradriver_jpeg.o			\
				$(OBJECT_DIR)cameradriver_livewindow.o		\
				$(OBJECT_DIR)cameradriver_png.o				\
				$(OBJECT_DIR)cameradriver_ATIK.o			\
				$(OBJECT_DIR)filterwheeldriver.o			\
				$(OBJECT_DIR)moonphase.o					\
				$(OBJECT_DIR)MoonRise.o						\
				$(OBJECT_DIR)julianTime.o					\


######################################################################################
#pragma mark ATIK Linux
#	make atik
atik	:		ATIK_LIB_DIR	=	$(ATIK_LIB_MASTER_DIR)/linux/x64/NoFlyCapture
atik	:		DEFINEFLAGS		+=	-D_ENABLE_ATIK_
atik	:		DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
atik	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_ATIK_
atik	:		DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
atik	:		DEFINEFLAGS		+=	-D_ENABLE_FITS_
atik	:		DEFINEFLAGS		+=	-D_USE_OPENCV_

atik	:					$(DRIVER_OBJECTS)			\
							$(CPP_OBJECTS)				\
							$(LIVE_WINDOW_OBJECTS)		\
							$(SOCKET_OBJECTS)			\


		$(LINK)  								\
					$(DRIVER_OBJECTS)			\
					$(CPP_OBJECTS)				\
					$(LIVE_WINDOW_OBJECTS)		\
					$(SOCKET_OBJECTS)			\
					$(OPENCV_LINK)				\
					-L$(ATIK_LIB_DIR)/			\
					-latikcameras				\
					-ludev						\
					-lusb-1.0					\
					-lpthread					\
					-lcfitsio					\
					-o atik


######################################################################################
#pragama mark make client client
client	:	DEFINEFLAGS		+=	-D_CLIENT_MAIN_
client	:			$(CLIENT_OBJECTS)

				$(LINK)  										\
							$(CLIENT_OBJECTS)					\
							-o client

#client	:	DEFINEFLAGS		+=	-D_DEBUG_PARSER_

######################################################################################
MANDELBROT_OBJECTS=												\
				$(OBJECT_DIR)mandelbrot.o						\

######################################################################################
CONTROLLER_BASE_OBJECTS=										\
				$(OBJECT_DIR)alpacadriver_helper.o				\
				$(OBJECT_DIR)commoncolor.o						\
				$(OBJECT_DIR)controller.o						\
				$(OBJECT_DIR)controllerAlpaca.o					\
				$(OBJECT_DIR)discoverythread.o					\
				$(OBJECT_DIR)HostNames.o						\
				$(OBJECT_DIR)json_parse.o						\
				$(OBJECT_DIR)opencv_utils.o						\
				$(OBJECT_DIR)sendrequest_lib.o					\
				$(OBJECT_DIR)windowtab.o						\
				$(OBJECT_DIR)windowtab_about.o					\
				$(OBJECT_DIR)windowtab_image.o					\

#				$(OBJECT_DIR)controller_image.o					\
#				$(OBJECT_DIR)controllerClient.o					\

######################################################################################
CONTROLLER_OBJECTS=												\
				$(OBJECT_DIR)alpacadriver_helper.o				\
				$(OBJECT_DIR)controller_main.o					\
				$(OBJECT_DIR)controller.o						\
				$(OBJECT_DIR)controllerAlpaca.o					\
				$(OBJECT_DIR)controller_focus.o					\
				$(OBJECT_DIR)controller_focus_generic.o			\
				$(OBJECT_DIR)controller_switch.o				\
				$(OBJECT_DIR)controller_camera.o				\
				$(OBJECT_DIR)controllerImageArray.o				\
				$(OBJECT_DIR)controller_cam_normal.o			\
				$(OBJECT_DIR)controller_dome.o					\
				$(OBJECT_DIR)controller_dome_common.o			\
				$(OBJECT_DIR)controller_filterwheel.o			\
				$(OBJECT_DIR)controller_image.o					\
				$(OBJECT_DIR)controller_ml_nc.o					\
				$(OBJECT_DIR)controller_ml_single.o				\
				$(OBJECT_DIR)controller_obsconditions.o			\
				$(OBJECT_DIR)controller_rotator.o				\
				$(OBJECT_DIR)controller_usb.o					\
				$(OBJECT_DIR)cpu_stats.o						\
				$(OBJECT_DIR)helper_functions.o					\
				$(OBJECT_DIR)linuxerrors.o						\
				$(OBJECT_DIR)opencv_utils.o						\
				$(OBJECT_DIR)windowtab.o						\
				$(OBJECT_DIR)windowtab_about.o					\
				$(OBJECT_DIR)windowtab_auxmotor.o				\
				$(OBJECT_DIR)windowtab_camera.o					\
				$(OBJECT_DIR)windowtab_camsettings.o			\
				$(OBJECT_DIR)windowtab_capabilities.o			\
				$(OBJECT_DIR)windowtab_config.o					\
				$(OBJECT_DIR)windowtab_dome.o					\
				$(OBJECT_DIR)windowtab_drvrInfo.o				\
				$(OBJECT_DIR)windowtab_filelist.o				\
				$(OBJECT_DIR)windowtab_graphs.o					\
				$(OBJECT_DIR)windowtab_image.o					\
				$(OBJECT_DIR)windowtab_ml_single.o				\
				$(OBJECT_DIR)windowtab_nitecrawler.o			\
				$(OBJECT_DIR)windowtab_switch.o					\
				$(OBJECT_DIR)windowtab_slit.o					\
				$(OBJECT_DIR)windowtab_slitgraph.o				\
				$(OBJECT_DIR)windowtab_usb.o					\
				$(OBJECT_DIR)moonlite_com.o						\
				$(OBJECT_DIR)nitecrawler_image.o				\
				$(OBJECT_DIR)discovery_lib.o					\
				$(OBJECT_DIR)json_parse.o						\
				$(OBJECT_DIR)serialport.o						\
				$(OBJECT_DIR)commoncolor.o						\
				$(OBJECT_DIR)sendrequest_lib.o					\

VIDEO_OBJECTS=													\
				$(OBJECT_DIR)controller.o						\
				$(OBJECT_DIR)controllerAlpaca.o					\
				$(OBJECT_DIR)controller_camera.o				\
				$(OBJECT_DIR)controller_video.o					\
				$(OBJECT_DIR)controller_preview.o				\
				$(OBJECT_DIR)discovery_lib.o					\
				$(OBJECT_DIR)json_parse.o						\
				$(OBJECT_DIR)commoncolor.o						\
				$(OBJECT_DIR)sendrequest_lib.o					\
				$(OBJECT_DIR)windowtab.o						\
				$(OBJECT_DIR)windowtab_about.o					\
				$(OBJECT_DIR)windowtab_video.o					\
				$(OBJECT_DIR)windowtab_preview.o				\
				$(OBJECT_DIR)cpu_stats.o						\


PREVIEW_OBJECTS=												\
				$(OBJECT_DIR)commoncolor.o						\
				$(OBJECT_DIR)controller.o						\
				$(OBJECT_DIR)controllerAlpaca.o					\
				$(OBJECT_DIR)controller_camera.o				\
				$(OBJECT_DIR)controller_main.o					\
				$(OBJECT_DIR)controller_preview.o				\
				$(OBJECT_DIR)cpu_stats.o						\
				$(OBJECT_DIR)discovery_lib.o					\
				$(OBJECT_DIR)json_parse.o						\
				$(OBJECT_DIR)sendrequest_lib.o					\
				$(OBJECT_DIR)windowtab.o						\
				$(OBJECT_DIR)windowtab_about.o					\
				$(OBJECT_DIR)windowtab_preview.o				\

#				$(OBJECT_DIR)controller_cam_normal.o			\


######################################################################################
#pragma mark mandelbrot
mandelbrot	:	DEFINEFLAGS		+=	-D_INCLUDE_MAIN_
mandelbrot	:			$(MANDELBROT_OBJECTS)

				$(LINK)  										\
							$(MANDELBROT_OBJECTS)				\
							$(OPENCV_LINK)						\
							-o mandlebrot;



######################################################################################
#make camera
#pragma mark camera-controller
camera		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
camera		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
camera		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
camera		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
camera		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
camera		:			$(CONTROLLER_OBJECTS)					\

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o camera


######################################################################################
#make camera
#pragma mark camera-controller
cameracv4		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
cameracv4		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
cameracv4		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
cameracv4		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
cameracv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
cameracv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
cameracv4		:	OPENCV_COMPILE	=	$(shell pkg-config --cflags opencv4)
cameracv4		:	OPENCV_LINK		=	$(shell pkg-config --libs opencv4)
cameracv4		:	$(CONTROLLER_OBJECTS)					\

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o camera

######################################################################################
#pragma mark dome-controller
#	make domectrl
domectrl		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
domectrl		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
domectrl		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
#domectrl		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
domectrl		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
domectrl		:	DEFINEFLAGS		+=	-D_USE_OPENCV_


domectrl		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o domectrl

######################################################################################
#pragma mark dome-controller
#	make domectrlcv4
domectrlcv4		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
domectrlcv4		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
domectrlcv4		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
#domectrlcv4		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
domectrlcv4		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
domectrlcv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
domectrlcv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_


domectrlcv4		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o domectrl

######################################################################################
#pragma mark focuser-controller
#	make focuser
focuser		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
focuser		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
focuser		:	DEFINEFLAGS		+=	-D_ENABLE_USB_FOCUSERS_
focuser		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
focuser		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
focuser		:	DEFINEFLAGS		+=	-D_USE_OPENCV_

focuser		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o focuser

######################################################################################
#pragma mark focuser-controller
#	make focuser
focusercv4		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
focusercv4		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
focusercv4		:	DEFINEFLAGS		+=	-D_ENABLE_USB_FOCUSERS_
focusercv4		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
focusercv4		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
focusercv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
focusercv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
focusercv4		:	OPENCV_COMPILE	=	$(shell pkg-config --cflags opencv4)
focusercv4		:	OPENCV_LINK		=	$(shell pkg-config --libs opencv4)

focusercv4		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o focuser


######################################################################################
#make switch
#pragma mark switch-controller
switch		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
switch		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
switch		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
switch		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
switch		:	DEFINEFLAGS		+=	-D_USE_OPENCV_

switch		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o switch

######################################################################################
#make switch
#pragma mark switch-controller
switchcv4		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
switchcv4		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
switchcv4		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
switchcv4		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
switchcv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
switchcv4		:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
switchcv4		:	OPENCV_COMPILE	=	$(shell pkg-config --cflags opencv4)
switchcv4		:	OPENCV_LINK		=	$(shell pkg-config --libs opencv4)

switchcv4		:			$(CONTROLLER_OBJECTS)

				$(LINK)  										\
							$(CONTROLLER_OBJECTS)				\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o switch


######################################################################################
# SkyTravel objects

SRC_SKYTRAVEL=./src_skytravel/
SKYTRAVEL_OBJECTS=											\
				$(OBJECT_DIR)aavso_data.o					\
				$(OBJECT_DIR)AsteroidData.o					\
				$(OBJECT_DIR)ConstellationData.o			\
				$(OBJECT_DIR)controller_camera.o			\
				$(OBJECT_DIR)controllerImageArray.o			\
				$(OBJECT_DIR)controller_cam_normal.o		\
				$(OBJECT_DIR)controller_constList.o			\
				$(OBJECT_DIR)controller_covercalib.o		\
				$(OBJECT_DIR)controller_dome.o				\
				$(OBJECT_DIR)controller_dome_common.o		\
				$(OBJECT_DIR)controller_filterwheel.o		\
				$(OBJECT_DIR)controller_focus.o				\
				$(OBJECT_DIR)controller_focus_generic.o		\
				$(OBJECT_DIR)controller_image.o				\
				$(OBJECT_DIR)controller_ml_nc.o				\
				$(OBJECT_DIR)controller_ml_single.o			\
				$(OBJECT_DIR)controller_obsconditions.o		\
				$(OBJECT_DIR)controller_rotator.o			\
				$(OBJECT_DIR)controller_skytravel.o			\
				$(OBJECT_DIR)controller_slit.o				\
				$(OBJECT_DIR)controller_switch.o			\
				$(OBJECT_DIR)controller_starlist.o			\
				$(OBJECT_DIR)controller_telescope.o			\
				$(OBJECT_DIR)cpu_stats.o					\
				$(OBJECT_DIR)eph.o							\
				$(OBJECT_DIR)fits_opencv.o					\
				$(OBJECT_DIR)helper_functions.o				\
				$(OBJECT_DIR)HipparcosCatalog.o				\
				$(OBJECT_DIR)moonlite_com.o					\
				$(OBJECT_DIR)julianTime.o					\
				$(OBJECT_DIR)linuxerrors.o					\
				$(OBJECT_DIR)moonphase.o					\
				$(OBJECT_DIR)NGCcatalog.o					\
				$(OBJECT_DIR)nitecrawler_image.o			\
				$(OBJECT_DIR)observatory_settings.o			\
				$(OBJECT_DIR)OpenNGC.o						\
				$(OBJECT_DIR)polaralign.o					\
				$(OBJECT_DIR)readconfigfile.o				\
				$(OBJECT_DIR)RemoteImage.o					\
				$(OBJECT_DIR)sidereal.o						\
				$(OBJECT_DIR)StarCatalogHelper.o			\
				$(OBJECT_DIR)skytravel_main.o				\
				$(OBJECT_DIR)SAO_stardata.o					\
				$(OBJECT_DIR)StarData.o						\
				$(OBJECT_DIR)SkyTravelTimeRoutines.o		\
				$(OBJECT_DIR)serialport.o					\
				$(OBJECT_DIR)windowtab_alpacalist.o			\
				$(OBJECT_DIR)windowtab_auxmotor.o			\
				$(OBJECT_DIR)windowtab_camera.o				\
				$(OBJECT_DIR)windowtab_camsettings.o		\
				$(OBJECT_DIR)windowtab_capabilities.o		\
				$(OBJECT_DIR)windowtab_config.o				\
				$(OBJECT_DIR)windowtab_constList.o			\
				$(OBJECT_DIR)windowtab_covercalib.o			\
				$(OBJECT_DIR)windowtab_cpustats.o			\
				$(OBJECT_DIR)windowtab_deviceselect.o		\
				$(OBJECT_DIR)windowtab_dome.o				\
				$(OBJECT_DIR)windowtab_drvrInfo.o			\
				$(OBJECT_DIR)windowtab_filelist.o			\
				$(OBJECT_DIR)windowtab_filterwheel.o		\
				$(OBJECT_DIR)windowtab_fov.o				\
				$(OBJECT_DIR)windowtab_graphs.o				\
				$(OBJECT_DIR)windowtab_iplist.o				\
				$(OBJECT_DIR)windowtab_ml_single.o			\
				$(OBJECT_DIR)windowtab_moon.o				\
				$(OBJECT_DIR)windowtab_mount.o				\
				$(OBJECT_DIR)windowtab_nitecrawler.o		\
				$(OBJECT_DIR)windowtab_obscond.o			\
				$(OBJECT_DIR)windowtab_RemoteData.o			\
				$(OBJECT_DIR)windowtab_rotator.o			\
				$(OBJECT_DIR)windowtab_slit.o				\
				$(OBJECT_DIR)windowtab_slitgraph.o			\
				$(OBJECT_DIR)windowtab_skytravel.o			\
				$(OBJECT_DIR)windowtab_starlist.o			\
				$(OBJECT_DIR)windowtab_STsettings.o			\
				$(OBJECT_DIR)windowtab_switch.o				\
				$(OBJECT_DIR)windowtab_telescope.o			\
				$(OBJECT_DIR)windowtab_teleSettings.o		\
				$(OBJECT_DIR)YaleStarCatalog.o				\


#	5/27/2022	Gaia data no longer used, using GaiaSQL instead
#				$(OBJECT_DIR)GaiaData.o						\

######################################################################################
GAIA_SQL_OBJECTS=											\
				$(OBJECT_DIR)GaiaSQL.o						\
				$(OBJECT_DIR)controller_GaiaRemote.o		\
				$(OBJECT_DIR)windowtab_GaiaRemote.o			\


######################################################################################
#make skytravel
#pragma mark skytravel
sky		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
sky		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_SKYTRAVEL_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_OBS_CONDITIONS_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_ROTATOR_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_TELESCOPE_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
sky		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_CONTROLLER_
sky		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
sky		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#sky		:	DEFINEFLAGS		+=	-D_ENABLE_ASTERIODS_
sky		:	INCLUDES		+=	-I$(SRC_SKYTRAVEL)
sky		:				$(SKYTRAVEL_OBJECTS)					\
						$(CONTROLLER_BASE_OBJECTS)				\


				$(LINK)  										\
							$(SKYTRAVEL_OBJECTS)				\
							$(CONTROLLER_BASE_OBJECTS)			\
							$(OPENCV_LINK)						\
							-lpthread							\
							-lcfitsio							\
							-o skytravel

######################################################################################
#make skycv4
#pragma mark skytravel
skycv4			:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_SKYTRAVEL_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_OBS_CONDITIONS_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_ROTATOR_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_TELESCOPE_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
skycv4			:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_CONTROLLER_
skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
skycv4			:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#skycv4			:	DEFINEFLAGS		+=	-D_ENABLE_ASTERIODS_
skycv4			:	DEFINEFLAGS		+=	-D_USE_OPENCV_
skycv4			:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
skycv4			:	INCLUDES		+=	-I$(SRC_SKYTRAVEL)
#skycv4			:	OPENCV_COMPILE	=	$(shell pkg-config --cflags opencv4)
#skycv4			:	OPENCV_LINK		=	$(shell pkg-config --libs opencv4)
skycv4			:		$(SKYTRAVEL_OBJECTS)					\
						$(CONTROLLER_BASE_OBJECTS)				\


				$(LINK)  										\
							$(SKYTRAVEL_OBJECTS)				\
							$(CONTROLLER_BASE_OBJECTS)			\
							-L/usr/local/lib					\
							$(OPENCV_LINK)						\
							-lpthread							\
							-lcfitsio							\
							-o skytravel

######################################################################################
#make skycv4sql
#pragma mark skytravel
skycv4sql			:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_SKYTRAVEL_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_OBS_CONDITIONS_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_ROTATOR_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_TELESCOPE_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
skycv4sql			:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_CONTROLLER_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
skycv4sql			:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
#skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_ASTERIODS_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_SQL_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_GAIA_
skycv4sql			:	DEFINEFLAGS		+=	-D_USE_OPENCV_
skycv4sql			:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
skycv4sql			:	DEFINEFLAGS		+=	-D_ENABLE_CPU_STATS_
skycv4sql			:	DEFINEFLAGS		+=	-D_SQL_$(SQL_VERSION)
skycv4sql			:	INCLUDES		+=	-I$(SRC_SKYTRAVEL)

skycv4sql			:	$(SKYTRAVEL_OBJECTS)					\
						$(CONTROLLER_BASE_OBJECTS)				\
						$(GAIA_SQL_OBJECTS)						\


				$(LINK)  										\
							$(SKYTRAVEL_OBJECTS)				\
							$(CONTROLLER_BASE_OBJECTS)			\
							$(GAIA_SQL_OBJECTS)					\
							-L/usr/local/lib					\
							$(OPENCV_LINK)						\
							-l$(SQL_VERSION)					\
							-lpthread							\
							-lcfitsio							\
							-o skytravel




######################################################################################
#make skysql
#pragma mark camera-controller
skysql		:	DEFINEFLAGS		+=	-D_USE_OPENCV_
skysql		:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_SKYTRAVEL_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_OBS_CONDITIONS_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_ROTATOR_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_TELESCOPE_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
skysql		:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_CONTROLLER_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
skysql		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_ASTERIODS_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_SQL_
skysql		:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_GAIA_
skysql		:	INCLUDES		+=	-I$(SRC_SKYTRAVEL)

skysql		:				$(SKYTRAVEL_OBJECTS)				\
						$(GAIA_SQL_OBJECTS)					\
						$(CONTROLLER_BASE_OBJECTS)			\


				$(LINK)  									\
						$(SKYTRAVEL_OBJECTS)				\
						$(GAIA_SQL_OBJECTS)					\
						$(CONTROLLER_BASE_OBJECTS)			\
						$(OPENCV_LINK)						\
						-lpthread							\
						-l$(SQL_VERSION)					\
						-lcfitsio							\
						-o skytravel


######################################################################################
SPECTROGRAPH_OBJECTS=										\
				$(OBJECT_DIR)spectrodriver.o				\
				$(OBJECT_DIR)spectrodrvr_usis.o				\
				$(OBJECT_DIR)controller_spectrograph.o		\
				$(OBJECT_DIR)filterwheeldriver.o			\
				$(OBJECT_DIR)filterwheeldriver_usis.o		\
				$(OBJECT_DIR)focuserdriver.o				\
				$(OBJECT_DIR)focuserdriver_USIS.o			\
				$(OBJECT_DIR)windowtab_spectro.o			\
				$(OBJECT_DIR)usis_communications.o			\

#				$(OBJECT_DIR)cameradriver.o					\
#				$(OBJECT_DIR)cameradriver_sim.o				\
#				$(OBJECT_DIR)cameradriver_save.o			\
#				$(OBJECT_DIR)cameradriverAnalysis.o			\


SRC_SPECTROGRAPH=./src_spectrograph/


######################################################################################
#	make spectro
spectro		:	DEFINEFLAGS		+=	-D_ENABLE_SPECTROGRAPH_
spectro		:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_
spectro		:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_USIS_
spectro		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_
spectro		:	DEFINEFLAGS		+=	-D_ENABLE_FOCUSER_USIS_
spectro		:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
spectro		:	INCLUDES		+=	-I$(SRC_SPECTROGRAPH)
spectro		:				$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(SPECTROGRAPH_OBJECTS)		\

				$(LINK)  								\
							$(CPP_OBJECTS)				\
							$(HELPER_OBJECTS)			\
							$(SOCKET_OBJECTS)			\
							$(SPECTROGRAPH_OBJECTS)			\
							-lpthread					\
							-o spectro

#spectro		:	DEFINEFLAGS		+=	-D_ENABLE_CAMERA_
#spectro		:	DEFINEFLAGS		+=	-D_SIMULATE_CAMERA_


######################################################################################
#make sss
#pragma mark skytravel
sss			:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_SKYTRAVEL_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_DOME_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_FOCUSERS_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_IMAGE_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_OBS_CONDITIONS_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_ROTATOR_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SWITCHES_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_SPECTROGRAPH_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_TELESCOPE_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_FITS_
sss			:	DEFINEFLAGS		+=	-D_CONTROLLER_USES_ALPACA_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_FILTERWHEEL_CONTROLLER_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_SLIT_TRACKER_
sss			:	DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_SQL_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_REMOTE_GAIA_
sss			:	DEFINEFLAGS		+=	-D_USE_OPENCV_
sss			:	DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
sss			:	DEFINEFLAGS		+=	-D_ENABLE_CPU_STATS_
sss			:	DEFINEFLAGS		+=	-D_SQL_$(SQL_VERSION)
sss			:	INCLUDES		+=	-I$(SRC_SKYTRAVEL)
sss			:	INCLUDES		+=	-I$(SRC_SPECTROGRAPH)

sss			:			$(SKYTRAVEL_OBJECTS)				\
						$(CONTROLLER_BASE_OBJECTS)			\
						$(GAIA_SQL_OBJECTS)					\
						$(SPECTROGRAPH_OBJECTS)				\


			$(LINK)  										\
						$(SKYTRAVEL_OBJECTS)				\
						$(CONTROLLER_BASE_OBJECTS)			\
						$(GAIA_SQL_OBJECTS)					\
						$(SPECTROGRAPH_OBJECTS)				\
						-L/usr/local/lib					\
						$(OPENCV_LINK)						\
						-l$(SQL_VERSION)					\
						-lpthread							\
						-lcfitsio							\
						-o skytravel


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)spectrodriver.o :		$(SRC_SPECTROGRAPH)spectrodriver.cpp	\
									$(SRC_SPECTROGRAPH)spectrodriver.h		\
									Makefile
	$(COMPILEPLUS) $(INCLUDES)		$(SRC_SPECTROGRAPH)spectrodriver.cpp -o$(OBJECT_DIR)spectrodriver.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)spectrodrvr_usis.o :	$(SRC_SPECTROGRAPH)spectrodrvr_usis.cpp	\
									$(SRC_SPECTROGRAPH)spectrodrvr_usis.h	\
									$(SRC_SPECTROGRAPH)spectrodriver.h		\
									Makefile
	$(COMPILEPLUS) $(INCLUDES)		$(SRC_SPECTROGRAPH)spectrodrvr_usis.cpp -o$(OBJECT_DIR)spectrodrvr_usis.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_spectrograph.o :	$(SRC_SPECTROGRAPH)controller_spectrograph.cpp		\
											$(SRC_SPECTROGRAPH)controller_spectrograph.h		\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_SPECTROGRAPH)controller_spectrograph.cpp -o$(OBJECT_DIR)controller_spectrograph.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)filterwheeldriver_usis.o :		$(SRC_SPECTROGRAPH)filterwheeldriver_usis.cpp		\
											$(SRC_SPECTROGRAPH)filterwheeldriver_usis.h			\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_SPECTROGRAPH)filterwheeldriver_usis.cpp -o$(OBJECT_DIR)filterwheeldriver_usis.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)focuserdriver_USIS.o :			$(SRC_SPECTROGRAPH)focuserdriver_USIS.cpp		\
											$(SRC_SPECTROGRAPH)focuserdriver_USIS.h			\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_SPECTROGRAPH)focuserdriver_USIS.cpp -o$(OBJECT_DIR)focuserdriver_USIS.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_spectro.o :			$(SRC_SPECTROGRAPH)windowtab_spectro.cpp	\
											$(SRC_SPECTROGRAPH)windowtab_spectro.h		\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_SPECTROGRAPH)windowtab_spectro.cpp -o$(OBJECT_DIR)windowtab_spectro.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)usis_communications.o :		$(SRC_SPECTROGRAPH)usis_communications.cpp	\
											$(SRC_SPECTROGRAPH)usis_communications.h	\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_SPECTROGRAPH)usis_communications.cpp -o$(OBJECT_DIR)usis_communications.o


######################################################################################
NETTEST_OBJECTS=												\
				$(OBJECT_DIR)cpu_stats.o						\
				$(OBJECT_DIR)commoncolor.o						\
				$(OBJECT_DIR)controller_main.o					\
				$(OBJECT_DIR)controller.o						\
				$(OBJECT_DIR)controller_nettest.o				\
				$(OBJECT_DIR)controllerAlpaca.o					\
				$(OBJECT_DIR)discovery_lib.o					\
				$(OBJECT_DIR)helper_functions.o					\
				$(OBJECT_DIR)json_parse.o						\
				$(OBJECT_DIR)linuxerrors.o						\
				$(OBJECT_DIR)sendrequest_lib.o					\
				$(OBJECT_DIR)windowtab.o						\
				$(OBJECT_DIR)windowtab_about.o					\
				$(OBJECT_DIR)windowtab_nettest.o				\


######################################################################################
FITSVIEW_OBJECTS=												\
				$(OBJECT_DIR)fitsview.o							\
				$(OBJECT_DIR)fits_opencv.o						\


DUMPFITS_OBJECTS=												\
				$(OBJECT_DIR)dumpfits.o							\

######################################################################################
#pragma mark make fitsview
fitsview	:		$(FITSVIEW_OBJECTS)


				$(LINK)  										\
							$(FITSVIEW_OBJECTS)					\
							$(OPENCV_LINK)						\
							-lcfitsio							\
							-lm									\
							-o fitsview

######################################################################################
#pragma mark make dumpfits
dumpfits	:		$(DUMPFITS_OBJECTS)


				$(LINK)  										\
							$(DUMPFITS_OBJECTS)					\
							-lcfitsio							\
							-o dumpfits


######################################################################################
#pragma mark make fitsviewcv4
fitsviewcv4	:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_
fitsviewcv4	:		$(FITSVIEW_OBJECTS)


				$(LINK)  										\
							$(FITSVIEW_OBJECTS)					\
							$(OPENCV_LINK)						\
							-lcfitsio							\
							-lm									\
							-o fitsview

######################################################################################
#pragma mark make net
SRC_NETTEST=./src_nettest/

net		:		DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
net		:		DEFINEFLAGS		+=	-D_ENABLE_NET_TEST_
net		:		DEFINEFLAGS		+=	-D_INCLUDE_MILLIS_
net		:		INCLUDES		+=	-I$(SRC_NETTEST)
net		:		DEFINEFLAGS		+=	-D_USE_OPENCV_
net		:		DEFINEFLAGS		+=	-D_USE_OPENCV_CPP_

net		:			$(NETTEST_OBJECTS)

				$(LINK)  										\
							$(NETTEST_OBJECTS)					\
							$(OPENCV_LINK)						\
							-lpthread							\
							-o nettest


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_nettest.o :		$(SRC_NETTEST)controller_nettest.cpp		\
										$(SRC_NETTEST)controller_nettest.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_NETTEST)controller_nettest.cpp -o$(OBJECT_DIR)controller_nettest.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_nettest.o :		$(SRC_NETTEST)windowtab_nettest.cpp		\
										$(SRC_NETTEST)windowtab_nettest.h		\
										$(SRC_DIR)windowtab.h					\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_NETTEST)windowtab_nettest.cpp -o$(OBJECT_DIR)windowtab_nettest.o


######################################################################################
#pragma mark video-controller
video			:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
video			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_VIDEO_
video			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_
video			:	DEFINEFLAGS		+=	-D_VIDEO_CONTROLLER_WORK_


video			:			$(VIDEO_OBJECTS)

				$(LINK)  										\
							$(VIDEO_OBJECTS)					\
							$(OPENCV_LINK)						\
							-o video


######################################################################################
#pragma mark preview-controller
#make preview
preview			:	DEFINEFLAGS		+=	-D_INCLUDE_CTRL_MAIN_
preview			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_PREVIEW_
preview			:	DEFINEFLAGS		+=	-D_ENABLE_CTRL_CAMERA_

preview			:			$(PREVIEW_OBJECTS)

				$(LINK)  										\
							$(PREVIEW_OBJECTS)					\
							$(OPENCV_LINK)						\
							-o preview


######################################################################################
#pragma mark clean
#	make clean
clean:
	rm -vf $(OBJECT_DIR)*.o



######################################################################################
$(OBJECT_DIR)socket_listen.o : $(SRC_DIR)socket_listen.c $(SRC_DIR)socket_listen.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)socket_listen.c -o$(OBJECT_DIR)socket_listen.o

$(OBJECT_DIR)JsonResponse.o : $(SRC_DIR)JsonResponse.c $(SRC_DIR)JsonResponse.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)JsonResponse.c -o$(OBJECT_DIR)JsonResponse.o


$(OBJECT_DIR)eventlogging.o : $(SRC_DIR)eventlogging.c $(SRC_DIR)eventlogging.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)eventlogging.c -o$(OBJECT_DIR)eventlogging.o

######################################################################################
$(OBJECT_DIR)readconfigfile.o : $(SRC_DIR)readconfigfile.c $(SRC_DIR)readconfigfile.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)readconfigfile.c -o$(OBJECT_DIR)readconfigfile.o


######################################################################################
# CPP objects
$(OBJECT_DIR)alpacadriver.o :			$(SRC_DIR)alpacadriver.cpp			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)alpacadriver.cpp -o$(OBJECT_DIR)alpacadriver.o

$(OBJECT_DIR)alpacadriver_helper.o :	$(SRC_DIR)alpacadriver_helper.c			\
										$(SRC_DIR)alpacadriver_helper.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)alpacadriver_helper.c -o$(OBJECT_DIR)alpacadriver_helper.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)alpaca_discovery.o :		$(SRC_DIR)alpaca_discovery.cpp		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)alpaca_discovery.cpp -o$(OBJECT_DIR)alpaca_discovery.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)alpacadriver_templog.o :	$(SRC_DIR)alpacadriver_templog.cpp		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)alpacadriver_templog.cpp -o$(OBJECT_DIR)alpacadriver_templog.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)alpacadriverLogging.o :	$(SRC_DIR)alpacadriverLogging.cpp	\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)alpacadriverLogging.cpp -o$(OBJECT_DIR)alpacadriverLogging.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver.o :			$(SRC_DIR)cameradriver.cpp			\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver.cpp -o$(OBJECT_DIR)cameradriver.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriverAnalysis.o :	$(SRC_DIR)cameradriverAnalysis.cpp	\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriverAnalysis.cpp -o$(OBJECT_DIR)cameradriverAnalysis.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_fits.o :		$(SRC_DIR)cameradriver_fits.cpp		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_fits.cpp -I$(SRC_MOONRISE) -o$(OBJECT_DIR)cameradriver_fits.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_ASI.o :		$(SRC_DIR)cameradriver_ASI.cpp		\
										$(SRC_DIR)cameradriver_ASI.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_ASI.cpp -o$(OBJECT_DIR)cameradriver_ASI.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_ATIK.o :		$(SRC_DIR)cameradriver_ATIK.cpp		\
										$(SRC_DIR)cameradriver_ATIK.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_ATIK.cpp -o$(OBJECT_DIR)cameradriver_ATIK.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)filterwheeldriver_ATIK.o :	$(SRC_DIR)filterwheeldriver_ATIK.cpp	\
										$(SRC_DIR)filterwheeldriver_ATIK.h		\
										$(SRC_DIR)filterwheeldriver.h			\
										$(SRC_DIR)alpacadriver.h				\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)filterwheeldriver_ATIK.cpp -o$(OBJECT_DIR)filterwheeldriver_ATIK.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_QHY.o :		$(SRC_DIR)cameradriver_QHY.cpp		\
										$(SRC_DIR)cameradriver_QHY.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_QHY.cpp -o$(OBJECT_DIR)cameradriver_QHY.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_QSI.o :		$(SRC_DIR)cameradriver_QSI.cpp		\
										$(SRC_DIR)cameradriver_QSI.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_QSI.cpp -o$(OBJECT_DIR)cameradriver_QSI.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_FLIR.o :		$(SRC_DIR)cameradriver_FLIR.cpp		\
										$(SRC_DIR)cameradriver_FLIR.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_FLIR.cpp -o$(OBJECT_DIR)cameradriver_FLIR.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_livewindow.o :$(SRC_DIR)cameradriver_livewindow.cpp	\
									 	$(SRC_DIR)cameradriver.h				\
										$(SRC_DIR)alpacadriver.h				\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_livewindow.cpp -o$(OBJECT_DIR)cameradriver_livewindow.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_PhaseOne.o 	:$(SRC_DIR)cameradriver_PhaseOne.cpp	\
									 	$(SRC_DIR)cameradriver_PhaseOne.h		\
									 	$(SRC_DIR)cameradriver.h				\
										$(SRC_DIR)alpacadriver.h				\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_PhaseOne.cpp -o$(OBJECT_DIR)cameradriver_PhaseOne.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_save.o :		$(SRC_DIR)cameradriver_save.cpp		\
									 	$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_save.cpp -o$(OBJECT_DIR)cameradriver_save.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_sim.o :		$(SRC_DIR)cameradriver_sim.cpp		\
									 	$(SRC_DIR)cameradriver_sim.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_sim.cpp -o$(OBJECT_DIR)cameradriver_sim.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_opencv.o :	$(SRC_DIR)cameradriver_opencv.cpp	\
									 	$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_opencv.cpp -o$(OBJECT_DIR)cameradriver_opencv.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_TOUP.o :		$(SRC_DIR)cameradriver_TOUP.cpp		\
									 	$(SRC_DIR)cameradriver_TOUP.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_TOUP.cpp -o$(OBJECT_DIR)cameradriver_TOUP.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_jpeg.o :		$(SRC_DIR)cameradriver_jpeg.cpp 	\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_jpeg.cpp -o$(OBJECT_DIR)cameradriver_jpeg.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_png.o :		$(SRC_DIR)cameradriver_png.cpp 		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_png.cpp -o$(OBJECT_DIR)cameradriver_png.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cameradriver_SONY.o :		$(SRC_DIR)cameradriver_SONY.cpp 	\
										$(SRC_DIR)cameradriver_SONY.h		\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)cameradriver_SONY.cpp -o$(OBJECT_DIR)cameradriver_SONY.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)multicam.o :				$(SRC_DIR)multicam.cpp				\
										$(SRC_DIR)multicam.h				\
										$(SRC_DIR)cameradriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)multicam.cpp -o$(OBJECT_DIR)multicam.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)domedriver.o :				$(SRC_DIR)domedriver.cpp			\
										$(SRC_DIR)domedriver.h				\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)domedriver.cpp -o$(OBJECT_DIR)domedriver.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)domeshutter.o :			$(SRC_DIR)domeshutter.cpp			\
										$(SRC_DIR)domedriver.h				\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)domeshutter.cpp -o$(OBJECT_DIR)domeshutter.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)domedriver_rpi.o :			$(SRC_DIR)domedriver_rpi.cpp		\
										$(SRC_DIR)domedriver.h				\
										$(SRC_DIR)domedriver_rpi.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)domedriver_rpi.cpp -o$(OBJECT_DIR)domedriver_rpi.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)domedriver_ror_rpi.o :		$(SRC_DIR)domedriver_ror_rpi.cpp	\
										$(SRC_DIR)domedriver_ror_rpi.h		\
										$(SRC_DIR)domedriver.h				\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)domedriver_ror_rpi.cpp -o$(OBJECT_DIR)domedriver_ror_rpi.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)shutterdriver.o :			$(SRC_DIR)shutterdriver.cpp			\
										$(SRC_DIR)shutterdriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)shutterdriver.cpp -o$(OBJECT_DIR)shutterdriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)shutterdriver_arduino.o :	$(SRC_DIR)shutterdriver_arduino.cpp	\
										$(SRC_DIR)shutterdriver_arduino.h	\
										$(SRC_DIR)shutterdriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)shutterdriver_arduino.cpp -o$(OBJECT_DIR)shutterdriver_arduino.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)filterwheeldriver.o :		$(SRC_DIR)filterwheeldriver.cpp		\
										$(SRC_DIR)filterwheeldriver.h		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)filterwheeldriver.cpp -o$(OBJECT_DIR)filterwheeldriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)filterwheeldriver_ZWO.o :	$(SRC_DIR)filterwheeldriver_ZWO.cpp	\
										$(SRC_DIR)filterwheeldriver_ZWO.h 	\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)filterwheeldriver_ZWO.cpp -o$(OBJECT_DIR)filterwheeldriver_ZWO.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)focuserdriver.o :			$(SRC_DIR)focuserdriver.cpp			\
										$(SRC_DIR)focuserdriver.h	 		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)focuserdriver.cpp -o$(OBJECT_DIR)focuserdriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)focuserdriver_nc.o :		$(SRC_DIR)focuserdriver_nc.cpp		\
										$(SRC_DIR)focuserdriver_nc.h 		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)focuserdriver_nc.cpp -o$(OBJECT_DIR)focuserdriver_nc.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)rotatordriver.o :			$(SRC_DIR)rotatordriver.cpp			\
										$(SRC_DIR)rotatordriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)rotatordriver.cpp -o$(OBJECT_DIR)rotatordriver.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)rotatordriver_nc.o :		$(SRC_DIR)rotatordriver_nc.cpp		\
										$(SRC_DIR)rotatordriver_nc.h	 	\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)rotatordriver_nc.cpp -o$(OBJECT_DIR)rotatordriver_nc.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)slittracker.o :		$(SRC_DIR)slittracker.cpp				\
										$(SRC_DIR)slittracker.h	 			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)slittracker.cpp -o$(OBJECT_DIR)slittracker.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver.o :		$(SRC_DIR)telescopedriver.cpp		\
										$(SRC_DIR)telescopedriver.h			\
										$(SRC_DIR)domedriver.h				\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)telescopedriver.cpp -o$(OBJECT_DIR)telescopedriver.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver_comm.o :	$(SRC_DIR)telescopedriver_comm.cpp	\
										$(SRC_DIR)telescopedriver_comm.h	\
										$(SRC_DIR)telescopedriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)telescopedriver_comm.cpp -o$(OBJECT_DIR)telescopedriver_comm.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver_lx200.o :	$(SRC_DIR)telescopedriver_lx200.cpp	\
										$(SRC_DIR)telescopedriver_lx200.h	\
										$(SRC_DIR)telescopedriver.h			\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)telescopedriver_lx200.cpp -o$(OBJECT_DIR)telescopedriver_lx200.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver_Rigel.o :	$(SRC_DIR)telescopedriver_Rigel.cpp	\
										$(SRC_DIR)telescopedriver_Rigel.h	\
										$(SRC_DIR)telescopedriver_comm.h	\
										$(SRC_DIR)telescopedriver.h			\
										$(SRC_DIR)alpacadriver.h
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)telescopedriver_Rigel.cpp -o$(OBJECT_DIR)telescopedriver_Rigel.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver_servo.o :	$(SRC_DIR)telescopedriver_servo.cpp	\
										$(SRC_DIR)telescopedriver_servo.h	\
										$(SRC_DIR)telescopedriver_comm.h	\
										$(SRC_DIR)telescopedriver.h			\
										$(SRC_DIR)alpacadriver.h
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)telescopedriver_servo.cpp -o$(OBJECT_DIR)telescopedriver_servo.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)telescopedriver_skywatch.o :	$(SRC_DIR)telescopedriver_skywatch.cpp	\
											$(SRC_DIR)telescopedriver_skywatch.h	\
											$(SRC_DIR)telescopedriver.h				\
											$(SRC_DIR)alpacadriver.h				\
											Makefile
	$(COMPILEPLUS) $(INCLUDES)				$(SRC_DIR)telescopedriver_skywatch.cpp -o$(OBJECT_DIR)telescopedriver_skywatch.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)managementdriver.o :		$(SRC_DIR)managementdriver.cpp		\
										$(SRC_DIR)managementdriver.h 		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)managementdriver.cpp -o$(OBJECT_DIR)managementdriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)switchdriver.o :			$(SRC_DIR)switchdriver.cpp			\
										$(SRC_DIR)switchdriver.h		 	\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)switchdriver.cpp -o$(OBJECT_DIR)switchdriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)switchdriver_rpi.o :		$(SRC_DIR)switchdriver_rpi.cpp		\
										$(SRC_DIR)switchdriver_rpi.h		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)switchdriver_rpi.cpp -o$(OBJECT_DIR)switchdriver_rpi.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)obsconditionsdriver.o :	$(SRC_DIR)obsconditionsdriver.cpp	\
										$(SRC_DIR)obsconditionsdriver.h	 	\
										$(SRC_DIR)alpacadriver.h			\
										$(SRC_DIR)alpaca_defs.h				\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)obsconditionsdriver.cpp -o$(OBJECT_DIR)obsconditionsdriver.o
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)obsconditionsdriver_rpi.o :	$(SRC_DIR)obsconditionsdriver_rpi.cpp 	\
											$(SRC_DIR)obsconditionsdriver.h			\
											$(SRC_DIR)alpacadriver.h				\
											$(SRC_DIR)alpaca_defs.h					\
											Makefile
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)obsconditionsdriver_rpi.cpp -o$(OBJECT_DIR)obsconditionsdriver_rpi.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)calibrationdriver.o :			$(SRC_DIR)calibrationdriver.cpp 	\
											$(SRC_DIR)calibrationdriver.h		\
											$(SRC_DIR)alpacadriver.h			\
											Makefile
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)calibrationdriver.cpp -o$(OBJECT_DIR)calibrationdriver.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)calibrationdriver_rpi.o :		$(SRC_DIR)calibrationdriver_rpi.cpp \
											$(SRC_DIR)calibrationdriver_rpi.h	\
											$(SRC_DIR)calibrationdriver.h		\
											$(SRC_DIR)alpacadriver.h			\
											Makefile
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)calibrationdriver_rpi.cpp -o$(OBJECT_DIR)calibrationdriver_rpi.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)calibration_Alnitak.o :		$(SRC_DIR)calibration_Alnitak.cpp 	\
											$(SRC_DIR)calibration_Alnitak.h		\
											$(SRC_DIR)calibrationdriver.h		\
											$(SRC_DIR)alpacadriver.h			\
											Makefile
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)calibration_Alnitak.cpp -o$(OBJECT_DIR)calibration_Alnitak.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)discoverythread.o :		$(SRC_DIR)discoverythread.c 		\
										$(SRC_DIR)discoverythread.h 		\
										$(SRC_DIR)alpacadriver.h			\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)discoverythread.c -o$(OBJECT_DIR)discoverythread.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)HostNames.o :				$(SRC_DIR)HostNames.c 	\
										$(SRC_DIR)HostNames.h 	\
										Makefile
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)HostNames.c -o$(OBJECT_DIR)HostNames.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)sendrequest_lib.o :		$(SRC_DIR)sendrequest_lib.c 	\
										$(SRC_DIR)sendrequest_lib.h 	\
										$(MLS_LIB_DIR)json_parse.h
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)sendrequest_lib.c -o$(OBJECT_DIR)sendrequest_lib.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)observatory_settings.o :	$(SRC_DIR)observatory_settings.c 	\
										$(SRC_DIR)observatory_settings.h
	$(COMPILEPLUS) $(INCLUDES)			$(SRC_DIR)observatory_settings.c -o$(OBJECT_DIR)observatory_settings.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)serialport.o :				$(SRC_DIR)serialport.c 	\
										$(SRC_DIR)serialport.h
	$(COMPILE) $(INCLUDES)				$(SRC_DIR)serialport.c -o$(OBJECT_DIR)serialport.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)sidereal.o :				$(SRC_DIR)sidereal.c 			\
										$(SRC_DIR)sidereal.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)sidereal.c -o$(OBJECT_DIR)sidereal.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)cpu_stats.o :				$(SRC_DIR)cpu_stats.c 			\
										$(SRC_DIR)cpu_stats.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)cpu_stats.c -o$(OBJECT_DIR)cpu_stats.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)helper_functions.o :		$(SRC_DIR)helper_functions.c 			\
										$(SRC_DIR)helper_functions.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)helper_functions.c -o$(OBJECT_DIR)helper_functions.o



######################################################################################
# ATIK objects
$(OBJECT_DIR)camera_atik.o : $(SRC_DIR)camera_atik.c $(SRC_DIR)camera_atik.h
	$(COMPILE) $(INCLUDES) $(SRC_DIR)camera_atik.c -o$(OBJECT_DIR)camera_atik.o



######################################################################################
#	CLIENT_OBJECTS
$(OBJECT_DIR)json_parse.o : $(MLS_LIB_DIR)json_parse.c $(MLS_LIB_DIR)json_parse.h
	$(COMPILE) $(INCLUDES) $(MLS_LIB_DIR)json_parse.c -o$(OBJECT_DIR)json_parse.o

$(OBJECT_DIR)discoveryclient.o : $(SRC_DISCOVERY)discoveryclient.c $(SRC_DISCOVERY)discoveryclient.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DISCOVERY)discoveryclient.c -o$(OBJECT_DIR)discoveryclient.o




######################################################################################
$(OBJECT_DIR)mandelbrot.o : $(SRC_DIR)mandelbrot.c
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)mandelbrot.c -o$(OBJECT_DIR)mandelbrot.o



######################################################################################
$(OBJECT_DIR)controller.o : $(SRC_DIR)controller.cpp $(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller.cpp -o$(OBJECT_DIR)controller.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controllerClient.o : 		$(SRC_DIR)controllerClient.cpp		\
										$(SRC_DIR)controllerClient.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controllerClient.cpp -o$(OBJECT_DIR)controllerClient.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controllerServer.o : 		$(SRC_DIR)controllerServer.cpp		\
										$(SRC_DIR)controllerServer.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controllerServer.cpp -o$(OBJECT_DIR)controllerServer.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controllerAlpaca.o : 		$(SRC_DIR)controllerAlpaca.cpp		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controllerAlpaca.cpp -o$(OBJECT_DIR)controllerAlpaca.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_filterwheel.o : $(SRC_DIR)controller_filterwheel.cpp	\
										$(SRC_DIR)controller_fw_common.cpp		\
										$(SRC_DIR)controller_filterwheel.h		\
										$(SRC_DIR)controller.h					\
										$(SRC_DIR)windowtab_about.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_filterwheel.cpp -o$(OBJECT_DIR)controller_filterwheel.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_focus.o : 		$(SRC_DIR)controller_focus.cpp		\
										$(SRC_DIR)controller_focus.h		\
										$(SRC_DIR)controller.h				\
										$(SRC_DIR)windowtab_auxmotor.h		\
										$(SRC_DIR)windowtab_config.h		\
										$(SRC_DIR)windowtab_ml_single.h		\
										$(SRC_DIR)windowtab_graphs.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_focus.cpp -o$(OBJECT_DIR)controller_focus.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_focus_generic.o : 	$(SRC_DIR)controller_focus_generic.cpp	\
											$(SRC_DIR)controller_focus_generic.h	\
											$(SRC_DIR)controller_focus.h			\
											$(SRC_DIR)controller.h					\
											$(SRC_DIR)windowtab_ml_single.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_focus_generic.cpp -o$(OBJECT_DIR)controller_focus_generic.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_ml_nc.o : 		$(SRC_DIR)controller_ml_nc.cpp		\
										$(SRC_DIR)controller_ml_nc.h		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)windowtab_nitecrawler.h	\
										$(SRC_DIR)windowtab_graphs.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_ml_nc.cpp -o$(OBJECT_DIR)controller_ml_nc.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_ml_single.o : 	$(SRC_DIR)controller_ml_single.cpp	\
										$(SRC_DIR)controller_ml_single.h	\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_ml_single.cpp -o$(OBJECT_DIR)controller_ml_single.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_obsconditions.o : 	$(SRC_DIR)controller_obsconditions.cpp		\
											$(SRC_DIR)controller_obsconditions.h		\
											$(SRC_DIR)controller.h						\
											$(SRC_DIR)alpaca_defs.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_obsconditions.cpp -o$(OBJECT_DIR)controller_obsconditions.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_rotator.o : 		$(SRC_DIR)controller_rotator.cpp		\
											$(SRC_DIR)controller_rotator.h			\
											$(SRC_DIR)controller.h					\
											$(SRC_DIR)alpaca_defs.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_rotator.cpp -o$(OBJECT_DIR)controller_rotator.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_rotator.o : 			$(SRC_DIR)windowtab_rotator.cpp			\
											$(SRC_DIR)windowtab_rotator.h			\
											$(SRC_DIR)windowtab.h					\
											$(SRC_DIR)alpaca_defs.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_rotator.cpp -o$(OBJECT_DIR)windowtab_rotator.o




#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_switch.o : 		$(SRC_DIR)controller_switch.cpp		\
										$(SRC_DIR)controller_switch.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_switch.cpp -o$(OBJECT_DIR)controller_switch.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_camera.o : 		$(SRC_DIR)controller_camera.cpp		\
										$(SRC_DIR)controller_camera.h		\
										$(SRC_DIR)controller_fw_common.cpp	\
										$(SRC_DIR)windowtab_camera.h		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_camera.cpp -o$(OBJECT_DIR)controller_camera.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_cam_normal.o : 	$(SRC_DIR)controller_cam_normal.cpp	\
										$(SRC_DIR)controller_cam_normal.h	\
										$(SRC_DIR)controller_fw_common.cpp	\
										$(SRC_DIR)windowtab_camera.h		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_cam_normal.cpp -o$(OBJECT_DIR)controller_cam_normal.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controllerImageArray.o : 	$(SRC_DIR)controllerImageArray.cpp	\
										$(SRC_DIR)controller_fw_common.cpp	\
										$(SRC_DIR)controller_camera.h		\
										$(SRC_DIR)windowtab_camera.h		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controllerImageArray.cpp -o$(OBJECT_DIR)controllerImageArray.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_covercalib.o : 	$(SRC_DIR)controller_covercalib.cpp	\
										$(SRC_DIR)controller_covercalib.h	\
										$(SRC_DIR)windowtab_covercalib.h	\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_covercalib.cpp -o$(OBJECT_DIR)controller_covercalib.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_dome.o : 		$(SRC_DIR)controller_dome.cpp		\
										$(SRC_DIR)controller_dome.h			\
										$(SRC_DIR)windowtab_dome.h			\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_dome.cpp -o$(OBJECT_DIR)controller_dome.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_slit.o : 		$(SRC_DIR)controller_slit.cpp		\
										$(SRC_DIR)controller_slit.h			\
										$(SRC_DIR)windowtab_slit.h			\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_slit.cpp -o$(OBJECT_DIR)controller_slit.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_dome_common.o : $(SRC_DIR)controller_dome_common.cpp	\
										$(SRC_DIR)controller_dome.h				\
										$(SRC_DIR)windowtab_dome.h				\
										$(SRC_DIR)windowtab_about.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_dome_common.cpp -o$(OBJECT_DIR)controller_dome_common.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_telescope.o :	$(SRC_DIR)controller_telescope.cpp		\
										$(SRC_DIR)controller_tscope_common.cpp	\
										$(SRC_DIR)controller_telescope.h		\
										$(SRC_DIR)windowtab_telescope.h			\
										$(SRC_DIR)windowtab_about.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_telescope.cpp -o$(OBJECT_DIR)controller_telescope.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_alpacalist.o :	$(SRC_DIR)windowtab_alpacalist.cpp		\
										$(SRC_DIR)windowtab_alpacalist.h		\
										$(SRC_DIR)windowtab.h					\
										$(SRC_DIR)discoverythread.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_alpacalist.cpp -o$(OBJECT_DIR)windowtab_alpacalist.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_iplist.o : 		$(SRC_DIR)windowtab_iplist.cpp		\
										$(SRC_DIR)windowtab_iplist.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)discoverythread.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_iplist.cpp -o$(OBJECT_DIR)windowtab_iplist.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_deviceselect.o : $(SRC_DIR)windowtab_deviceselect.cpp	\
										$(SRC_DIR)windowtab_deviceselect.h		\
										$(SRC_DIR)windowtab.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_deviceselect.cpp -o$(OBJECT_DIR)windowtab_deviceselect.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_image.o : 		$(SRC_DIR)controller_image.cpp		\
										$(SRC_DIR)controller_image.h		\
										$(SRC_DIR)windowtab_image.h			\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_image.cpp -o$(OBJECT_DIR)controller_image.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_image.o : 		$(SRC_DIR)windowtab_image.cpp		\
										$(SRC_DIR)windowtab_image.h			\
										$(SRC_DIR)controller_image.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_image.cpp -o$(OBJECT_DIR)windowtab_image.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_usb.o : 		$(SRC_DIR)controller_usb.cpp		\
										$(SRC_DIR)controller_usb.h			\
										$(SRC_DIR)windowtab_usb.h			\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_usb.cpp -o$(OBJECT_DIR)controller_usb.o




#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_preview.o : 	$(SRC_DIR)controller_preview.cpp	\
										$(SRC_DIR)controller_preview.h		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_preview.cpp -o$(OBJECT_DIR)controller_preview.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab.o : 				$(SRC_DIR)windowtab.cpp				\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab.cpp -o$(OBJECT_DIR)windowtab.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_camsettings.o : 	$(SRC_DIR)windowtab_camsettings.cpp	\
										$(SRC_DIR)windowtab_camsettings.h	\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller_camera.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_camsettings.cpp -o$(OBJECT_DIR)windowtab_camsettings.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_filelist.o : 	$(SRC_DIR)windowtab_filelist.cpp	\
										$(SRC_DIR)controller_camera.h		\
										$(SRC_DIR)windowtab_filelist.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_filelist.cpp -o$(OBJECT_DIR)windowtab_filelist.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_filterwheel.o : 	$(SRC_DIR)windowtab_filterwheel.cpp	\
										$(SRC_DIR)windowtab_filterwheel.h	\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_filterwheel.cpp -o$(OBJECT_DIR)windowtab_filterwheel.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_ml_single.o : 	$(SRC_DIR)windowtab_ml_single.cpp	\
										$(SRC_DIR)windowtab_ml_single.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_ml_single.cpp -o$(OBJECT_DIR)windowtab_ml_single.o

$(OBJECT_DIR)windowtab_nitecrawler.o : 	$(SRC_DIR)windowtab_nitecrawler.cpp	\
										$(SRC_DIR)windowtab_nitecrawler.h	\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_nitecrawler.cpp -o$(OBJECT_DIR)windowtab_nitecrawler.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_about.o : 		$(SRC_DIR)windowtab_about.cpp		\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_about.cpp -o$(OBJECT_DIR)windowtab_about.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_drvrInfo.o : 	$(SRC_DIR)windowtab_drvrInfo.cpp		\
										$(SRC_DIR)windowtab_drvrInfo.h			\
										$(SRC_DIR)windowtab.h					\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_drvrInfo.cpp -o$(OBJECT_DIR)windowtab_drvrInfo.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_capabilities.o : $(SRC_DIR)windowtab_capabilities.cpp	\
										$(SRC_DIR)windowtab_capabilities.h		\
										$(SRC_DIR)windowtab.h					\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_capabilities.cpp -o$(OBJECT_DIR)windowtab_capabilities.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_moon.o : 		$(SRC_DIR)windowtab_moon.cpp		\
										$(SRC_DIR)windowtab_moon.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_moon.cpp -o$(OBJECT_DIR)windowtab_moon.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_obscond.o : 		$(SRC_DIR)windowtab_obscond.cpp		\
										$(SRC_DIR)windowtab_obscond.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)alpaca_defs.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_obscond.cpp -o$(OBJECT_DIR)windowtab_obscond.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)opencv_utils.o : 			$(SRC_DIR)opencv_utils.cpp		\
										$(SRC_DIR)opencv_utils.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)opencv_utils.cpp -o$(OBJECT_DIR)opencv_utils.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_preview.o : 		$(SRC_DIR)windowtab_preview.cpp		\
										$(SRC_DIR)windowtab_preview.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_preview.cpp -o$(OBJECT_DIR)windowtab_preview.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_auxmotor.o : 	$(SRC_DIR)windowtab_auxmotor.cpp	\
										$(SRC_DIR)windowtab_auxmotor.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_auxmotor.cpp -o$(OBJECT_DIR)windowtab_auxmotor.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_camera.o : 		$(SRC_DIR)windowtab_camera.cpp		\
										$(SRC_DIR)windowtab_camera.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_camera.cpp -o$(OBJECT_DIR)windowtab_camera.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_config.o : 		$(SRC_DIR)windowtab_config.cpp		\
										$(SRC_DIR)windowtab_config.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_config.cpp -o$(OBJECT_DIR)windowtab_config.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_covercalib.o : 	$(SRC_DIR)windowtab_covercalib.cpp	\
										$(SRC_DIR)windowtab_covercalib.h	\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_covercalib.cpp -o$(OBJECT_DIR)windowtab_covercalib.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_dome.o : 		$(SRC_DIR)windowtab_dome.cpp		\
										$(SRC_DIR)windowtab_dome.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_dome.cpp -o$(OBJECT_DIR)windowtab_dome.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_mount.o : 		$(SRC_DIR)windowtab_mount.cpp		\
										$(SRC_DIR)windowtab_mount.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_mount.cpp -o$(OBJECT_DIR)windowtab_mount.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_graphs.o : 		$(SRC_DIR)windowtab_graphs.cpp		\
										$(SRC_DIR)windowtab_graphs.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_graphs.cpp -o$(OBJECT_DIR)windowtab_graphs.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_slit.o : 		$(SRC_DIR)windowtab_slit.cpp		\
										$(SRC_DIR)windowtab_slit.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_slit.cpp -o$(OBJECT_DIR)windowtab_slit.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_slitgraph.o : 	$(SRC_DIR)windowtab_slitgraph.cpp	\
										$(SRC_DIR)windowtab_slitgraph.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_slitgraph.cpp -o$(OBJECT_DIR)windowtab_slitgraph.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_switch.o : 		$(SRC_DIR)windowtab_switch.cpp		\
										$(SRC_DIR)windowtab_switch.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_switch.cpp -o$(OBJECT_DIR)windowtab_switch.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_usb.o : 			$(SRC_DIR)windowtab_usb.cpp			\
										$(SRC_DIR)windowtab_usb.h			\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_usb.cpp -o$(OBJECT_DIR)windowtab_usb.o





#-------------------------------------------------------------------------------------
$(OBJECT_DIR)nitecrawler_image.o : 		$(SRC_DIR)nitecrawler_image.c		\
										$(SRC_DIR)nitecrawler_image.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)nitecrawler_image.c -o$(OBJECT_DIR)nitecrawler_image.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)moonlite_com.o : 			$(SRC_DIR)moonlite_com.c			\
										$(SRC_DIR)moonlite_com.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)moonlite_com.c -o$(OBJECT_DIR)moonlite_com.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_main.o : 		$(SRC_DIR)controller_main.cpp		\
										$(SRC_DIR)controller_focus.h		\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)controller_main.cpp -o$(OBJECT_DIR)controller_main.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)fits_opencv.o :			$(SRC_DIR)fits_opencv.c			\
										$(SRC_DIR)fits_opencv.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)fits_opencv.c -o$(OBJECT_DIR)fits_opencv.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)fitsview.o :				$(SRC_DIR)fitsview.c
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)fitsview.c -o$(OBJECT_DIR)fitsview.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)dumpfits.o :				$(SRC_DIR)dumpfits.c
	$(COMPILE) $(INCLUDES) $(SRC_DIR)dumpfits.c -o$(OBJECT_DIR)dumpfits.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)discovery_lib.o :			$(SRC_DIR)discovery_lib.c			\
										$(SRC_DIR)discovery_lib.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)discovery_lib.c -o$(OBJECT_DIR)discovery_lib.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)commoncolor.o :			$(SRC_DIR)commoncolor.c				\
										$(SRC_DIR)commoncolor.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)commoncolor.c -o$(OBJECT_DIR)commoncolor.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)imageprocess_orb.o :		$(SRC_IMGPROC)imageprocess_orb.cpp	\
										$(SRC_IMGPROC)imageprocess_orb.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_IMGPROC)imageprocess_orb.cpp -o$(OBJECT_DIR)imageprocess_orb.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)moonphase.o :				$(SRC_DIR)moonphase.c	\
										$(SRC_DIR)moonphase.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)moonphase.c -o$(OBJECT_DIR)moonphase.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)MoonRise.o :				$(SRC_MOONRISE)MoonRise.cpp	\
										$(SRC_MOONRISE)MoonRise.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_MOONRISE)MoonRise.cpp -I$(SRC_MOONRISE) -o$(OBJECT_DIR)MoonRise.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)julianTime.o :				$(SRC_DIR)julianTime.c	\
										$(SRC_DIR)julianTime.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)julianTime.c -o$(OBJECT_DIR)julianTime.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)raspberrypi_relaylib.o :	$(SRC_DIR)raspberrypi_relaylib.c	\
										$(SRC_DIR)raspberrypi_relaylib.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)raspberrypi_relaylib.c -o$(OBJECT_DIR)raspberrypi_relaylib.o




######################################################################################
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)skytravel_main.o :			$(SRC_SKYTRAVEL)skytravel_main.cpp	\
										$(SRC_SKYTRAVEL)windowtab_skytravel.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)skytravel_main.cpp -o$(OBJECT_DIR)skytravel_main.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_telescope.o :	$(SRC_DIR)windowtab_telescope.cpp	\
										$(SRC_DIR)windowtab_telescope.h		\
										$(SRC_DIR)windowtab.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_telescope.cpp -o$(OBJECT_DIR)windowtab_telescope.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_teleSettings.o :	$(SRC_DIR)windowtab_teleSettings.cpp	\
										$(SRC_DIR)windowtab_teleSettings.h		\
										$(SRC_DIR)windowtab.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)windowtab_teleSettings.cpp -o$(OBJECT_DIR)windowtab_teleSettings.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_skytravel.o :	$(SRC_SKYTRAVEL)controller_skytravel.cpp	\
										$(SRC_DIR)controller_tscope_common.cpp		\
										$(SRC_DIR)controller_dome_common.cpp		\
										$(SRC_SKYTRAVEL)controller_skytravel.h		\
										$(SRC_SKYTRAVEL)SkyStruc.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)controller_skytravel.cpp -o$(OBJECT_DIR)controller_skytravel.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_fov.o : 			$(SRC_SKYTRAVEL)windowtab_fov.cpp			\
										$(SRC_SKYTRAVEL)windowtab_fov.h				\
										$(SRC_SKYTRAVEL)cameraFOV.h					\
										$(SRC_DIR)windowtab.h						\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_fov.cpp -o$(OBJECT_DIR)windowtab_fov.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)StarData.o :				$(SRC_SKYTRAVEL)StarData.c	\
										$(SRC_SKYTRAVEL)StarData.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)StarData.c -o$(OBJECT_DIR)StarData.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)SAO_stardata.o :			$(SRC_SKYTRAVEL)SAO_stardata.c	\
										$(SRC_SKYTRAVEL)SAO_stardata.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)SAO_stardata.c -o$(OBJECT_DIR)SAO_stardata.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)aavso_data.o :				$(SRC_SKYTRAVEL)aavso_data.c	\
										$(SRC_SKYTRAVEL)aavso_data.h	\
										$(SRC_SKYTRAVEL)SkyStruc.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)aavso_data.c -o$(OBJECT_DIR)aavso_data.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)polaralign.o :				$(SRC_SKYTRAVEL)polaralign.cpp	\
										$(SRC_SKYTRAVEL)polaralign.h	\
										$(SRC_SKYTRAVEL)SkyStruc.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)polaralign.cpp -o$(OBJECT_DIR)polaralign.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_skytravel.o :	$(SRC_SKYTRAVEL)windowtab_skytravel.cpp	\
										$(SRC_SKYTRAVEL)windowtab_skytravel.h	\
										$(SRC_DIR)windowtab.h					\
										$(SRC_SKYTRAVEL)AsteroidData.h			\
										$(SRC_SKYTRAVEL)aavso_data.h			\
										$(SRC_SKYTRAVEL)StarData.h				\
										$(SRC_SKYTRAVEL)SkyStruc.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_skytravel.cpp -o$(OBJECT_DIR)windowtab_skytravel.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_cpustats.o :		$(SRC_SKYTRAVEL)windowtab_cpustats.cpp	\
										$(SRC_SKYTRAVEL)windowtab_cpustats.h	\
										$(SRC_DIR)windowtab.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_cpustats.cpp -o$(OBJECT_DIR)windowtab_cpustats.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_STsettings.o :	$(SRC_SKYTRAVEL)windowtab_STsettings.cpp	\
										$(SRC_SKYTRAVEL)windowtab_STsettings.h		\
										$(SRC_DIR)windowtab.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_STsettings.cpp -o$(OBJECT_DIR)windowtab_STsettings.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_RemoteData.o :	$(SRC_SKYTRAVEL)windowtab_RemoteData.cpp	\
										$(SRC_SKYTRAVEL)windowtab_RemoteData.h		\
										$(SRC_DIR)windowtab.h						\
										$(SRC_SKYTRAVEL)RemoteImage.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_RemoteData.cpp -o$(OBJECT_DIR)windowtab_RemoteData.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)eph.o :					$(SRC_SKYTRAVEL)eph.c	\
										$(SRC_SKYTRAVEL)eph.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)eph.c -o$(OBJECT_DIR)eph.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)SkyTravelTimeRoutines.o :	$(SRC_SKYTRAVEL)SkyTravelTimeRoutines.c	\
										$(SRC_SKYTRAVEL)SkyTravelTimeRoutines.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)SkyTravelTimeRoutines.c -o$(OBJECT_DIR)SkyTravelTimeRoutines.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)NGCcatalog.o :				$(SRC_SKYTRAVEL)NGCcatalog.c	\
										$(SRC_SKYTRAVEL)NGCcatalog.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)NGCcatalog.c -o$(OBJECT_DIR)NGCcatalog.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)OpenNGC.o :				$(SRC_SKYTRAVEL)OpenNGC.c	\
										$(SRC_SKYTRAVEL)OpenNGC.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)OpenNGC.c -o$(OBJECT_DIR)OpenNGC.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)StarCatalogHelper.o :		$(SRC_SKYTRAVEL)StarCatalogHelper.c	\
										$(SRC_SKYTRAVEL)StarCatalogHelper.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)StarCatalogHelper.c -o$(OBJECT_DIR)StarCatalogHelper.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)YaleStarCatalog.o :		$(SRC_SKYTRAVEL)YaleStarCatalog.c	\
										$(SRC_SKYTRAVEL)YaleStarCatalog.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)YaleStarCatalog.c -o$(OBJECT_DIR)YaleStarCatalog.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)HipparcosCatalog.o :		$(SRC_SKYTRAVEL)HipparcosCatalog.c	\
										$(SRC_SKYTRAVEL)HipparcosCatalog.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)HipparcosCatalog.c -o$(OBJECT_DIR)HipparcosCatalog.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)ConstellationData.o :		$(SRC_SKYTRAVEL)ConstellationData.c	\
										$(SRC_SKYTRAVEL)ConstellationData.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)ConstellationData.c -o$(OBJECT_DIR)ConstellationData.o

#-------------------------------------------------------------------------------------
#$(OBJECT_DIR)GaiaData.o :				$(SRC_SKYTRAVEL)GaiaData.c	\
#										$(SRC_SKYTRAVEL)GaiaData.h
#	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)GaiaData.c -o$(OBJECT_DIR)GaiaData.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)GaiaSQL.o :				$(SRC_SKYTRAVEL)GaiaSQL.cpp	\
										$(SRC_SKYTRAVEL)GaiaSQL.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)GaiaSQL.cpp -o$(OBJECT_DIR)GaiaSQL.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_GaiaRemote.o :	$(SRC_SKYTRAVEL)controller_GaiaRemote.cpp	\
										$(SRC_SKYTRAVEL)controller_GaiaRemote.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)controller_GaiaRemote.cpp -o$(OBJECT_DIR)controller_GaiaRemote.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_GaiaRemote.o :	$(SRC_SKYTRAVEL)windowtab_GaiaRemote.cpp	\
										$(SRC_DIR)windowtab.h						\
										$(SRC_SKYTRAVEL)windowtab_GaiaRemote.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_GaiaRemote.cpp -o$(OBJECT_DIR)windowtab_GaiaRemote.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)AsteroidData.o :			$(SRC_SKYTRAVEL)AsteroidData.c	\
										$(SRC_SKYTRAVEL)AsteroidData.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)AsteroidData.c -o$(OBJECT_DIR)AsteroidData.o



#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_starlist.o : 	$(SRC_SKYTRAVEL)controller_starlist.cpp	\
										$(SRC_SKYTRAVEL)controller_starlist.h	\
										$(SRC_DIR)windowtab_about.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)controller_starlist.cpp -o$(OBJECT_DIR)controller_starlist.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_starlist.o : 	$(SRC_SKYTRAVEL)windowtab_starlist.cpp	\
										$(SRC_SKYTRAVEL)windowtab_starlist.h	\
										$(SRC_DIR)windowtab.h					\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_starlist.cpp -o$(OBJECT_DIR)windowtab_starlist.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_constList.o :	$(SRC_SKYTRAVEL)windowtab_constList.cpp	\
										$(SRC_SKYTRAVEL)windowtab_constList.h	\
										$(SRC_DIR)windowtab.h					\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)windowtab_constList.cpp -o$(OBJECT_DIR)windowtab_constList.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_constList.o : 	$(SRC_SKYTRAVEL)controller_constList.cpp			\
												$(SRC_SKYTRAVEL)controller_constList.h		\
												$(SRC_DIR)windowtab_about.h					\
												$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)controller_constList.cpp -o$(OBJECT_DIR)controller_constList.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)RemoteImage.o : 			$(SRC_SKYTRAVEL)RemoteImage.cpp	\
										$(SRC_SKYTRAVEL)RemoteImage.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SKYTRAVEL)RemoteImage.cpp -o$(OBJECT_DIR)RemoteImage.o


#-------------------------------------------------------------------------------------
$(OBJECT_DIR)lx200_com.o :				$(SRC_DIR)lx200_com.c	\
										$(SRC_DIR)lx200_com.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)lx200_com.c -o$(OBJECT_DIR)lx200_com.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)linuxerrors.o :			$(SRC_DIR)linuxerrors.c	\
										$(SRC_DIR)linuxerrors.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_DIR)linuxerrors.c -o$(OBJECT_DIR)linuxerrors.o


SRC_SPECIAL			=	./src_special/

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)windowtab_video.o : 		$(SRC_SPECIAL)windowtab_video.cpp	\
										$(SRC_SPECIAL)windowtab_video.h		\
										$(SRC_DIR)windowtab.h				\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SPECIAL)windowtab_video.cpp -o$(OBJECT_DIR)windowtab_video.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)controller_video.o : 		$(SRC_SPECIAL)controller_video.cpp	\
										$(SRC_SPECIAL)controller_video.h	\
										$(SRC_DIR)windowtab_about.h			\
										$(SRC_DIR)controller.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SPECIAL)controller_video.cpp -o$(OBJECT_DIR)controller_video.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)startextrathread.o : 		$(SRC_SPECIAL)startextrathread.cpp	\
										$(SRC_DIR)alpacadriver_helper.h
	$(COMPILEPLUS) $(INCLUDES) $(SRC_SPECIAL)startextrathread.cpp -o$(OBJECT_DIR)startextrathread.o

##################################################################################
#		Servo source code
##################################################################################
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_mount_cfg.o : 		$(SRC_SERVO)servo_mount_cfg.c	\
										$(SRC_SERVO)servo_mount_cfg.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_mount_cfg.c -o$(OBJECT_DIR)servo_mount_cfg.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_time.o : 			$(SRC_SERVO)servo_time.c	\
										$(SRC_SERVO)servo_time.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_time.c -o$(OBJECT_DIR)servo_time.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_mount.o : 			$(SRC_SERVO)servo_mount.c	\
										$(SRC_SERVO)servo_mount.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_mount.c -o$(OBJECT_DIR)servo_mount.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_motion.o : 			$(SRC_SERVO)servo_motion.c	\
										$(SRC_SERVO)servo_motion.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_motion.c -o$(OBJECT_DIR)servo_motion.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_motion_cfg.o : 		$(SRC_SERVO)servo_motion_cfg.c	\
										$(SRC_SERVO)servo_motion_cfg.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_motion_cfg.c -o$(OBJECT_DIR)servo_motion_cfg.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_observ_cfg.o : 		$(SRC_SERVO)servo_observ_cfg.c	\
										$(SRC_SERVO)servo_observ_cfg.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_observ_cfg.c -o$(OBJECT_DIR)servo_observ_cfg.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_rc_utils.o : 		$(SRC_SERVO)servo_rc_utils.c	\
										$(SRC_SERVO)servo_rc_utils.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_rc_utils.c -o$(OBJECT_DIR)servo_rc_utils.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)servo_mc_core.o : 			$(SRC_SERVO)servo_mc_core.c	\
										$(SRC_SERVO)servo_mc_core.h	\
										$(SRC_SERVO)servo_std_defs.h
	$(COMPILE) $(INCLUDES) $(SRC_SERVO)servo_mc_core.c -o$(OBJECT_DIR)servo_mc_core.o

##################################################################################
#		IMU source code
##################################################################################
#-------------------------------------------------------------------------------------
$(OBJECT_DIR)imu_lib.o : 				$(SRC_IMU)imu_lib.c	\
										$(SRC_IMU)imu_lib.h	\
										$(SRC_IMU)getbno055.h
	$(COMPILE) $(INCLUDES) $(SRC_IMU)imu_lib.c -o$(OBJECT_DIR)imu_lib.o

#-------------------------------------------------------------------------------------
$(OBJECT_DIR)i2c_bno055.o : 			$(SRC_IMU)i2c_bno055.c	\
										$(SRC_IMU)getbno055.h
	$(COMPILE) $(INCLUDES) $(SRC_IMU)i2c_bno055.c -o$(OBJECT_DIR)i2c_bno055.o
