//
//  CommonDefine.h
//  IntelligentRingKing
//
//  Created by qf on 14-5-11.
//  Copyright (c) 2014年 JAGA. All rights reserved.
//

#ifndef IntelligentRingKing_CommonDefine_h
#define IntelligentRingKing_CommonDefine_h

#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height >= 568)

typedef struct IRKPhone2DeviceAlarms{
    BOOL is_call;
    BOOL is_email;
    BOOL is_sms;
    BOOL is_calendar;
    BOOL is_phone_lowpower;
    
}IRKPhone2DeviceAlarms, *p_IRKPhone2DeviceAlarms;

#define TEMP_TYPE_C 1
#define TEMP_TYPE_F 0

typedef struct IRKPhone2DeviceWeather{
    int weather_type;
    int temperature;
    int temperature_type;
}IRKPhone2DeviceWeather;

#define MAX_MAIN_PAGE_COUNT  5

typedef enum
{
	IRKConnectionStateConnected,	// X-Axis labels will be rotated 90 degrees counter-clockwise
	IRKConnectionStateUnConnected, // X-Axis labels are horizontal (watch out that they don't over-lap! You can adjust the font through properties defined in this class)
	IRKConnectionStateUnknown		// X-Axis labels are rotated 45 degrees counter-clockwise
} IRKConnectionState;
//notify key
#define notify_key_did_scan_device @"NOTIFY_KEY_DID_SCAN_DEVICE"
#define notify_key_did_connect_device @"NOTIFY_KEY_DID_CONNECT_DEVICE"
#define notify_key_did_connect_device_err @"NOTIFY_KEY_DID_CONNECT_DEVICE_ERR"
#define notify_key_did_disconnect_device @"NOTIFY_KEY_DID_DISCONNECT_DEVICE"
#define notify_key_connect_state_changed @"NOTIFY_KEY_CONNECT_STATE_CHANGED"
#define notify_key_will_enter_background @"notify_key_will_enter_background"
#define notify_key_did_ble_characteristic_notify_update @"notify_key_did_ble_characteristic_notify_update"
#define notify_key_bong_to_phone_read_device_data_resp @"notify_key_bong_to_phone_read_device_data_resp"
#define notify_key_did_ble_characteristic_batterylevel_notify_update @"notify_key_did_ble_characteristic_batterylevel_notify_update"
#define notify_key_did_get_current_steps @"notify_key_did_get_current_steps"
#define notify_key_take_photo   @"notify_key_take_photo"
#define notify_key_event_call_disconnected @"notify_key_event_call_disconnected"
#define notify_key_event_call_connected @"notify_key_event_call_connected"
#define notify_key_event_call_incoming @"notify_key_event_call_incoming"

#define notify_key_read_device_time_ok @"notify_key_read_device_time_ok"
#define notify_key_set_device_time @"notify_key_set_device_time"
#define notify_key_has_reminder @"notify_key_has_reminder"
#define notify_band_has_kickoff @"notify_band_has_kickoff"
#define notify_band_has_disconnect @"notify_band_has_disconnect"
#define notify_key_location_update @"notify_key_location_update"
#define notify_key_weather_update @"notify_key_weather_update"
#define notify_key_location_geacoder_update @"geacoder_update"
#define notify_key_did_recv_device_sync_data @"did_recve_device_sync_data"
#define notify_key_did_finish_device_sync @"did_finish_device_sync"
#define notify_key_connect_timeout @"connect_timeout"
#define notify_key_start_sync_history @"start_sync_history"
#define notify_key_start_set_personinfo @"Set_Person"
#define notify_key_start_set_hydration @"Set_Hydration"
#define notify_key_ble_power_on @"ble_power_on"
#define notify_key_ble_power_off @"ble_power_off"

#define notify_key_stop_sync @"stop_sync"

#define notify_key_sycn_finish_need_reloaddata @"need_reloadData"
#define notify_key_read_sport_data_finish @"read_sportdata_finish"
#define notify_key_did_finish_modeset @"finish_modeset"
#define notify_key_did_finish_modeset_err @"fail_modset"
#define notify_key_heartbeat @"heartbeat"
#define notify_key_has_Login @"loingnow"
#define notify_key_start_location @"startlocation"
#define notify_key_did_finish_send_cmd @"finish_send_cmd"
#define notify_key_did_finish_send_cmd_err @"finish_send_cmd_err"
#define notify_key_did_finish_weather_cmd @"weatherfinish"
#define notify_key_did_get_member_info @"get_member_info"
#define notify_key_did_modify_nickname @"modify_nickname"
#define notify_key_did_get_headimage @"get_headimg"
#define notify_key_did_get_mac_id @"getmacid"
#define notify_key_did_update_rssi @"didupdaterssi"

#define notify_key_clear_ok @"clearok"
#define notify_key_clear_err @"clearerr"
#define notify_key_clear_all_data @"clearalldata"
#define notify_key_clear_timeout @"cleartimeout"
#define notify_key_did_finish_send_clock_ok @"clockok"
#define notify_key_did_finish_send_clock_err @"clockerr"
#define notify_key_did_get_activity_report @"activity_report"
#define notify_key_monitor_change @"monitorchange"
#define notify_key_start_running_request @"runreq"
#define notify_key_start_running_location @"runloc"
#define notify_key_pause_running_location @"runpause"
#define notify_key_stop_running_location @"runstop"
#define notify_key_running_did_location @"rundidloc"
#define notify_key_did_click_on_annotation @"onanno"
#define notify_key_ble_ota_resp @"OTAReadValue"
#define notify_key_ble_ota_charater_change @"OTAChchg"
#define notify_key_next_command @"nextcommand"
#define notify_key_check_ota @"checkota"
#define notify_key_start_OTA @"startOTA"
#define notify_key_open_otaview @"openotaview"
#define notify_key_did_get_sensor_report @"sensor_report"
#define notify_key_did_change_sensor_status @"sensor_change"
#define notify_key_did_send_nodic_ota0 @"nordicota0"
#define notify_key_stop_read_heart_data @"stopheart"
#define notify_key_did_set_max_heart @"notify_key_did_set_max_heart"

#define notify_key_synckey_changed_memberinfo @"synckeymember"
#define notify_key_download_synckey_changed @"downloadsynckeychanged"

#define notify_key_sync_networkdata_finish @"syncnetworkdatafinish"
#define notify_key_syncnetwork_data @"syncnetwork"
#define notify_key_syncdata_to_network_ok @"syncnetworkok"

//配置管理
#define CONFIG_KEY_FIRST_RUN @"CONFIG_KEY_FIRST_RUN"

#define CONFIG_KEY_IN_FACTORY @"CONFIG_KEY_IN_FACTORY"
#define CONFIG_KEY_ENABLE_AUTOHEART @"CONFIG_KEY_ENABLE_AUTOHEART"
#define CONFIG_KEY_ENABLE_ANTILOST @"CONFIG_KEY_ENABLE_ANTILOST"
#define CONFIG_KEY_ENABLE_BRIGHTSCREEN @"CONFIG_KEY_ENABLE_BRIGHTSCREEN"
#define CONFIG_KEY_ENABLE_NODISTURB @"CONFIG_KEY_ENABLE_NODISTURB"
#define CONFIG_KEY_ENABLE_RIGHTHAND @"CONFIG_KEY_ENABLE_RIGHTHAND"

#define CONFIG_KEY_ENABLE_TAKEPHOTO @"CONFIG_KEY_ENABLE_TAKEPHOTO"
#define CONFIG_KEY_ENABLE_WHATSAPP @"CONFIG_KEY_ENABLE_WHATSAPP"
#define CONFIG_KEY_ENABLE_QQ @"CONFIG_KEY_ENABLE_QQ"

#define CONFIG_KEY_ENABLE_FACEBOOK @"CONFIG_KEY_ENABLE_FACEBOOK"
#define CONFIG_KEY_ENABLE_TWITTER @"CONFIG_KEY_ENABLE_TWITTER"
#define CONFIG_KEY_ENABLE_SKYPE @"CONFIG_KEY_ENABLE_SKYPE"
#define CONFIG_KEY_ENABLE_LINE @"CONFIG_KEY_ENABLE_LINE"

