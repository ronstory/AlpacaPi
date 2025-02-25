//*****************************************************************************
//*		controller_cam_normal.cpp		(c) 2020 by Mark Sproul
//*
//*
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
//*	Re-distribution of this source code must retain this copyright notice.
//*****************************************************************************
//*	Edit History
//*****************************************************************************
//*	Jun 24,	2020	<MLS> Made decision to switch camera to have sub classes
//*	Jun 24,	2020	<MLS> Created controller_cam_normal.cpp
//*	Jun 25,	2020	<MLS> Cam_normal subclass now back to same functionality as before
//*	Dec 27,	2020	<MLS> Added UpdateDownloadProgress()
//*	Jun 30,	2022	<MLS> Added capability list to camera controller
//*	Sep 18,	2022	<MLS> Added DisableFilterWheel()
//*	Sep 21,	2022	<MLS> Added ProcessReadAll_IMU()
//*****************************************************************************
//*	todo
//*		control key for different step size.
//*		work on fits view to handle color fits images
//*		add error list window
//*		save cross hair location
//*		finish exposure step options
//*		clear error msg
//*****************************************************************************

#ifdef _ENABLE_CTRL_CAMERA_

#include	<stdio.h>
#include	<stdlib.h>
#include	<unistd.h>

#include	"discovery_lib.h"
#include	"sendrequest_lib.h"

#include	"alpaca_defs.h"

#define _ENABLE_CONSOLE_DEBUG_
#include	"ConsoleDebug.h"


//#define	kCamWindowWidth		456
#define	kCamWindowWidth		500
#define	kCamWindowHeight	800


#include	"windowtab.h"
#include	"windowtab_camera.h"
#include	"windowtab_camgraph.h"
#include	"windowtab_filelist.h"
#include	"windowtab_camsettings.h"
#include	"windowtab_about.h"

#include	"controller.h"
#include	"controller_camera.h"
#include	"controller_cam_normal.h"


//**************************************************************************************
enum
{
	kTab_Camera	=	1,
	kTab_Settings,
	kTab_Capabilities,
//	kTab_Advanced,
//	kTab_Graphs,
	kTab_FileList,
	kTab_DriverInfo,
	kTab_About,

	kTab_Count

};

//**************************************************************************************
ControllerCamNormal::ControllerCamNormal(	const char			*argWindowName,
											TYPE_REMOTE_DEV		*alpacaDevice)
	:ControllerCamera(argWindowName, alpacaDevice, kCamWindowWidth,  kCamWindowHeight)
{
	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	cIMUdetected	=	false;

	SetupWindowControls();

}



//**************************************************************************************
// Destructor
//**************************************************************************************
ControllerCamNormal::~ControllerCamNormal(void)
{
	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);
	if (cCameraProp.CoolerOn)
	{
		//*	the ATIK cameras need to have cooling turned off gracefully
		//*	so, just as a last minute thing, turn it off.
		CONSOLE_DEBUG_W_STR("turning coolor off", cWindowName);
		ToggleCooler();
	}
	//*	delete the windowtab objects
	DELETE_OBJ_IF_VALID(cCameraTabObjPtr);
	DELETE_OBJ_IF_VALID(cCamSettingsTabObjPtr);
	DELETE_OBJ_IF_VALID(cCapabilitiesTabObjPtr);
	DELETE_OBJ_IF_VALID(cFileListTabObjPtr);
	DELETE_OBJ_IF_VALID(cDriverInfoTabObjPtr);
	DELETE_OBJ_IF_VALID(cAboutBoxTabObjPtr);
}

