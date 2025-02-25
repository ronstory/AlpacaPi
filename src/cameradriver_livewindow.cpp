//*****************************************************************************
//*	Name:			cameradriver_livewindow.cpp
//*
//*	Author:			Mark Sproul (C) 2019, 2020, 2021
//*
//*	Description:	C++ Driver for Alpaca protocol
//*
//*****************************************************************************
//*	AlpacaPi is an open source project written in C/C++
//*
//*	Use of this source code for private or individual use is granted
//*	Use of this source code, in whole or in part for commercial purpose requires
//*	written agreement in advance.
//*
//*	You may use or modify this source code in any way you find useful, provided
//*	that you agree that the author(s) have no warranty, obligations or liability.  You
//*	must determine the suitability of this source code for your use.
//*
//*	Redistributions of this source code must retain this copyright notice.
//*****************************************************************************
//*	Edit History
//*****************************************************************************
//*	<MLS>	=	Mark L Sproul
//*****************************************************************************
//*	Apr 14,	2019	<MLS> Created cameradriver_livewindow.c
//*****************************************************************************

#if defined(_ENABLE_CAMERA_) && defined(_USE_OPENCV_)

//#define _DEBUG_TIMING_
#define _ENABLE_CONSOLE_DEBUG_
#include	"ConsoleDebug.h"

#include	"alpaca_defs.h"

#include	"alpacadriver.h"
#include	"alpacadriver_helper.h"
#include	"cameradriver.h"
#include	"opencv_utils.h"

#include	"controller_image.h"

//*****************************************************************************
TYPE_ASCOM_STATUS	CameraDriver::OpenLiveWindow(char *alpacaErrMsg)
{
TYPE_ASCOM_STATUS	alpacaErrCode;

	alpacaErrCode	=	kASCOM_Err_Success;

#ifdef _ENABLE_CTRL_IMAGE_
char				myWindowName[80];
bool				windowExists;

	CONSOLE_DEBUG(__FUNCTION__);

	if (strlen(gHostName) > 0)
	{
		strcpy(myWindowName,	gHostName);
		strcat(myWindowName,	"-");
		strcat(myWindowName,	cCommonProp.Name);
	}
	else
	{
		strcpy(myWindowName,	cCommonProp.Name);
	}
	CONSOLE_DEBUG_W_STR("New Window:", myWindowName);
	windowExists	=	CheckForOpenWindowByName(myWindowName);
	if (windowExists)
	{
		CONSOLE_DEBUG_W_STR("Window already open:", myWindowName);
	}
	else
	{
		CONSOLE_DEBUG_W_STR("Creating new window:", myWindowName);
		cLiveController	=	new ControllerImage(myWindowName, NULL);
	}
	alpacaErrCode	=	kASCOM_Err_Success;

	CONSOLE_DEBUG("-----------------------------");
	CONSOLE_DEBUG(__FUNCTION__);
	CONSOLE_DEBUG_W_NUM("gControllerCnt\t=",	gControllerCnt);
	CONSOLE_DEBUG(__FUNCTION__);
	CONSOLE_DEBUG("-----------------------------");

#endif
	return(alpacaErrCode);
}


//*****************************************************************************
void	CameraDriver::UpdateLiveWindow(void)
{
#ifdef _ENABLE_CTRL_IMAGE_
ControllerImage	*myImageController;
double			exposure_Secs;

	CONSOLE_DEBUG(__FUNCTION__);

	myImageController	=	(ControllerImage *)cLiveController;
	if (myImageController != NULL)
	{
#if defined(_USE_OPENCV_CPP_) && (CV_MAJOR_VERSION >= 2)
		DumpCVMatStruct(cOpenCV_ImagePtr, __FUNCTION__);
#endif // _USE_OPENCV_CPP_
		myImageController->UpdateLiveWindowImage(cOpenCV_ImagePtr, cFileNameRoot);

		exposure_Secs	=	1.0 * cCurrentExposure_us / 1000000.0;

		myImageController->UpdateLiveWindowInfo(&cCameraProp,
												cFramesRead,
												exposure_Secs,
											#ifdef _ENABLE_FILTERWHEEL_
												cFilterWheelCurrName,
											#else
												NULL,
											#endif // _ENABLE_FILTERWHEEL_
												cObjectName
												);
	}
#endif	//	_ENABLE_CTRL_IMAGE_
}

#endif // _ENABLE_CAMERA_