#define CONFIG_KEY_ENABLE_WECHAT @"CONFIG_KEY_ENABLE_WECHAT"
#define CONFIG_KEY_ENABLE_MAILALERT @"CONFIG_KEY_ENABLE_MAILALERT"
#define CONFIG_KEY_ENABLE_BONGCONTROLMUSIC @"CONFIG_KEY_ENABLE_BONGCONTROLMUSIC"
#define CONFIG_KEY_ENABLE_PROJECT_ALERT @"CONFIG_KEY_ENABLE_PROJECT_ALERT"
#define CONFIG_KEY_ENABLE_INCOMING_CALL @"CONFIG_KEY_ENABLE_INCOMING_CALL"
#define CONFIG_KEY_TARGET_STEPS @"CONFIG_KEY_TARGET_STEPS"
#define CONFIG_KEY_TARGET_RUNSTEPS @"CONFIG_KEY_TARGET_RUNSTEPS"
#define CONFIG_KEY_ENABLE_REMINDER_NOTIFY @"CONFIG_KEY_ENABLE_REMINDER_NOTIFY"
#define CONFIG_KEY_TARGET_DISTANCE @"CONFIG_KEY_TARGET_DISTANCE"
#define CONFIG_KEY_TARGET_CAROLIE @"CONFIG_KEY_TARGET_CAROLIE"
#define CONFIG_KEY_TARGET_SLEEPTIME @"CONFIG_KEY_TARGET_SLEEPTIME"
#define CONFIG_KEY_PERSON_INFO_MALE @"CONFIG_KEY_PERSON_INFO_MALE"
#define CONFIG_KEY_PERSON_INFO_HEIGHT @"CONFIG_KEY_PERSON_INFO_HEIGHT"
#define CONFIG_KEY_PERSON_INFO_WEIGHT @"CONFIG_KEY_PERSON_INFO_WEIGHT"
#define CONFIG_KEY_PERSON_INFO_BIRTHYEAR @"CONFIG_KEY_PERSON_INFO_BIRTHYEAR"
#define CONFIG_KEY_PERSON_INFO_STRIDE @"CONFIG_KEY_PERSON_INFO_STRIDE"
#define CONFIG_KEY_LAST_CONNECT_BONG_UUID @"CONFIG_KEY_LAST_CONNECT_BONG_UUID"
#define CONFIG_KEY_BONG_SERVICE_UUID @"CONFIG_KEY_BONG_SERVICE_UUID"
#define CONFIG_KEY_BONG_NOTIFYCHARACTER_UUID @"CONFIG_KEY_BONG_NOTIFYCHARACTER_UUID"
#define CONFIG_KEY_BONG_WRITECHARACTER_UUID @"CONFIG_KEY_BONG_WRITECHARACTER_UUID"
#define CONFIG_KEY_BONG_BATTERYCHARACTER_UUID @"CONFIG_KEY_BONG_BATTERYCHARACTER_UUID"
#define CONFIG_KEY_LAST_READ_DETAIL_DATATIME @"CONFIG_KEY_LAST_READ_DETAIL_DATATIME"
#define CONFIG_KEY_LAST_READ_SPORT_DATA_TIME @"CONFIG_KEY_LAST_READ_SPORT_DATA_TIME"
#define CONFIG_KEY_MEASUREUNIT @"CONFIG_KEY_MEASUREUNIT"
#define CONFIG_KEY_NICKNAME @"CONFIG_KEY_NICKNAME"
#define CONFIG_KEY_ENABLE_SMS_NOTIFY @"CONFIG_KEY_ENABLE_SMS_NOTIFY"
#define CONFIG_KEY_ENABLE_DEVICE_CALL @"CONFIG_KEY_ENABLE_DEVICE_CALL"
#define CONFIG_KEY_SYNC_PERSONDATA @"CONFIG_KEY_SYNC_PERSONDATA"
#define CONFIG_KEY_CURRENT_STEPS @"CURRENT_STEPS"
#define CONFIG_KEY_CURRENT_HAERT @"CURRENT_HEART"
#define CONFIG_KEY_CURRENT_CAL @"CURRENT_CAL"
#define CONFIG_KEY_CURRENT_DISTANCE @"CURRENT_DISTANCE"
#define CONFIG_KEY_LAST_LAT @"CONFIG_KEY_LAST_LAT"
#define CONFIG_KEY_LAST_LONG @"CONFIG_KEY_LAST_LONG"
#define CONFIG_KEY_LAST_CITY @"CONFIG_KEY_LAST_CITY"
#define CONFIG_KEY_LAST_LOCATION_DETAIL @"LOCATION_DETAIL"
#define CONFIG_KEY_IS_REGIST @"CONFIG_KEY_IS_REGIST"
#define CONFIG_KEY_ACCOUNT @"ACCOUNT"
#define CONFIG_KEY_PASSWORD @"PASSWORD"
#define CONFIG_KEY_TOKEN @"TOKEN"
#define CONFIG_KEY_ENABLE_LONGSIT @"LONGSIT"
#define CONFIG_KEY_ENABLE_LOWBATTERY @"Lowbattery"
#define CONFIG_KEY_LONGSIT_TIME @"LONGSITTIME"
#define CONFIG_KEY_LASTLOGIN_TIME @"LASTLOGINTIME"
#define CONFIG_KEY_LASTLOGIN_USERNAME @"lastusername"
#define CONFIG_KEY_ENABLE_CLOCK @"CLOCK"
#define CONFIG_KEY_CLOCK_HOUR @"CLOCK_HOUR"
#define CONFIG_KEY_CLOCK_MIN @"CLOCK_MINUTE"
#define CONFIG_KEY_CLOCK_PERIOD @"CLOCK_PERIOD"
#define CONFIG_KEY_LONGSIT_PERIOD @"LONGSIT_PERIOD"
#define CONFIG_KEY_CLOCK_SMART @"CLOCK_SMART"
#define CONFIG_KEY_LONGSIT_START @"LONGSIT_START"
#define CONFIG_KEY_LONGSIT_END @"LONGSIT_END"
#define CONFIG_KEY_SLEEPMODE @"IS_SLEEPMODE"
#define CONFIG_KEY_ENABLE_SHOCK @"ENABLE_SHOCK"
#define CONFIG_KEY_PERSON_INFO_BLOODTYPE @"BLOODTYPE"
#define CONFIG_KEY_UID @"MEMBER_UID"
#define CONFIG_KEY_PERSON_INFO_HEADIMGURL @"HEADIMGURL"
#define CONFIG_KEY_PERSON_INFO_HAS_CUSTOM_HEADIMG @"hascustomimage"
#define CONFIG_KEY_PERSON_INFO_IS_MEMBERINFO_CHANGE @"ismemberinfochange"
#define CONFIG_KEY_FOBBIDEN_FLAG @"fobbiden flag"
#define CONFIG_KEY_LAST_C6_TIME @"lastc6time"
#define CONFIG_KEY_LAST_C6_VALUE @"lastc6value"
#define CONFIG_KEY_GEARSUBTYPE @"gsbt"
#define CONFIG_KEY_SCREENTIME @"sct"
#define CONFIG_KEY_TARGET_ACTIVITY @"activity"
#define CONFIG_KEY_AUTOSYNC @"autosync"
#define CONFIG_KEY_ALARM_URL @"alarm_url"
#define CONFIG_KEY_DEVICEID @"DID"

#define MEASURE_UNIT_METRIX 1
#define MEASURE_UNIT_US 2
#define COMMON_CALORIES_RATE 0.0395
//蓝牙相关
typedef enum
{
	IRKFindBleDeviceOK,
	IRKFindBleDeviceFAILWithBleNotPowerON,
	IRKFindBleDeviceFAILWithoutBle
} IRKFindBleDevice;
//0号位置表示手环连接
#define BLECONNECTED_DEVICE_BONG_KEY @"ConnectedBong"
#define BLECONNECTED_DEVICE_BONG_NOTIFY_CHARATERISTIC_KEY @"ConnectedBong_Notify_CH"
#define BLECONNECTED_DEVICE_BONG_WRITE_CHARATERISTIC_KEY @"ConnectedBong_Write_CH"
#define BLECONNECTED_DEVICE_BONG_BATTERY_CHARATERISTIC_KEY @"ConnectedBong_Battery_CH"
#define BLECONNECTED_DEVICE_BONG_NOTIFY_ADV_CHARATERISTIC_KEY @"ConnectedBong_Notify_CH_ADV"
#define BLECONNECTED_DEVICE_BONG_WRITE_ADV_CHARATERISTIC_KEY @"ConnectedBong_Write_CH_ADV"
#define BLECONNECTED_DEVICE_BONG_NOTIFY_OTACMD_CHARATERISTIC_KEY @"ConnectedBong_Notify_CH_OTACMD"
#define BLECONNECTED_DEVICE_BONG_NOTIFY_OTADATA_CHARATERISTIC_KEY @"ConnectedBong_Notify_CH_OTADATA"
#define BLECONNECTED_DEVICE_BONG_WRITE_OTADATA_CHARATERISTIC_KEY @"ConnectedBong_Write_CH_OTADATA"