//**************************************************************************************
void	ControllerCamNormal::SetupWindowControls(void)
{
char	lineBuff[64];

	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	SetTabCount(kTab_Count);
	SetTabText(kTab_Camera,			"Camera");
	SetTabText(kTab_Settings,		"Settings");
	SetTabText(kTab_Capabilities,	"Capabilities");
//	SetTabText(kTab_Advanced,		"Adv");
//	SetTabText(kTab_Graphs,			"Graphs");
	SetTabText(kTab_FileList,		"File List");
	SetTabText(kTab_DriverInfo,		"Driver Info");
	SetTabText(kTab_About,			"About");

	//--------------------------------------------
	cCameraTabObjPtr		=	new WindowTabCamera(cWidth,
													cHeight,
													cBackGrndColor,
													cWindowName,
													cAlpacaDeviceNameStr,
													cHas_FilterWheel);
	if (cCameraTabObjPtr != NULL)
	{
		SetTabWindow(kTab_Camera,	cCameraTabObjPtr);
		cCameraTabObjPtr->SetParentObjectPtr(this);
	}

	//--------------------------------------------
	cCamSettingsTabObjPtr	=	new WindowTabCamSettings(cWidth,
													cHeight,
													cBackGrndColor,
													cWindowName,
													cAlpacaDeviceNameStr,
													cHas_FilterWheel);
	if (cCamSettingsTabObjPtr != NULL)
	{
		SetTabWindow(kTab_Settings,	cCamSettingsTabObjPtr);
		cCamSettingsTabObjPtr->SetParentObjectPtr(this);
	}

	//--------------------------------------------
	cCapabilitiesTabObjPtr		=	new WindowTabCapabilities(	cWidth, cHeight, cBackGrndColor, cWindowName);
	if (cCapabilitiesTabObjPtr != NULL)
	{
		SetTabWindow(kTab_Capabilities,	cCapabilitiesTabObjPtr);
		cCapabilitiesTabObjPtr->SetParentObjectPtr(this);
	}

	//--------------------------------------------
	cFileListTabObjPtr		=	new WindowTabFileList(	cWidth, cHeight, (cv::Scalar)cBackGrndColor, cWindowName);
	if (cFileListTabObjPtr != NULL)
	{
		SetTabWindow(kTab_FileList,	cFileListTabObjPtr);
		cFileListTabObjPtr->SetParentObjectPtr(this);
	}

	//--------------------------------------------
	cDriverInfoTabObjPtr		=	new WindowTabDriverInfo(	cWidth, cHeight, cBackGrndColor, cWindowName);
	if (cDriverInfoTabObjPtr != NULL)
	{
		SetTabWindow(kTab_DriverInfo,	cDriverInfoTabObjPtr);
		cDriverInfoTabObjPtr->SetParentObjectPtr(this);
	}

	//--------------------------------------------
	cAboutBoxTabObjPtr		=	new WindowTabAbout(	cWidth, cHeight, cBackGrndColor, cWindowName);
	if (cAboutBoxTabObjPtr != NULL)
	{
		SetTabWindow(kTab_About,	cAboutBoxTabObjPtr);
		cAboutBoxTabObjPtr->SetParentObjectPtr(this);
	}

	//*	display the IPaddres/port
	if (cValidIPaddr)
	{
	char	ipString[32];

		PrintIPaddressToString(cDeviceAddress.sin_addr.s_addr, ipString);
		sprintf(lineBuff, "%s:%d/%d", ipString, cPort, cAlpacaDevNum);

		SetWindowIPaddrInfo(lineBuff, true);
	}
}

//**************************************************************************************
void	ControllerCamNormal::DisableFilterWheel(void)
{
	if (cCameraTabObjPtr != NULL)
	{
		cCameraTabObjPtr->DisableFilterWheel();
	}
}

//**************************************************************************************
void	ControllerCamNormal::UpdateCapabilityList(void)
{
	UpdateCapabilityListID(kTab_Capabilities, kCapabilities_TextBox1, kCapabilities_TextBoxN);
}

#pragma mark -

//*****************************************************************************
void	ControllerCamNormal::UpdateCommonProperties(void)
{
//	CONSOLE_DEBUG(__FUNCTION__);

	SetWidgetText(kTab_DriverInfo,		kDriverInfo_Name,				cCommonProp.Name);
	SetWidgetText(kTab_DriverInfo,		kDriverInfo_Description,		cCommonProp.Description);
	SetWidgetText(kTab_DriverInfo,		kDriverInfo_DriverInfo,			cCommonProp.DriverInfo);
	SetWidgetText(kTab_DriverInfo,		kDriverInfo_DriverVersion,		cCommonProp.DriverVersion);
	SetWidgetNumber(kTab_DriverInfo,	kDriverInfo_InterfaceVersion,	cCommonProp.InterfaceVersion);

//	CONSOLE_DEBUG_W_STR(__FUNCTION__, "Exit");
}

