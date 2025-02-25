//*****************************************************************************
//#include	"windowtab_preview.h"



#ifndef	_WINDOWTAB_PREVIEW_H_
#define	_WINDOWTAB_PREVIEW_H_

#ifndef	_WINDOW_TAB_H_
	#include	"windowtab.h"
#endif

//*****************************************************************************
enum
{
	kPreviewBox_Title	=	0,

	kPreviewBox_Size,
	kPreviewBox_Logo,
	kPreviewBox_FileName,

	kPreviewBox_Exposure_Label,
	kPreviewBox_Exposure_Slider,
	kPreviewBox_Exposure,
	kPreviewBox_Exposure_Up,
	kPreviewBox_Exposure_Down,

	kPreviewBox_Gain_Label,
	kPreviewBox_Gain_Slider,
	kPreviewBox_Gain,
	kPreviewBox_Gain_Up,
	kPreviewBox_Gain_Down,

	kPreviewBox_State,
	kPreviewBox_AutoExposure,

	kPreviewBox_ReadMode0,
	kPreviewBox_ReadMode1,
	kPreviewBox_ReadMode2,
	kPreviewBox_ReadMode3,
	kPreviewBox_ReadMode4,
	kPreviewBox_ReadModeOutline,


	kPreviewBox_RefID,

	kPreviewBox_Reset,
	kPreviewBox_StartExposure,

	kPreviewBox_GetPicture,

	kPreviewBox_ImageDisplay,

	kPreviewBox_ProgressBar,

//	kPreviewBox_AlpacaLogo,
	kPreviewBox_IPaddr,
	kPreviewBox_Readall,


	kPreviewBox_last
};


//**************************************************************************************
class WindowTabPreview: public WindowTab
{
	public:
		//
		// Construction
		//
				WindowTabPreview(	const int	xSize,
									const int	ySize,
									cv::Scalar	backGrndColor,
									const char	*windowName);
		virtual	~WindowTabPreview(void);

//		virtual	void	DrawGraphWidget(const int widgetIdx);
		virtual	void	SetupWindowControls(void);
//		virtual	void	DrawWindow(void);
//		virtual void	HandleKeyDown(const int keyPressed);
		virtual	void	ProcessButtonClick(const int buttonIdx, const int flags);
//		virtual	void	ProcessDoubleClick(const int	widgetIdx,
//											const int	event,
//											const int	xxx,
//											const int	yyy,
//											const int	flags);

				void	SetDeviceInfo(TYPE_REMOTE_DEV *alpacaDevice);
				void	ForceUpdate(void);
				void	BumpGain(const int howMuch);
				void	BumpExposure(const double howMuch);
				void	ToggleLiveMode(void);
				void	ToggleSideBar(void);
				void	ToggleAutoExposure(void);
				void	ToggleDisplayImage(void);
				void	ToggleCooler(void);
				void	SetTempartueDisplayEnable(bool enabled);
				void	SetReceivedFileName(const char *newFileName);
				void	UpdateCameraState(TYPE_ALPACA_CAMERASTATE newCameraState);

				void	StartExposure(void);
				void	DownloadImage(void);

				char			cAlpacaDeviceName[64];
				TYPE_REMOTE_DEV	cAlpacaDevInfo;

				IplImage		*cOpenCVdownLoadedImage;
				char			cDownLoadedFileNameRoot[256];

				TYPE_ALPACA_CAMERASTATE		cAlpacaCameraState;


};


#endif // _WINDOWTAB_ABOUT_H_