#define BLE_DEVICE_SEVICE_UUID @"FFF0"
#define BLE_DEVICE_CHARACTERISTIC_NOTIFY_UUID @"FFF1"
#define BLE_DEVICE_CHARACTERISTIC_BATTERYLEVEL @"2A19"
#define BLE_DEVICE_CHARACTERISTIC_WRITE_UUID @"FFF2"

#define BLE_RECV_DATA_TIMEOUT 10

//汇杰通蓝牙通信协议
//phone 2 bong
#define HJT_CMD_PHONE2DEVICE_SET_BLE_NAME 0x81
#define HJT_CMD_PHONE2DEVICE_SET_BLE_MATCH_PASSWORD 0x85
#define HJT_CMD_PHONE2DEVICE_SET_PERSONINFO 0x83
#define HJT_CMD_PHONE2DEVICE_SET_HYDRATION 0x84
#define HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_WEEK 0xC4
#define HJT_CMD_PHONE2DEVICE_READ_SPORT_DATA_BY_DAY 0xA2
#define HJT_CMD_PHONE2DEVICE_READ_DATA_CURVE_BY_DATE 0xC7
#define HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA 0xC6
#define HJT_CMD_PHONE2DEVICE_READ_DEVICE_DATA_AND_TOTAL_STEPS 0xC8
#define HJT_CMD_PHONE2DEVICE_RESET 0x87
#define HJT_CMD_PHONE2DEVICE_CLEAR_DATA 0x88
#define HJT_CMD_PHONE2DEVICE_SET_DEVICE_TIME 0xC2
#define HJT_CMD_PHONE2DEVICE_READ_DEVICE_TIME 0x89
#define HJT_CMD_PHONE2DEVICE_SET_SLEEP_TIME 0x9D
#define HJT_CMD_PHONE2DEVICE_SET_PARAM 0x9B
#define HJT_CMD_PHONE2DEVICE_SET_LONGSIT 0x86


#define HJT_CMD_PHONE2DEVICE_ALARM 0xF1
#define HJT_CMD_PHONE2DEVICE_WEATHER 0xF2
#define HJT_CMD_PHONE2DEVICE_ANTILOST 0xF3
#define HJT_CMD_PHONE2DEVICE_MODESET 0xF4
#define HJT_CMD_PHONE2DEVICE_INCOMINGCALLNBR 0xF7
#define HJT_CMD_PHONE2DEVICE_LONGSIT 0xF9
#define HJT_CMD_PHONE2DEVICE_GETMAC 0xFA
#define HJT_CMD_PHONE2DEVICE_MINFO 0xFB
#define HJT_CMD_PHONE2DEVICE_NOTIFY 0xFF
#define HJT_CMD_PHONE2DEVICE_SENSORDATA 0xB1



#define HJT_ADV_CMD_PHONE2DEVICE_ACTIVITY_MONITOR 0x94
#define HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_OK 0x34
#define HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_MONITOR_ERR 0x14
#define HJT_CMD_PHONE2DEVICE_SYNC_SPORT_DATA 0x95
#define HJT_CMD_PHONE2DEVICE_SENSOR_CHANGE 0x93

#define HJT_CMD_PHONE2DEVICE_ANCS_PAIR 0xA1
#define HJT_CMD_PHONE2DEVICE_NORDIC_INTO_OTA 0xFC
#define HJT_CMD_PHONE2DEVICE_NORDIC_INTO_OTA 0xFC
#define HJT_CMD_ALARM_NAME 0xFD


//bong 2 phone
#define HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_OK 0x21
#define HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_OK 0x25
#define HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_OK 0x23
#define HJT_CMD_DEVICE2PHONE_SET_HYDRATION_OK 0x39
#define HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_OK 0x24
#define HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_OK 0x31
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_OK 0x26
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_OK 0x30
#define HJT_CMD_DEVICE2PHONE_RESET_OK 0x27
#define HJT_CMD_DEVICE2PHONE_CLEAR_DATA_OK 0x28
#define HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_OK 0x22
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_OK 0x29
#define HJT_CMD_DEVICE2PHONE_LONGSIT_OK 0x32

#define HJT_CMD_DEVICE2PHONE_SET_BLE_NAME_ERR 0x01
#define HJT_CMD_DEVICE2PHONE_SET_BLE_MATCH_PASSWORD_ERR 0x05
#define HJT_CMD_DEVICE2PHONE_SET_PERSONINFO_ERR 0x03
#define HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_WEEK_ERR 0x04
#define HJT_CMD_DEVICE2PHONE_READ_DATA_CURVE_BY_DATE_ERR 0x0B
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_ERR 0x06
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_DATA_AND_TOTAL_STEPS_ERR 0x0A
#define HJT_CMD_DEVICE2PHONE_RESET_ERR 0x07
#define HJT_CMD_DEVICE2PHONE_CLEAR_DATA_ERR 0x08
#define HJT_CMD_DEVICE2PHONE_SET_DEVICE_TIME_ERR 0x02
#define HJT_CMD_DEVICE2PHONE_READ_DEVICE_TIME_ERR 0x09
#define HJT_CMD_DEVICE2PHONE_LONGSIT_ERR 0x0D

#define HJT_CMD_DEVICE2PHONE_ANTILOST 0xF3
#define HJT_CMD_DEVICE2PHONE_REQUEST_TIME 0xF4
#define HJT_CMD_DEVICE2PHONE_PHOTO 0xF5
#define HJT_CMD_DEVICE2PHONE_MUSIC 0xF6
#define HJT_CMD_DEVICE2PHONE_GPS_ALTITUDE 0xF8
#define HJT_CMD_DEVICE2PHONE_GETMAC 0xFA
#define HJT_CMD_DEVICE2PHONE_MINFO 0xFB
#define HJT_CMD_DEVICE2PHONE_OTA_REQUEST 0xFD

#define HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_OK 0x2D
#define HJT_CMD_DEVICE2PHONE_SET_SLEEP_TIME_ERR 0x1D

#define HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_OK 0x2B
#define HJT_CMD_DEVICE2PHONE_SET_BANDPRAM_ERR 0x1B


#define HJT_ADV_CMD_DEVICE2PHONE_ACTIVITY_REPORT 0x97

#define HJT_CMD_DEVICE2PHONE_SYNC_SPORT_DATA_OK 0x35
#define HJT_CMD_DEVICE2PHONE_SYNC_SPORT_DATA_ERR 0x15

#define HJT_CMD_DEVICE2PHONE_ANCS_OK 0xA1
#define HJT_CMD_DEVICE2PHONE_SENSOR_CHANGE_OK 0x33
#define HJT_CMD_DEVICE2PHONE_SENSOR_CHANGE_ERR 0x13

#define HJT_CMD_DEVICE2PHONE_SENSOR_REPORT 0x99

#define HJT_CMD_DEVICE2PHONE_SETALARMNAME_OK 0xFD
#define HJT_CMD_DEVICE2PHONE_SETALARMNAME_ERR 0x3D
#define HJT_CMD_DEVICE2PHONE_NOTIFY_OK 0xFF
#define HJT_CMD_DEVICE2PHONE_SENSORDATA_OK 0xB1
#define HJT_CMD_DEVICE2PHONE_SENSORDATA_ERR 0x61