//*****************************************************************************
void	ControllerCamNormal::UpdateSettings_Object(const char *filePrefix)
{

	if (cCamSettingsTabObjPtr != NULL)
	{
		cCamSettingsTabObjPtr->UpdateSettings_Object(filePrefix);
		cUpdateWindow	=	true;
	}
}

//*****************************************************************************
void	ControllerCamNormal::AlpacaDisplayErrorMessage(const char *errorMsgString)
{
//	CONSOLE_DEBUG_W_STR("Alpaca error=", errorMsgString);
	SetWidgetText(kTab_Camera, kCameraBox_AlpacaErrorMsg, errorMsgString);
}


//*****************************************************************************
void	ControllerCamNormal::UpdateSupportedActions(void)
{
	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	SetWidgetValid(kTab_Camera,		kCameraBox_Readall,				cHas_readall);
	SetWidgetValid(kTab_Camera,		kCameraBox_FlipText,			cHas_Flip);
	SetWidgetValid(kTab_Camera,		kCameraBox_FlipValue,			cHas_Flip);
	SetWidgetValid(kTab_Camera,		kCameraBox_FlipHorzCheckBox,	cHas_Flip);
	SetWidgetValid(kTab_Camera,		kCameraBox_FlipVertCheckBox,	cHas_Flip);


	SetWidgetValid(kTab_Settings,	kCamSet_Readall,		cHas_readall);
//	SetWidgetValid(kTab_Graphs,		kHistogram_Readall,		cHas_readall);
	SetWidgetValid(kTab_FileList,	kFileList_Readall,		cHas_readall);



	if (cHas_readall == false)
	{
		SetWidgetCrossedout(kTab_Settings, kCamSet_ObjOutline,		true);
		SetWidgetCrossedout(kTab_Settings, kCamSet_FilenameOutline, true);

		SetWidgetText(kTab_Camera,		kCamSet_AlpacaErrorMsg,	"readall not supported");
		SetWidgetText(kTab_Settings,	kCamSet_AlpacaErrorMsg,	"readall not supported");
	}
	SetWidgetValid(kTab_Camera,	kCameraBox_AutoExposure,		cHas_autoexposure);
	SetWidgetValid(kTab_Camera,	kCameraBox_DisplayImage,		cHas_displayimage);
	SetWidgetValid(kTab_Camera,	kCameraBox_LiveMode,			cHas_livemode);
	SetWidgetValid(kTab_Camera,	kCameraBox_SideBar,				cHas_sidebar);
	SetWidgetValid(kTab_Camera,	kCameraBox_DownloadRGBarray,	cHas_rgbarray);
	SetWidgetValid(kTab_Camera,	kCameraBox_SaveAll,				cHas_SaveAll);

	UpdateAboutBoxRemoteDevice(kTab_About, kAboutBox_CPUinfo);
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraName(void)
{
int		jjj;

	SetWidgetText(kTab_Camera,		kCameraBox_Title,	cCommonProp.Name);
	SetWidgetText(kTab_Settings,	kCamSet_Title,		cCommonProp.Name);
	SetWidgetText(kTab_FileList,	kFileList_Title,	cCommonProp.Name);
	//*	check for ATIK cameras, they do not support GAIN
	if (strcasestr(cCommonProp.Name, "ATIK") != NULL)
	{
		for (jjj=kCameraBox_Gain_Label; jjj<=kCameraBox_Gain_Down; jjj++)
		{
			SetWidgetValid(kTab_Camera, jjj, false);
		}
		SetWidgetType(	kTab_Camera, kCameraBox_Gain_Slider, kWidgetType_TextBox);
		SetWidgetText(	kTab_Camera, kCameraBox_Gain_Slider, "Gain not supported");
		SetWidgetValid(	kTab_Camera, kCameraBox_Gain_Slider, true);
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateReadoutModes(void)
{
int		jjj;

	for (jjj=0; jjj<kMaxReadOutModes; jjj++)
	{
		if (strlen(cCameraProp.ReadOutModes[jjj].modeStr) > 0)
		{
			SetWidgetValid(	kTab_Camera, (kCameraBox_ReadMode0 + jjj), true);
			SetWidgetText(	kTab_Camera,
						(kCameraBox_ReadMode0 + jjj),
						cCameraProp.ReadOutModes[jjj].modeStr);
		}
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCurrReadoutMode(void)
{
	SetWidgetChecked(kTab_Camera, kCameraBox_ReadMode0, (cCameraProp.ReadOutMode == 0));
	SetWidgetChecked(kTab_Camera, kCameraBox_ReadMode1, (cCameraProp.ReadOutMode == 1));
	SetWidgetChecked(kTab_Camera, kCameraBox_ReadMode2, (cCameraProp.ReadOutMode == 2));
	SetWidgetChecked(kTab_Camera, kCameraBox_ReadMode3, (cCameraProp.ReadOutMode == 3));
	SetWidgetChecked(kTab_Camera, kCameraBox_ReadMode4, (cCameraProp.ReadOutMode == 4));
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraGain(const TYPE_ASCOM_STATUS lastAlpacaErr)
{
	if (lastAlpacaErr == kASCOM_Err_Success)
	{
		SetWidgetSliderLimits(	kTab_Camera, kCameraBox_Gain_Slider, cCameraProp.GainMin, cCameraProp.GainMax);
		SetWidgetSliderValue(	kTab_Camera, kCameraBox_Gain_Slider, cCameraProp.Gain);
		SetWidgetNumber(		kTab_Camera, kCameraBox_Gain, cCameraProp.Gain);
	}
	else
	{
		SetWidgetType(	kTab_Camera, kCameraBox_Gain_Slider, kWidgetType_TextBox);
		SetWidgetText(	kTab_Camera, kCameraBox_Gain_Slider, "Gain not implemented");
	}
	cUpdateWindow	=	true;
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraExposure(void)
{
	SetWidgetSliderLimits(	kTab_Camera, kCameraBox_Exposure_Slider,	cCameraProp.ExposureMin_seconds,
																		cCameraProp.ExposureMax_seconds);
	SetWidgetSliderValue(	kTab_Camera, kCameraBox_Exposure_Slider,	cExposure);
	SetWidgetNumber(		kTab_Camera, kCameraBox_Exposure,			cExposure);

	cUpdateWindow	=	true;
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraOffset(const TYPE_ASCOM_STATUS lastAlpacaErr)
{
//	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	if (lastAlpacaErr == kASCOM_Err_Success)
	{
		SetWidgetSliderLimits(	kTab_Camera, kCameraBox_Offset_Slider, cCameraProp.OffsetMin, cCameraProp.OffsetMax);
		SetWidgetSliderValue(	kTab_Camera, kCameraBox_Offset_Slider, cCameraProp.Offset);
		SetWidgetNumber(		kTab_Camera, kCameraBox_Offset, cCameraProp.Offset);
	}
	else
	{
		CONSOLE_DEBUG_W_NUM("lastAlpacaErr\t=", lastAlpacaErr);
		SetWidgetType(	kTab_Camera, kCameraBox_Offset_Slider, kWidgetType_TextBox);
		SetWidgetText(	kTab_Camera, kCameraBox_Offset_Slider, "Offset not implemented");
	}
	cUpdateWindow	=	true;
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraSize(void)
{
char	linebuff[64];

	sprintf(linebuff, "%d x %d", cCameraProp.CameraXsize, cCameraProp.CameraYsize);
	SetWidgetText(kTab_Camera, kCameraBox_Size, linebuff);

	cUpdateWindow	=	true;
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCameraState(void)
{
char			linebuff[64];

//	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	switch(cCameraProp.CameraState)
	{
		case	kALPACA_CameraState_Idle:		strcpy(linebuff,	"Idle");		break;
		case	kALPACA_CameraState_Waiting:	strcpy(linebuff,	"Waiting");		break;
		case	kALPACA_CameraState_Exposing:	strcpy(linebuff,	"Exposing");	break;
		case	kALPACA_CameraState_Reading:	strcpy(linebuff,	"Reading");		break;
		case	kALPACA_CameraState_Download:	strcpy(linebuff,	"Download");	break;
		case	kALPACA_CameraState_Error:		strcpy(linebuff,	"Error");		break;

		default:								strcpy(linebuff,	"unknown");		break;
	}
	SetWidgetText(		kTab_Camera, kCameraBox_State,			linebuff);
	if (cCameraState_imageready)
	{
		//*	image is ready, highlight the buttons
		SetWidgetBGColor(kTab_Camera, kCameraBox_DownloadImage, CV_RGB(255, 255, 255));
		SetWidgetBGColor(kTab_Camera, kCameraBox_DownloadRGBarray, CV_RGB(255, 255, 255));
	}
	else
	{
		//*	not ready, grey the buttons
		SetWidgetBGColor(kTab_Camera, kCameraBox_DownloadImage, CV_RGB(100, 100, 100));
		SetWidgetBGColor(kTab_Camera, kCameraBox_DownloadRGBarray, CV_RGB(100, 100, 100));
	}


	if (cCameraProp.CanStopExposure)
	{
		SetWidgetBGColor(kTab_Camera,	kCameraBox_StopExposure,	CV_RGB(255,	255,	255));
	}
	else
	{
		SetWidgetBGColor(kTab_Camera,	kCameraBox_StopExposure,	CV_RGB(128,	128,	128));
	}
	cUpdateWindow	=	true;
}


//*****************************************************************************
void	ControllerCamNormal::UpdateCameraTemperature(void)
{
char			linebuff[128];

	sprintf(linebuff, "%1.1f C / %1.1f F", cCameraProp.CCDtemperature,
											(cCameraProp.CCDtemperature * 9.0/5.0) +32.0);
	SetWidgetText(kTab_Camera, kCameraBox_Temperature, linebuff);

	if (cHasCCDtemp	== false)
	{
		if (cCameraTabObjPtr != NULL)
		{
			//*	disable the display of the temperature items
			cCameraTabObjPtr->SetTempartueDisplayEnable(false);
		}
	}
}
//*****************************************************************************
void	ControllerCamNormal::UpdatePercentCompleted(void)
{
char			linebuff[128];

//	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);

	sprintf(linebuff, "%d %% ", cCameraProp.PercentCompleted);
	SetWidgetText(kTab_Camera, kCameraBox_PercentCompleted, linebuff);
}

//*****************************************************************************
void	ControllerCamNormal::UpdateCoolerState(void)
{
	SetWidgetChecked(kTab_Camera, kCameraBox_CoolerChkBox, cCameraProp.CoolerOn);

}

//*****************************************************************************
void	ControllerCamNormal::UpdateFilterWheelInfo(void)
{
int		iii;
int		fwTabNumber;

	CONSOLE_DEBUG_W_STR(__FUNCTION__, cWindowName);
	SetWidgetText(	kTab_Camera,	kCameraBox_FilterWheelName,	cFilterWheelName);
	for (iii=0; iii<kMaxFiltersPerWheel; iii++)
	{
		if (strlen(cFilterWheelProp.Names[iii].FilterName) > 0)
		{
			//*	set the text in the window widget
			fwTabNumber	=	kCameraBox_FilterWheel1 + iii;
			SetWidgetValid(	kTab_Camera, fwTabNumber, true);
			SetWidgetText(	kTab_Camera,
							fwTabNumber,
							cFilterWheelProp.Names[iii].FilterName);

			if (strncasecmp(cFilterWheelProp.Names[iii].FilterName, "RED", 3) == 0)
			{
				SetWidgetTextColor(kTab_Camera, fwTabNumber, CV_RGB(255,	0,	0));
			}
			else if (strncasecmp(cFilterWheelProp.Names[iii].FilterName, "GREEN", 5) == 0)
			{
				SetWidgetTextColor(kTab_Camera, fwTabNumber, CV_RGB(0,	255,	0));
			}
			else if (strncasecmp(cFilterWheelProp.Names[iii].FilterName, "BLUE", 4) == 0)
			{
				SetWidgetTextColor(kTab_Camera, fwTabNumber, CV_RGB(0,	0,	255));
			}
			SetWidgetText(	kTab_Camera,
							fwTabNumber,
							cFilterWheelProp.Names[iii].FilterName);

		}
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateFilterWheelPosition(void)
{
int		jjj;

	if (cHas_FilterWheel)
	{
		for (jjj=kCameraBox_FilterWheel1; jjj<=kCameraBox_FilterWheel8; jjj++)
		{
			SetWidgetChecked(kTab_Camera, jjj, false);
		}
		SetWidgetChecked(kTab_Camera, (kCameraBox_FilterWheel1 + cFilterWheelProp.Position), true);
	}
	else
	{
		DisableFilterWheel();
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateFileNameOptions(void)
{
	SetWidgetChecked(kTab_Settings,	kCamSet_FN_IncFilter,		cFN_includeFilter);
	SetWidgetChecked(kTab_Settings,	kCamSet_FN_IncCamera,		cFN_includeManuf);
	SetWidgetChecked(kTab_Settings,	kCamSet_FN_IncSerialNum,	cFN_includeSerialNum);
	SetWidgetChecked(kTab_Settings,	kCamSet_FN_IncRefID,		cFN_includeRefID);
}

//*****************************************************************************
void	ControllerCamNormal::UpdateReceivedFileName(const char *newFileName)
{
	SetWidgetText(kTab_Camera, kCameraBox_Filename, newFileName);
	if (cCameraTabObjPtr != NULL)
	{
		cCameraTabObjPtr->SetReceivedFileName(newFileName);
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateRemoteFileList(void)
{
int		iii;
int		jjj;

	//*	now update the displayed list in the file list window
	iii	=	0;
	jjj	=	kFileList_FistEntry;
	while ((jjj <= kFileList_LastEntry) && (iii < kMaxRemoteFileCnt))
	{
		CONSOLE_DEBUG_W_NUM("Widget Index\t\t=", jjj);
		CONSOLE_DEBUG_W_STR("cRemoteFiles[iii].filename\t=", cRemoteFiles[iii].filename);

		if (cRemoteFiles[iii].validData)
		{
			SetWidgetText(kTab_FileList, jjj, cRemoteFiles[iii].filename);
		}
		else
		{
			CONSOLE_DEBUG("INVALID");
		}
		iii++;
		jjj++;
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateDisplayModes(void)
{
	SetWidgetChecked(kTab_Camera, kCameraBox_LiveMode,		cLiveMode);
	SetWidgetChecked(kTab_Camera, kCameraBox_SideBar,		cSideBar);
	SetWidgetChecked(kTab_Camera, kCameraBox_AutoExposure,	cAutoExposure);
	SetWidgetChecked(kTab_Camera, kCameraBox_DisplayImage,	cDisplayImage);
	SetWidgetChecked(kTab_Camera, kCameraBox_SaveAll,		cSaveAllImages);


}

//*****************************************************************************
void	ControllerCamNormal::UpdateFlipMode(void)
{
	SetWidgetNumber(kTab_Camera,	kCameraBox_FlipValue,			cCameraProp.FlipMode);
	SetWidgetChecked(kTab_Camera,	kCameraBox_FlipHorzCheckBox,	(cCameraProp.FlipMode & 0x01));
	SetWidgetChecked(kTab_Camera,	kCameraBox_FlipVertCheckBox,	(cCameraProp.FlipMode & 0x02));
}

//*****************************************************************************
void	ControllerCamNormal::UpdateBackgroundColor(const int redValue, const int grnValue, const int bluValue)
{
	SetWidgetBGColor(kTab_Camera, kCameraBox_Title, CV_RGB(redValue,	grnValue,	bluValue));
	if ((redValue + grnValue + bluValue) < (128 * 3))
	{
		SetWidgetTextColor(kTab_Camera, kCameraBox_Title, CV_RGB(255,	255,	255));
	}
	else
	{
		SetWidgetTextColor(kTab_Camera, kCameraBox_Title, CV_RGB(0,	0,	0));
	}
}


//*****************************************************************************
void	ControllerCamNormal::UpdateDownloadProgress(const int unitsRead, const int totalUnits)
{
double	newProgressValue;

	CONSOLE_DEBUG(__FUNCTION__);

	newProgressValue	=	1.0 * unitsRead / totalUnits;

	if (newProgressValue < cPrevProgessValue)
	{
		CONSOLE_DEBUG("Reset progress bar");
		cPrevProgessValue	=	0.0;
		cProgressUpdates	=	0;
		cProgressReDraws	=	0;
	}
	cProgressUpdates++;
	if (((newProgressValue - cPrevProgessValue) > 0.002) || (newProgressValue > 0.9985))
	{
		SetWidgetProgress(kTab_Camera, kCameraBox_ErrorMsg, unitsRead, totalUnits);
		cUpdateWindow	=	true;
		cv::waitKey(1);
		cv::waitKey(5);

		cProgressReDraws++;

		cPrevProgessValue	=	newProgressValue;
	}

	if (newProgressValue > 0.9999)
	{
		CONSOLE_DEBUG_W_DBL("newProgressValue\t=", newProgressValue);
		CONSOLE_DEBUG_W_NUM("cProgressUpdates\t=", cProgressUpdates);
		CONSOLE_DEBUG_W_NUM("cProgressReDraws\t=", cProgressReDraws);
	}
}

//*****************************************************************************
void	ControllerCamNormal::UpdateConnectedStatusIndicator(void)
{
	UpdateConnectedIndicator(kTab_Camera,		kCameraBox_Connected);
}


//*****************************************************************************
//*	if remote IMU is not enabled, this routine does nothing and will probably never get called,
//*	It has to be here to satisfy the parent class
//*****************************************************************************
void	ControllerCamNormal::ProcessReadAll_IMU(const char	*deviceTypeStr,
												const int	deviceNum,
												const char	*keywordString,
												const char	*valueString)
{
#ifdef _SUPPORT_REMOTE_IMU_
double		valueDouble;
int			valueInt;
char		textString[64];
cv::Scalar	textColor;

//	CONSOLE_DEBUG_W_STR(keywordString,valueString);

	if (cIMUdetected == false)
	{
		if (cCameraTabObjPtr != NULL)
		{
			cCameraTabObjPtr->SetRemoteIMUdisplay(true);
		}
		cIMUdetected	=	true;
	}

	valueDouble	=	atof(valueString);
	valueInt	=	atoi(valueString);
	switch(valueInt)
	{
		case 0:		textColor	=	CV_RGB(0xff,	0x00,	0x00);	break;	//*	red
		case 1:		textColor	=	CV_RGB(0xff,	0xff,	0x00);	break;	//*	yellow
		case 2:		textColor	=	CV_RGB(0x00,	0xff,	0xff);	break;	//*	cyan
		case 3:		textColor	=	CV_RGB(0x00,	0xff,	0x00);	break;	//*	green
		default:	textColor	=	CV_RGB(0xff,	0xff,	0xff);	break;	//*	white

	}
// [ProcessReadAll_IMU  ] IMU-HEADING 114.937500000000
// [ProcessReadAll_IMU  ] IMU-ROLL 10.500000000000
// [ProcessReadAll_IMU  ] IMU-PITCH -24.500000000000
// [ProcessReadAll_IMU  ] IMU-CAL-GYRO 3
// [ProcessReadAll_IMU  ] IMU-CAL-ACCEL 3
// [ProcessReadAll_IMU  ] IMU-CAL-MAGN 3
// [ProcessReadAll_IMU  ] IMU-CAL-SYS 0
	if (strcasecmp(keywordString, "IMU-HEADING") == 0)
	{
		sprintf(textString, "H=%3.3f", valueDouble);
		SetWidgetText(kTab_Camera, kCameraBox_IMU_Heading, textString);
	}
	else if (strcasecmp(keywordString, "IMU-ROLL") == 0)
	{
		sprintf(textString, "R=%3.3f", valueDouble);
		SetWidgetText(kTab_Camera, kCameraBox_IMU_Roll, textString);
	}
	else if (strcasecmp(keywordString, "IMU-PITCH") == 0)
	{
		sprintf(textString, "P=%3.3f", valueDouble);
		SetWidgetText(kTab_Camera, kCameraBox_IMU_Pitch, textString);
	}
	else if (strcasecmp(keywordString, "IMU-CAL-MAGN") == 0)
	{
		sprintf(textString, "IMU (%d)", valueInt);
		SetWidgetText(kTab_Camera,		kCameraBox_IMU_Title, textString);

		SetWidgetTextColor(kTab_Camera, kCameraBox_IMU_Heading, textColor);
		SetWidgetTextColor(kTab_Camera, kCameraBox_IMU_Roll,	textColor);
		SetWidgetTextColor(kTab_Camera, kCameraBox_IMU_Pitch,	textColor);
	}
	else if (strcasecmp(keywordString, "IMU-CAL-SYS") == 0)
	{
		SetWidgetBGColor(kTab_Camera,	kCameraBox_IMU_Title, textColor);
	}

#endif // _SUPPORT_REMOTE_IMU_
}


#endif // _ENABLE_CTRL_CAMERA_