////参数定义 for 0xC6 READ_DEVICE_DATA
#define HJT_PARAM_LID_MONDAY 0x01
#define HJT_PARAM_LID_TUESDAY 0x02
#define HJT_PARAM_LID_WEDNESDAY 0x03
#define HJT_PARAM_LID_THURSDAY 0x04
#define HJT_PARAM_LID_FRIDAY 0x05
#define HJT_PARAM_LID_SATURDAY 0x06
#define HJT_PARAM_LID_SUNDAY 0x07
#define HJT_PARAM_LID_CURRENT_STEPS 0x08

#define HJT_STEP_MODE_DAILY 0
#define HJT_STEP_MODE_SLEEP 1
#define HJT_STEP_MODE_SPORT 2

#define HJT_SLEEP_MODE_AWAKE 30
#define HJT_SLEEP_MODE_EXLIGHT 20
#define HJT_SLEEP_MODE_LIGHT 10

//10分钟一个数据
#define HJT_DATA_TIME_INTERVAL  60*10
#define HJT_MAX_STORE_DATA_TIME  6*24*60*60
#define HJT_MAX_STORE_SPORT_DATA_TIME 2*24*60*60

#define HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE 0x01
#define HJT_ANTILOST_TYPE_PHONE_CALL_DEVICE_END 0xA1
#define HJT_ANTILOST_TYPE_OUT_OF_RANGE 0x02
#define HJT_ANTILOST_TYPE_OUT_OF_RANGE_END 0xA2

#define HJT_ANTILOST_CMD_CALL_PHONE 0x01
#define HJT_ANTILOST_CMD_CALL_PHONE_END 0xA1

#define HJT_MUSIC_CMD_PLAY 0x01
#define HJT_MUSIC_CMD_NEXT 0x03
#define HJT_MUSIC_CMD_BACK 0x02


#define ALARM_RSSI_VALUE -95
#define NORMAL_RSSI_VALUE -80
//#define ALARM_RSSI_VALUE -70
//#define NORMAL_RSSI_VALUE -65
#define MAX_RSSI_SAMPLES 5


#define IRKDATATYPE_STEP  0
#define IRKDATATYPE_SLEEP 1

#define CHECK_REMINDER_TIMEINTERVAL 60

#define HJT_C4_TIMEOUT 0.1
#define HJT_C6_TIMEOUT 9

#define WEATHER_API_TYPE_OPENWEATHERORG 1
#define WeatherAPIKey @"7e1da2b76ad3ee8a75bf2568c6739738"
#define WEATHER_API_URL @"http://api.openweathermap.org/data/2.5/weather?lat=%.7f&lon=%.7f&APPID=%@&units=%@"

#define WEATHER_UV_API_URL @"http://api.openweathermap.org/v3/uvi/%.7f,%.7f/2016-11-14T18:18:00Z.json?appid=%@"

#define WEATHER_TYPE_CLEAR 0x1
#define WEATHER_TYPE_CLOUDY 0x3
#define WEATHER_TYPE_DRIZZLE 0x4
#define WEATHER_TYPE_RAIN 0x5
#define WEATHER_TYPE_HEAVYRAIN 0x6
#define WEATHER_TYPE_THUNDERRAIN 0x7
#define WEATHER_TYPE_LIGHTSNOW 0x8
#define WEATHER_TYPE_SNOW 0x9
#define WEATHER_TYPE_HEAVYSNOW 0xA
#define WEATHER_TYPE_SNOWRAIN 0xB
#define WEATHER_TYPE_FLOG 0xC
#define WEATHER_TYPE_HAIL 0xD
#define WEATHER_TYPE_HAILRAIN 0xE
#define WEATHER_TYPE_SAND 0xF
#define WEATHER_TYPE_STORM 0x10
#define WEATHER_TYPE_WIND 0x11
#define WEATHER_TYPE_GALE 0x12
#define WEATHER_TYPE_HEAVYGALE 0x13
#define WEATHER_TYPE_TORNADO 0x14
#define WEATHER_TYPE_THONDERSTORM 0x15
#define WEATHER_TYPE_HEAVYTHONDERSTORM 0x16

#define GET_LOCATION_TIME 60*60

#define SLEEP_STATE_GOOD 0.9
#define SLEEP_STATE_NORMAL 0.7
#define SLEEP_STATE_LACK 0.5

#define RUNMODE_ACTIVE 1
#define RUNMODE_BACKGROUD 2

#define KG2LB 2.2046226
#define M2FEET 3.2808
#define M2INCH 39.3700787
#define KM2MILE 0.6213712
#define CM2INCH 0.3937008
#define CALQUOTE 0.78
#define RUNNINGCALORIEQUOTE 1.036
#define MILE2FEET 5280
#define MILE2INCH 63360
#define MILE2YARD 1760
#define YARD2INCH 36


#define MAX_LOGIN_TIMER 7*24*60*60
#define SERVER_URL @"http://api.keeprapid.com:8081/"

#define IPSVR_URL @"ronaldo-ipsvr"


#define ERROR_CODE_NOUSER @"404"
#define ERROR_CODE_PASSWORD @"407"
#define ERROR_CODE_401 @"401"
#define ERROR_CODE_403 @"403"


#define PERIOD_1 0x01
#define PERIOD_2 0x02
#define PERIOD_3 0x04
#define PERIOD_4 0x08
#define PERIOD_5 0x10
#define PERIOD_6 0x20
#define PERIOD_7 0x40

#define WORKDAY 0x3E//0x1F
#define ALLDAY 0x7F

#define RSSI_LEVEL0 -100
#define RSSI_LEVEL1 -90
#define RSSI_LEVEL2 -80
#define RSSI_LEVEL3 -65
#define RSSI_LEVEL4 -50

#define READ_WEATHER_TIMEOUT 12*60*60

//#if defined(CUSTOM_OBANGLE)
//#define VID @"000005001001"
//#elif defined(CUSTOM_GETFIT)
//#define VID @"000012001010"
//#elif defined(CUSTOM_FITGO)
//#define VID @"000012001009"
//#elif defined(CUSTOM_HAIER)
//#define VID @"000012001007"
//#elif defined(CUSTOM_GORBILLER)
//#define VID @"000012001008"
//#elif defined(CUSTOM_PUZZLE)
//#define VID @"000012001006"
//#elif defined(CUSTOM_HIMOVE)
//#if CUSTOM_MGCOOLBAND2
//#define VID @"000012001014"
//#else
#define VID @"000016001001"
//#endif


//#elif defined(CUSTOM_NOMI)
//#define VID @"000012001013"
//#elif defined(CUSTOM_POLAROID)
//#define VID @"000005001002"
//#elif defined(CUSTOM_FITBAND)
//#define VID @"000006001001"
//#elif defined(CUSTOM_ELISUNG)
//#define VID @"000007001001"
//#elif defined(CUSTOM_POWERWATCH)
//#define VID @"000010001001"
//#elif defined(CUSTOM_TOUCHBAND)
//#define VID @"000010001003"
//#elif defined(CUSTOM_SMARTWRISTBAND)
//#define VID @"000010001002"
//#elif defined(CUSTOM_GOBAND)
//#define VID @"000012001001"
//#elif defined(CUSTOM_ZZB)
//#define VID @"ZZB"
//#elif defined(CUSTOM_YFT)
//#define VID @"000012001002"
//#elif defined(CUSTOM_FITRIST)
//#define VID @"000012001003"
//#elif defined(CUSTOM_WISTARS)
//#define VID @"000013001001"
//#elif defined(CUSTOM_BLOX)
//#define VID @"000012001004"
//#elif defined(CUSTOM_SPRING)
//#define VID @"000010001004"
//#elif defined(CUSTOM_SPRINFIT)
//#define VID @"000012001005"
//#elif defined(CUSTOM_CCBAND)
//#define VID @"000015001001"
//#elif defined(CUSTOM_ZZB)
//#define VID @"000012001011"
//#else
//#define VID @"000001001001"
//#endif


#define HEADIMAGE_WIDTH 160
#define HEADIMAGE_HEIGHT 160

#define VERIFY_CODE @"abcdef"

#define MEMBER_URL @"ronaldo-member"
#define GEARCENTER_URL @"ronaldo-gearcenter"
#define DATACENTER_URL @"ronaldo-dc"


#define ERROR_CODE_OK @"200"
#define ERROR_CODE_TOKENOOS @"41004"

#define PROTOCOL_VERSION @"1.0"

#ifdef CUSTOM_CZJK_COMMON
#ifdef CUSTOM_FITRIST
#define DEFAULT_HEIGHT 170.0f
#define DEFAULT_WEIGHT 65.0f
#define DEFAULT_STRIDE 45.0f
#else
#define DEFAULT_HEIGHT 170.0f
#define DEFAULT_WEIGHT 65.0f
#define DEFAULT_STRIDE 45.0f
#endif
#else
#define DEFAULT_HEIGHT 172.0f
#define DEFAULT_WEIGHT 60.0f
#define DEFAULT_STRIDE 45.0f
#endif
#define DEFAULT_BLOODTYPE @"O"
#define DEFAULT_BIRTH @"1980-01-01"
#define DEFAULT_NICKNAME @"Anonymous"
#define GEAR_TYPE @"001"


//OTA
#define RUN_STATE_NORMAL 0
#define RUN_STATE_OTA 1


#define OTA_FILE_BEGIN 0x2E00
#define OTA_PIECE_BYTES 16
#define OTA_MAX_PIECE_COUNT 96
#define OTA_MAX_BLOCK_COUNT 10

#define OTA_CMD_CTRL 0xFD
#define OTA_CMD_CTRL_RSP 0xAD
#define OTA_CMD_SEND_DATA 0xFA
#define OTA_CMD_SEND_DATA_RSP 0xAA

#define OTA_SUB_CMD_START 0x12
#define OTA_SUB_CMD_START_RSP 0xED
#define OTA_SUB_CMD_END 0x23
#define OTA_SUB_CMD_END_RSP_OK 0xDC
#define OTA_SUB_CMD_END_RSP_ERR 0xAE

#define OTA_TIMER_INTERVAL 1

//#if defined(CUSTOM_POWERWATCH)
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/powersensor/fwupdater/%@/%@/update.json"
//#elif defined(CUSTOM_SMARTWRISTBAND)
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/smartwristband/fwupdater/%@/%@/update.json"
//#elif defined(CUSTOM_SPRING)
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/springband/fwupdater/%@/%@/update.json"
//#elif defined(CUSTOM_GOBAND)
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/goband/fwupdater/%@/%@/update.json"
//#elif defined(CUSTOM_ZZB)
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/goband/fwupdater/%@/%@/update.json"
////#elif defined(CUSTOM_FITRIST)
//#elif CUSTOM_FITRIST
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/fitrist/fwupdater/%@/%@/update.json"
//#elif CUSTOM_FITGO
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/fitristpulzz/fwupdater/en/%@/update.json"
//#elif CUSTOM_PUZZLE
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/fitristpulzz/fwupdater/en/%@/update.json"
//#elif CUSTOM_HIMOVE
//#if CUSTOM_MGCOOLBAND2
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/mgcool/fwupdater/en/%@/update.json"
//#else
#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/himove/fwupdater/en/%@/update.json"
//#endif
//
//#elif CUSTOM_NOMI
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/fitristpulzz/fwupdater/en/%@/update.json"
//#else
//#define FIRMWARE_VERSION_SERVER_URL @"http://download.keeprapid.com/apps/smartband/sxrband/fwupdater/%@/%@/update.json"
//#endif


//#define POWERWATCH_BLE_NAME @"power watch"
#define POWERWATCH_BLE_NAME @"POWERWATCH"


#define ACTION_CMD_REGISTER @"register"
#define ACTION_CMD_LOGIN @"login"
#define ACTION_CMD_LOGOUT @"logout"
#define ACTION_CMD_REGISTER_LOGIN @"register_login"
#define ACTION_CMD_MEMBER_UPDATE @"member_update"
#define ACTION_CMD_MEMBER_INFO @"member_info"
#define ACTION_CMD_MEMBER_UPDATE @"member_update"

#define ACTION_CMD_ADD_USER @"user_add"
#define ACTION_CMD_UPDATE_USER @"user_update"
#define ACTION_CMD_UPDATE_ALARM @"update_alarm"
#define ACTION_CMD_GEARAUTH @"gear_auth"
#define ACTION_CMD_UPLOADFITNESS @"upload_fitness"
#define ACTION_CMD_DOWNLOADFITNESS @"download_fitness2"
#define ACTION_CMD_UPLOADSLEEP @"upload_sleep"
#define ACTION_CMD_DOWNLOADSLEEP @"download_sleep"
#define ACTION_CMD_QUERYSYNC @"query_synckey"
#define ACTION_CMD_UPLOAD_RUNRECORD @"upload_runrecord"
#define ACTION_CMD_DOWNLOAD_RUNRECORD @"download_runrecord"
#define ACTION_CMD_UPLOAD_RUNHISTORY @"upload_runhistory"
#define ACTION_CMD_DOWNLOAD_RUNHISTORY @"download_runhistory"
#define ACTION_CMD_DOWNLOAD_BODYFUNCTION @"download_bodyfunction2"
#define ACTION_CMD_UPLOAD_BODYFUNCTION @"upload_bodyfunction"
#define ACTION_CMD_JPUSH_UPDATE @"jpush_update"


#define ACTION_KEY_VERSION @"version"
#define ACTION_KEY_BODY @"body"
#define ACTION_KEY_CMDNAME @"action_cmd"
#define ACTION_KEY_VID @"vid"
#define ACTION_KEY_SEQID @"seq_id"
#define ACTION_KEY_USERNAME @"username"
#define ACTION_KEY_PASSWORD @"pwd"
#define ACTION_KEY_EMAIL @"email"
#define ACTION_KEY_TID @"tid"
#define ACTION_KEY_HEIGHT @"height"
#define ACTION_KEY_WEIGHT @"weight"
#define ACTION_KEY_STRIDE @"stride"
#define ACTION_KEY_NICKNAME @"nickname"
#define ACTION_KEY_BIRTHDAY @"birth"
#define ACTION_KEY_BLOODTYPE @"bloodtype"
#define ACTION_KEY_PHONENAME @"phone_name"
#define ACTION_KEY_PHONEOS @"phone_os"
#define ACTION_KEY_PHONEID @"phone_id"
#define ACTION_KEY_APPVERSION @"app_version"
#define ACTION_KEY_MOBLIE @"mobile"
#define ACTION_KEY_GENDER @"gender"
#define ACTION_KEY_SOURCE @"source"
#define ACTION_KEY_UID @"uid"
#define ACTION_KEY_OLDPASSWORD @"old_password"
#define ACTION_KEY_NEWPASSWORD @"new_password"
#define ACTION_KEY_LANG @"lang"
#define ACTION_KEY_GEARTYPE @"gear_type"
#define ACTION_KEY_NAME @"name"
#define ACTION_KEY_IMG @"img"
#define ACTION_KEY_FORMAT @"format"
#define ACTION_KEY_DEVICENAME @"device_name"
#define ACTION_KEY_GEARSUBTYPE @"gear_subtype"
#define ACTION_KEY_MACID @"mac_id"
#define ACTION_KEY_GOALSTEPS @"goal_steps"
#define ACTION_KEY_GOALCAL @"goal_cal"
#define ACTION_KEY_GOALDISTANCE @"goal_dis"
#define ACTION_KEY_GOALACTIVITY @"goal_act"
#define ACTION_KEY_GOALSLEEP @"goal_slp"
#define ACTION_KEY_YOOGOAL @"yoo_goal"
#define ACTION_KEY_YOOCHALLENGE @"yoo_challenge"
#define ACTION_KEY_YOOCHALLENGEID @"yoo_challengeid"
#define ACTION_KEY_TYPE @"type"
#define ACTION_KEY_ENABLE @"enable"
#define ACTION_KEY_CREATETIME @"createtime"
#define ACTION_KEY_HOUR @"hour"
#define ACTION_KEY_MINUTE @"minute"
#define ACTION_KEY_FIREDATE @"firedate"
#define ACTION_KEY_WEEKLY @"weekly"
#define ACTION_KEY_SNOOZE @"snooze"
#define ACTION_KEY_SNOOZE_REPEAT @"snooze_repeat"
#define ACTION_KEY_DAY @"day"
#define ACTION_KEY_REPEATHOUR @"repeat_hour"
#define ACTION_KEY_REPEATTIMES @"repeat_times"
#define ACTION_KEY_VIBNUMBER @"vib_number"
#define ACTION_KEY_VIBREPEAT @"vib_repeat"
#define ACTION_KEY_YEAR @"year"
#define ACTION_KEY_MONTH @"month"
#define ACTION_KEY_REPEATSCEDUAL @"repeat_schedule"
#define ACTION_KEY_STARTHOUR @"starthour"
#define ACTION_KEY_STARTMINUTE @"startminute"
#define ACTION_KEY_ENDHOUR @"endhour"
#define ACTION_KEY_ENDMINUTE @"endminute"
#define ACTION_KEY_ALARMID @"alarm_id"
#define ACTION_KEY_UNIT @"unit"
#define ACTION_KEY_SOSNUMBER @"sosnumber"
#define ACTION_KEY_APPLANG @"app_lang"
#define ACTION_KEY_SYSLANG @"sys_lang"
#define ACTION_KEY_NATION @"nation"
#define ACTION_KEY_NATIONCODE @"nation_code"
#define ACTION_KEY_PHONETYPE @"phone_type"
#define ACTION_KEY_DID @"did"
#define ACTION_KEY_DATATYPE @"data_type"
#define ACTION_KEY_DATALIST @"datalist"
#define ACTION_KEY_SYNCKEY @"sync_key"
#define ACTION_KEY_TARGETKEY @"target_key"
#define ACTION_KEY_TIMEZONE @"timezone"
#define ACTION_KEY_STEP @"step"
#define ACTION_KEY_CALORIES @"calories"
#define ACTION_KEY_DISTANCE @"distance"
#define ACTION_KEY_TIMEZONE @"timezone"
#define ACTION_KEY_DATETIME @"datetime"
#define ACTION_KEY_HEARTRATE @"heartrate"
#define ACTION_KEY_DURATION @"duration"
#define ACTION_KEY_MODE @"mode"
#define ACTION_KEY_TIMESTAMP @"timestamp"
#define ACTION_KEY_ADDTIMESTAMP @"addtimestamp"
#define ACTION_KEY_STARTTIMESTAMP @"starttimestamp"
#define ACTION_KEY_VALUE @"value"
#define ACTION_KEY_VALUE2 @"value2"
#define ACTION_KEY_JPUSHID @"registrationID"


#define ACTION_KEY_CLOSED @"closed"
#define ACTION_KEY_PACE @"pace"
#define ACTION_KEY_RUNNINGID @"running_id"
#define ACTION_KEY_TOTALCALORIES @"totalcalories"
#define ACTION_KEY_TOTALDISTANCE @"totaldistance"
#define ACTION_KEY_TOTALSTEP @"totalstep"
#define ACTION_KEY_TOTALTIME @"totaltime"
#define ACTION_KEY_ALTITUDE @"altitude"
#define ACTION_KEY_DIRECTION @"direction"
#define ACTION_KEY_LATITUDE @"latitude"
#define ACTION_KEY_LOCTYPE @"locType"
#define ACTION_KEY_LONGITUDE @"longitude"
#define ACTION_KEY_RADIUS @"radius"
#define ACTION_KEY_SATELLITENUMBER @"satellite_number"
#define ACTION_KEY_SPEED @"speed"

#define RESPONE_KEY_TID @"tid"
#define RESPONE_KEY_MEMBERID @"memberid"
#define RESPONE_KEY_ERRORCODE @"error_code"
#define RESPONE_KEY_BODY @"body"
#define RESPONE_KEY_SOURCE @"source"
#define RESPONE_KEY_HEIGHT @"height"
#define RESPONE_KEY_WEIGHT @"weight"
#define RESPONE_KEY_UID @"uid"
#define RESPONE_KEY_STRIDE @"stride"
#define RESPONE_KEY_BIRTH @"birth"
#define RESPONE_KEY_EMAIL @"email"
#define RESPONE_KEY_GEARTYPE @"gear_type"
#define RESPONE_KEY_NAME @"name"
#define RESPONE_KEY_GENDER @"gender"
#define RESPONE_KEY_STATE @"state"
#define RESPONE_KEY_USERINFO @"userinfo"
#define RESPONE_KEY_MOBILE @"mobile"
#define RESPONE_KEY_NICKNAME @"nickname"
#define RESPONE_KEY_IMGURL @"img_url"
#define RESPONE_KEY_IMGFORMAT @"headimg_fmt"
#define RESPONE_KEY_GEARSUBTYPE @"gear_subtype"
#define RESPONE_KEY_BLOODTYPE @"bloodtype"
#define RESPONE_KEY_GOALSTEPS @"goal_steps"
#define RESPONE_KEY_GOALCAL @"goal_cal"
#define RESPONE_KEY_GOALDISTANCE @"goal_dis"
#define RESPONE_KEY_GOALACTIVITY @"goal_act"
#define RESPONE_KEY_GOALSLEEP @"goal_slp"
#define RESPONE_KEY_YOOGOAL @"yoo_goal"
#define RESPONE_KEY_YOOCHALLENGE @"yoo_challenge"
#define RESPONE_KEY_YOOCHALLENGEID @"yoo_challengeid"
#define RESPONE_KEY_ALARMLIST @"alarmlist"
#define RESPONE_KEY_TYPE @"type"
#define RESPONE_KEY_NAME @"name"
#define RESPONE_KEY_ENABLE @"enable"
#define RESPONE_KEY_CREATETIME @"createtime"
#define RESPONE_KEY_HOUR @"hour"
#define RESPONE_KEY_MINUTE @"minute"
#define RESPONE_KEY_FIREDATE @"firedate"
#define RESPONE_KEY_WEEKLY @"weekly"
#define RESPONE_KEY_SNOOZE @"snooze"
#define RESPONE_KEY_SNOOZE_REPEAT @"snooze_repeat"
#define RESPONE_KEY_DAY @"day"
#define RESPONE_KEY_REPEATHOUR @"repeat_hour"
#define RESPONE_KEY_REPEATTIMES @"repeat_times"
#define RESPONE_KEY_VIBNUMBER @"vib_number"
#define RESPONE_KEY_VIBREPEAT @"vib_repeat"
#define RESPONE_KEY_YEAR @"year"
#define RESPONE_KEY_MONTH @"month"
#define RESPONE_KEY_REPEATSCEDUAL @"repeat_schedule"
#define RESPONE_KEY_STARTHOUR @"starthour"
#define RESPONE_KEY_STARTMINUTE @"startminute"
#define RESPONE_KEY_ENDHOUR @"endhour"
#define RESPONE_KEY_ENDMINUTE @"endminute"
#define RESPONE_KEY_MACID @"mac_id"
#define RESPONE_KEY_ALARMID @"alarm_id"
#define RESPONE_KEY_VID @"vid"
#define RESPONE_KEY_UNIT @"unit"
#define RESPONE_KEY_SOSNUMBER @"sosnumber"
#define RESPONE_KEY_AUTHFLAG @"auth_flag"
#define RESPONE_KEY_BINDNAME @"bind_username"
#define RESPONE_KEY_SYNCKEY @"sync_key"
#define RESPONE_KEY_DATALIST @"datalist"
#define RESPONE_KEY_TIMESTAMP @"timestamp"



#define ALARM_TYPE_TIMER 1
#define ALARM_TYPE_MEDICINE 2
#define ALARM_TYPE_DRINK 3
#define ALARM_TYPE_FIT 4
#define ALARM_TYPE_LONGSIT 5

#define ALARM_ENABLE 1
#define ALARM_DISABLE 0

#define ALARM_REPEAT_SCHEDULE_NO_REPEAT 0
#define ALARM_REPEAT_SCHEDULE_DAILY 1
#define ALARM_REPEAT_SCHEDULE_WEEKLY 2
#define ALARM_REPEAT_SCHEDULE_MONTHLY 3

#define ALARM_HYDRATION_REPEAT_TIMES_MIN 				0
#define ALARM_HYDRATION_REPEAT_TIMES_MAX 				6
#define ALARM_HYDRATION_REPEAT_IN_MINUTES_MAX 			240
#define ALARM_HYDRATION_REPEAT_IN_MINUTES_MIN 			1
#define ALARM_HYDRATION_DEFAULT_REPEAT_HOUR 			30
#define ALARM_HYDRATION_DEFAULT_REPEAT_TIMES 			8

//#ifdef CUSTOM_FITRIST
//#if CUSTOM_CZJK_COMMON
#define ALARM_MAX_COUNT_TIMER 4
//#else
//#define ALARM_MAX_COUNT_TIMER 4
//#endif

#define USER_SOURCE_ORIGIN @"origin"
#define USER_SOURCE_FACEBOOK @"facebook"

#define AUTO_CONNECT_RSSI -65


#define BONGINFO_KEY_FIRMWARE @"FW"
#define BONGINFO_KEY_HARDWARE @"HW"
#define BONGINFO_KEY_BLEADDR @"BA"
#define BONGINFO_KEY_BLENAME @"BN"
#define BONGINFO_KEY_CHIPADDR @"CA"
#define BONGINFO_KEY_PROJECTCODE @"PJC"
#define BONGINFO_KEY_PRODUCTCODE @"PDC"
#define BONGINFO_KEY_VERSIONCODE @"VSC"
#define BONGINFO_KEY_LASTSYNCTIME1 @"LT1"
#define BONGINFO_KEY_LASTSYNCTIME @"LT"
#define BONGINFO_KEY_BATTERYLEVEL @"BL"
#define BONGINFO_KEY_AUTHEXPIRE @"AE"
#define BONGINFO_KEY_NAME @"NM"
#define BONGINFO_KEY_UUID @"UUID"
#define BONGINFO_KEY_SUBGEARTYPE @"ST"
#define BONGINFO_KEY_SLEEP1_ENABLE @"SF1E"
#define BONGINFO_KEY_SLEEP1_START_H @"SF1STH"
#define BONGINFO_KEY_SLEEP1_START_M @"SF1STM"
#define BONGINFO_KEY_SLEEP1_END_H @"SF1EDH"
#define BONGINFO_KEY_SLEEP1_END_M @"SF1EDM"
#define BONGINFO_KEY_SLEEP2_ENABLE @"SF2E"
#define BONGINFO_KEY_SLEEP2_START_H @"SF2STH"
#define BONGINFO_KEY_SLEEP2_START_M @"SF2STM"
#define BONGINFO_KEY_SLEEP2_END_H @"SF2EDH"
#define BONGINFO_KEY_SLEEP2_END_M @"SF2EDM"
#define BONGINFO_KEY_SLEEP3_ENABLE @"SF3E"
#define BONGINFO_KEY_SLEEP3_START_H @"SF3STH"
#define BONGINFO_KEY_SLEEP3_START_M @"SF3STM"
#define BONGINFO_KEY_SLEEP3_END_H @"SF3EDH"
#define BONGINFO_KEY_SLEEP3_END_M @"SF3EDM"
#define BONGINFO_KEY_LASTCANCELUPDATE_DATE @"UPDATECANCELDATE"
#define BONGINFO_KEY_LASTCHECKOTA_DATE @"CHKUPDATE"
#define BONGINFO_KEY_UPDATEINFO @"UPIF"
//#define BONGINFO_KEY_UPDATEFILEURL @"UPFURL"
#define BONGINFO_KEY_UPDATEVERSIONCODE @"UPVERC"
#define BONGINFO_KEY_UPDATEFILEMD5 @"UPMD5"
#define BONGINFO_KEY_UPDATEFILEURL @"UPFILEURL"

#define BONGINFO_KEY_SLEEPSTARTTIME @"SLEEPSTART"
#define BONGINFO_KEY_SLEEPENDTIME @"SLEEPEND"
#define BONGINFO_KEY_LAST4NAME @"LSTNAME"

#define BONGINFO_KEY_DISTURB_STARTTIME @"DISTURB_STARTTIME"
#define BONGINFO_KEY_DISTURB_ENDTIME @"DISTURB_ENDTIME"
#define BONGINFO_KEY_AUTOHEART @"AUTOH"
#define BONGINFO_KEY_AUTOTEMP @"AUTOT"
#define BONGINFO_KEY_LASTSENSORDATATIME @"LASTSENSORTIME"


#define DEF_ENABLE @"1"
#define DEF_DISABLE @"0"

#define ACTIVITY_TYPE_SWIM 0x80
#define ACTIVITY_TYPE_STAIR 0x40
#define ACTIVITY_TYPE_BYCICLE 0x20
#define ACTIVITY_TYPE_NORMAL 0x10
#define ACTIVITY_TYPE_RUNNING 0x08
#define ACTIVITY_TYPE_ROPE 0x04
#define ACTIVITY_TYPE_JACK 0x02
#define ACTIVITY_TYPE_SITUP 0x01

#define SENSOR_HEARTRATE 0x80
#define SENSOR_TEMPERATURE 0x10
#define SENSOR_BLOODPRESS 0x40
#define SENSOR_SPO 0x20

#define SENSOR_TYPE_SERVER_HEARTRATE 1
#define SENSOR_TYPE_SERVER_TEMPERATURE 14
#define SENSOR_TYPE_SERVER_BLOODPRESS 4


#define SPORT_TYPE_WALK 0                  //走路
#define SPORT_TYPE_ROPE 1                  //跳绳
#define SPORT_TYPE_JACK 2                  //开合跳
#define SPORT_TYPE_SITUP 3                 //仰卧起坐
#define SPORT_TYPE_TREADMILL 4             //跑步机
#define SPORT_TYPE_SWIM 5                  //游泳
#define SPORT_TYPE_RUNNING 6               //手机跑步
#define SPORT_TYPE_BICYCLE 7               //骑车
#define SPORT_TYPE_BONG_RUNNING 8          //手环跑步
#define SPORT_TYPE_BONG_SWIM 9             //手环游泳
#define SPORT_TYPE_BAND_BICYCLE 1024
#define SPORT_TYPE_BAND_SWIM 1025
#define SPORT_TYPE_GPS_CLIMB 2002

#define HEIGHT_MIN_MATRIX 50
#define HEIGHT_MAX_MATRIX 250
#define WEIGHT_MIN_MATRIX 20
#define WEIGHT_MAX_MATRIX 227
#define STRIDE_MIN_MATRIX 30
#define STRIDE_MAX_MATRIX 213

#define HEIGHT_FEET_MIN_US 1
#define HEIGHT_FEET_MAX_US 8
#define HEIGHT_INCH_MIN_US 0
#define HEIGHT_INCH_MAX_US 11
#define HEIGHT_INCH1_MIN_US 8
#define HEIGHT_INCH1_MAX_US 11


#define STRIDE_FEET_MIN_US 1
#define STRIDE_FEET_MAX_US 7
#define STRIDE_INCH_MIN_US 0
#define STRIDE_INCH_MAX_US 11

#define WEIGHT_MIN_US 45
#define WEIGHT_MAX_US 501

#define START_RUN_ACCURACY 25
#define GPS_ACCURACY_VALID 0
#define GPS_ACCURACY_STRONG 25
#define GPS_ACCURACY_WEAK 50
#define GPS_ACCURACY_UNTRUST 100

#define PROJECTCODE_SXR @"SXR"
#define PROJECTCODE_WDB @"WDB_"

#define PRODUCTCODE_W4S @"W4S_"



#define ANCS_SUPPORT_VERSIONCODE 60

#define FIRMWARE_FILE_DIR @"fwupdate"
#define FIRMWARE_FILE_NAME @"newfirmware.hex"

#define FIRMINFO_DICT_UPDATEINFO @"updateInfo"
#define FIRMINFO_DICT_FWDESC @"fwDescription"
#define FIRMINFO_DICT_FWNAME @"fwName"
#define FIRMINFO_DICT_FORCEUPDATE @"forceUpdate"
#define FIRMINFO_DICT_AUTOUPDATE @"autoUpdate"
#define FIRMINFO_DICT_FWURL @"fwUrl"
#define FIRMINFO_DICT_VERSIONCODE @"versionCode"
#define FIRMINFO_DICT_VERSIONNAME @"versionName"
#define FIRMINFO_DICT_UPDATETIPS @"updateTips"
#define FIRMINFO_DICT_MD5 @"md5"


#define CMD_ServiceID @"fff0"
#define default_Resp_CharID @"FFF1"
#define default_Write_Code_CharID @"FFF2"
#define Write_Code_Resquest_Characteristic_UUID_default @"FFF2"
#define Write_Code_Resquest_Characteristic_Value 0xfc12cc0000
#define End_Write_Code_Resquest_Characteristic_Value @"FC23CC"
#define Resp_Indication_Characteristic_UUID_default @"FFF1"
#define Resp_Indication_Characteristic_Value @"ACEDAC"
#define End_Resp_Indication_Characteristic_Byte0 @"AC"
#define End_Resp_Indication_Characteristic_Byte2 @"AC"
#define Write_Code_Resquest_Characteristic_Byte0 @"FA"
#define Resp_Indication_Characteristic_Byte0 @"AA"
#define Fixed_Tag @"484541445F454E44"
#define OTA_Service @"feba"


#define OTA_DEFAULT_UPDATECODESERVICE @"FFF0"
#define OTA_DEFAULT_RSPINDICATIONCHARACTERISTIC @"FFF1"
#define OTA_DEFAULT_WRITECODEREQUESTCHARACTERISTIC @"FFF2"
#define OTA_DEFAULT_OTASERVER @"FEBA"
#define OTA_DEFAULT_OTACMDSERVICE @"FA11"
#define OTA_DEFAULT_OTADATASERVICE @"FA10"


//状态
#define STATE_CONNECT_LOST 0
#define STATE_CONNECT_INIT 1
#define STATE_CONNECT_IDLE 2
#define STATE_SYNC_HISTORY_DATA 3
#define STATE_OTA 4
#define STATE_SINGLE_CMD 5

//子状态
#define SUB_STATE_IDLE 0
#define SUB_STATE_WAIT_FA_RSP 1
#define SUB_STATE_WAIT_FB_RSP 2
#define SUB_STATE_WAIT_READTIME_RSP 3
#define SUB_STATE_WAIT_SETTIME_RSP 4
#define SUB_STATE_WAIT_C6_RSP 5
#define SUB_STATE_WAIT_C4_RSP 6
#define SUB_STATE_WAIT_PERSONINFO_RSP 7
#define SUB_STATE_WAIT_SETSLEEP_RSP 8
#define SUB_STATE_WAIT_SETPARAM_RSP 9
#define SUB_STATE_WAIT_CLEAR_RSP 10
#define SUB_STATE_WAIT_F1_RSP 11
#define SUB_STATE_WAIT_WEATHER_RSP 12
#define SUB_STATE_WAIT_ANTILOST_RSP 13
#define SUB_STATE_WAIT_RESET_RSP 14
#define SUB_STATE_WAIT_MONITOR_RSP 15
#define SUB_STATE_WAIT_SETSCREEN_RSP 16
#define SUB_STATE_WAIT_ALARM_RSP 17
#define SUB_STATE_WAIT_SPORTDATA_RSP 18
#define SUB_STATE_WAIT_ANCSPAIR_RSP 19
#define SUB_STATE_WAIT_SENSOR_CHANGE_RSP 20
#define SUB_STATE_WAIT_NODIC_INTO_OTA_RSP 21
#define SUB_STATE_WAIT_SETSYDRATION_RSP 22
#define SUB_STATE_WAIT_A2_RSP 23
#define SUB_STATE_WAIT_LONGSIT 24
#define SUB_STATE_WAIT_NOTIFICATION 25
#define SUB_STATE_WAIT_ALARM_NAME 26
#define SUB_STATE_WAIT_SENSORDATA_RSP 27



//命令
#define CMD_GETMAC @"getmac"
#define CMD_GETFW @"getfw"
#define CMD_C4 @"c4"
#define CMD_A2 @"A2"
#define CMD_C6 @"c6"
#define CMD_CLEAR @"clear"
#define CMD_RESET @"Reset"
#define CMD_READTIME @"readtime"
#define CMD_SETTIME @"settime"
#define CMD_ANTILOST @"antilost"
#define CMD_WEATHER @"weather"
#define CMD_SETPERSON @"person"
#define CMD_SETHYDRATION @"hydration"
#define CMD_SETSLEEP @"sleep"
#define CMD_SETPARAM @"setparam"
#define CMD_ADV_MONITOR @"adv_monitor"
#define CMD_SETSCREEN @"screen"
#define CMD_SENDALARM @"alarm"
#define CMD_SPORTDATA @"sportdata"
#define CMD_PAIR @"pair"
#define CMD_SENSOR_CHANGE @"sensor"
#define CMD_NORDIC_INTO_OTA @"nodicota"
#define CMD_LONGSIT @"longsit"
#define CMD_NOTIFICATION @"notification"
#define CMD_ALARM_NAME @"set_alarm_name"
#define CMD_SENSORDATA @"getSensorData"



#define SEDENTARY_MIN_SNOOZE 5

//#ifdef CUSTOM_CZJK_COMMON
#define DEFAULT_CMD_TIMEOUT 10
//#else
//#define DEFAULT_CMD_TIMEOUT 30
//#endif

#define SENSOR_REPORT_INFO_KEY_TYPE @"sensor_type"
#define SENSOR_REPORT_INFO_KEY_VALUE @"sensor_value"
#define SENSOR_REPORT_INFO_KEY_VALUE2 @"sensor_value2"

#define SENSOR_REPORT_ONOFF @"sensor_onoff"

#define BAND_SUBTYPE_BASE @"Base"
#define BAND_SUBTYPE_PRIME @"Prime"
#define BAND_SUBTYPE_NONE @"none"

#define SYNCKEY_PREFIX @"SYNCKEY"

#define SYNCKEY_MEMBERINFO @"SYNCKEY1"
#define SYNCKEY_FITNESS @"SYNCKEY100"
#define SYNCKEY_BODYFUNCTION @"SYNCKEY101"
#define SYNCKEY_SLEEP @"SYNCKEY102"
#define SYNCKEY_RUNRECORD @"SYNCKEY107"
#define SYNCKEY_RUNHISTORY @"SYNCKEY108"


#define DATATYPE_FITNESS @"fitness"
#define DATATYPE_SLEEP @"sleep"
#define DATATYPE_RUNRECORD @"runrecord"
#define DATATYPE_RUNHISTORY @"runhistory"
#define DATATYPE_BODYFUNCTION @"bodyfunction"

#define TASKTYPE_DOWNLOAD @"downloaddata"
#define TASKTYPE_WRITEDB @"writedb"
#define TASKTYPE_UPLOAD @"uploaddata"

#define TASKSTATE_FINISH 0
#define TASKSTATE_PROCEEDING 1
#define TASKSTATE_WAITING 2

#define DOWNLOADTASKARRAY_PREFIX @"DOWNLOADTASKBYSYNCKEY"
#define DOWNLOADTASKARRAY_STARTKEY @"startkey"
#define DOWNLOADTASKARRAY_CURRENTKEY @"currentkey"
#define DOWNLOADTASKARRAY_TARGETKEY @"targetkey"

#define MAX_TASK_NUMBER 1

#define SERVER_STEP_MODE_SLEEP 12
#define SERVER_STEP_MODE_STEP 0
#define SERVER_STEP_MODE_RUN 1
#define SERVER_TYPE_ROPE 13
#define SERVER_TYPE_JACK 14
#define SERVER_TYPE_SITUP 15

#define SERVER_TYPE_TREADMILL 18
#define SERVER_TYPE_BAND_BIKE 1024
#define SERVER_TYPE_BAND_SWIM 1025
#define SERVER_TYPE_GPS_RUN 2000
#define SERVER_TYPE_GPS_BIKE 2001
#define SERVER_TYPE_GPS_CLIMB 2002

#define CONTROL_DEVICE_OPTCODE_NONE 0
#define CONTROL_DEVICE_OPTCODE_CLOSE 1
#define CONTROL_DEVICE_OPTCODE_REBOOT 2
#define CONTROL_DEVICE_OPTCODE_RESET 3


#define USERMANUAL_URL @"http://download.keeprapid.com:8181/docs/himove_usermanual/%@%@"

//////////for healthkit/////////////
#define notify_key_syncdata_to_healthkit_ok @"synchealthkitok"
#define notify_key_syncdata_to_healthkit @"synchealthkit"



#endif
