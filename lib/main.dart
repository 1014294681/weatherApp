import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_qweather/constants.dart';
import 'package:flutter_qweather/flutter_qweather.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'citySearch.dart';

///程序入口
void main() {
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411,982),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyHomePage(
            title: 'weather',
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WeatherNowResp? _weatherNowResp;
  late WeatherDailyResp _weatherDailyResp;
  WeatherHourlyResp? _hourlyResp;
  StreamSubscription<Map<String, Object>>? _locationListener;
  PermissionStatus? status;
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();

  TextStyle textStyle16 = TextStyle(
      color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500,fontFamily: "Noto_Sans_SC");
  TextStyle textStyle20 = TextStyle(
      color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w500,fontFamily: "Noto_Sans_SC");
  TextStyle textStyle60 = TextStyle(
      color: Colors.white, fontSize: 60.sp, fontWeight: FontWeight.bold,fontFamily: "Noto_Sans_SC");

  //实时定位名称
  late String currentLocation = "香洲区";

  //实时气温
  late String currentTemperature = "31°";

  //实时天气
  late Image currentWeatherIcon = Image(
      image: const AssetImage('asset/images/sunny.png'),
      height: 32.w,
      width: 32.w,
      color: Colors.white);

  //今日天气概况
  late String todayWeather = "多云 31°/26°C";

  //六日天气预报列表
  late List<Map<String, Object>> mapList = [];

  //六日天气预报映射
  late Map<String, Object> weatherMap1 = {};
  late Map<String, Object> weatherMap2 = {};
  late Map<String, Object> weatherMap3 = {};
  late Map<String, Object> weatherMap4 = {};
  late Map<String, Object> weatherMap5 = {};
  late Map<String, Object> weatherMap6 = {};
  //今日风向
  late String windDirection = "西北风";

  //今日风力等级
  late String windScale = "3级";

  //今日相对湿度
  late String relativeHumidity = "50%";

  //今日紫外线强度等级
  late String ultravioletIntensity = "3级";

  //今日体感温度
  late String apparentTemperature = "33度";

  //今日降水量
  late String precipitation = "30mm";

  //今日能见度
  late String visibility = "10公里";

  //今日生活指数
  late String livingIndex = "生活指数";


  @override
  void initState() {
    super.initState();
    initQweather();
    //初始化map
    weatherMap1 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    weatherMap2 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    weatherMap3 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    weatherMap4 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    weatherMap5 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    weatherMap6 = {
      "count": 0,
      "date": "7/5",
      "weekday": "今天",
      "imageDay": "asset/images/rainy.png",
      "maxTemp": "31°",
      "minTemp": "26°",
      "imageNight": "asset/images/rainy.png"
    };
    mapList.add(weatherMap1);
    mapList.add(weatherMap2);
    mapList.add(weatherMap3);
    mapList.add(weatherMap4);
    mapList.add(weatherMap5);
    mapList.add(weatherMap6);
    for (int i = 0; i <= 5; i++) {
      mapList[i]["count"] = i;
    }

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用， 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// [hasContains] 隐私声明中是否包含高德隐私政策说明
    ///
    /// [hasShow] 隐私权政策是否弹窗展示告知用户
    AMapFlutterLocation.updatePrivacyShow(true, true);

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作
    ///
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    ///
    /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    ///
    /// [hasAgree] 隐私权政策是否已经取得用户同意
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 动态申请定位权限
    _requestPermission();

    ///设置Android和iOS的apiKey<br>
    ///key的申请请参考高德开放平台官网说明<br>
    ///Android: https://lbs.amap.com/api/android-location-sdk/guide/create-project/get-key
    ///iOS: https://lbs.amap.com/api/ios-location-sdk/guide/create-project/get-key
    AMapFlutterLocation.setApiKey(
        '73f2e5ebf14a155ffbb15eed52f3ead8', '73f2e5ebf14a155ffbb15eed52f3ead8');

    ///注册定位结果监听
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      setState(() {
        if (result.isNotEmpty) {
          ///获取定位城市名称
          if (result["district"]!="") {
            currentLocation = result.putIfAbsent("district", () => -1).toString();
          } else {
            currentLocation = result.putIfAbsent("city", () => "-1").toString();
          }
          ///-------------更新天气信息并重新构造页面----------------
          ///和风天气api只能接受小数点后两位精度的经纬度定位，需要进行处理
          updateWeather(
              "${(result.putIfAbsent("longitude", () => "-1") as double).toStringAsFixed(2)},${(result.putIfAbsent("latitude", () => "") as double).toStringAsFixed(2)}");
          _stopLocation();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener?.cancel();
    }

    ///销毁定位
    _locationPlugin.destroy();
  }

  ///设置定位参数
  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = false;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Hight_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  /// 动态申请定位权限
  Future<bool> _requestPermission() async {
    status = await Permission.location.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (kDebugMode) {
        print('status=$status');
      }
      if (status == PermissionStatus.granted) {
        _startLocation();
        return true;
      } else {
        ///默认不给定位权限就更新北京市的天气信息
        updateWeather("101010100");
        currentLocation="北京市";
        return false;
      }
    }
  }


  ///开始定位
  void _startLocation() {
    ///开始定位之前设置定位参数
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  ///停止定位
  void _stopLocation() {
    _locationPlugin.stopLocation();
  }



  // 初始化 Qweather
  Future<void> initQweather() async {
    QweatherConfig config = QweatherConfig(
        publicIdForAndroid: 'HE2208051101011006',
        keyForAndroid: 'cddad923ec4d48289b7213d573c9c4be',
        publicIdForIos: 'HE2208051101011006',
        keyForIos: 'cddad923ec4d48289b7213d573c9c4be',
        biz: false,
        debug: true);
    await FlutterQweather.instance.init(config);
  }

  //根据定位更新天气信息
  Future<void> updateWeather(String location) async {
    _weatherNowResp = await FlutterQweather.instance.getWeatherNow(location);
    _weatherDailyResp = (await FlutterQweather.instance
        .getWeatherDaily(location, WeatherDailyForecast.WeatherForecast7Day))!;
    _hourlyResp = await FlutterQweather.instance.getWeatherHourly(
        location, WeatherHourlyForecast.WeatherForecast24Hour);
    //_dailyIndicesResp=await FlutterQweather.instance.getIndices3Day(location);
    setState(() {
      //当前天气
      if (_weatherNowResp!.now.text.contains("晴")) {
        currentWeatherIcon = Image(
            image: const AssetImage('asset/images/sunny.png'),
            height: 32.w,
            width: 32.w,
            color: Colors.white);
      }
      if (_weatherNowResp!.now.text.contains("雨")) {
        currentWeatherIcon = Image(
            image: const AssetImage('asset/images/rainy.png'),
            height: 32.w,
            width: 32.w,
            color: Colors.white);
      }
      if (_weatherNowResp!.now.text.contains("云")) {
        currentWeatherIcon = Image(
            image: const AssetImage('asset/images/cloudy.png'),
            height: 32.w,
            width: 32.w,
            color: Colors.white);
      }
      currentTemperature = "${_weatherNowResp!.now.temp}°";
      todayWeather =
          "${_weatherDailyResp.daily[0].textDay} ${_weatherDailyResp.daily[0].tempMax}°/${_weatherDailyResp.daily[0].tempMin}°C";
      //六日天气预报
      List<WeatherDaily> list = _weatherDailyResp.daily;
      int i = 0;
      for (var element in mapList) {
        element["date"] = dateFormat(list[i].fxDate);
        element["weekday"] =
            DateFormat('EE', "zh_CN").format(DateTime.parse(list[i].fxDate));
        if (list[i].textDay.contains("晴")) {
          element["imageDay"] = "asset/images/sunny.png";
        }
        if (list[i].textDay.contains("雨")) {
          element["imageDay"] = "asset/images/rainy.png";
        }
        if (list[i].textDay.contains("云")) {
          element["imageDay"] = "asset/images/cloudy.png";
        }
        if (list[i].textNight.contains("晴")) {
          element["imageNight"] = "asset/images/sunny.png";
        }
        if (list[i].textNight.contains("雨")) {
          element["imageNight"] = "asset/images/rainy.png";
        }
        if (list[i].textNight.contains("云")) {
          element["imageNight"] = "asset/images/cloudy.png";
        }
        element["maxTemp"] = list[i].tempMax;
        element["minTemp"] = list[i].tempMin;
        i++;
      }
      ultravioletIntensity = list[0].uvIndex;
      switch (list[0].uvIndex) {
        case "0":
        case "1":
        case "2":
          ultravioletIntensity = "很弱";
          break;
        case "3":
        case "4":
          ultravioletIntensity = "弱";
          break;
        case "5":
        case "6":
          ultravioletIntensity = "中等";
          break;
        case "7":
        case "8":
        case "9":
          ultravioletIntensity = "强";
          break;
        default:
          ultravioletIntensity = "很强";
          break;
      }
      apparentTemperature = "${_weatherNowResp!.now.feelsLike}°";
      precipitation = "${_weatherNowResp!.now.precip}mm";
      visibility = "${_weatherNowResp!.now.vis}km";
      windScale = "${_weatherNowResp!.now.windScale}级";
      windDirection = _hourlyResp!.hourly[0].windDir;
      relativeHumidity = "${_hourlyResp?.hourly[0].humidity}%";

      //livingIndex=_dailyIndicesResp!.dailyList[0].text;
    });
    mapList[0]["weekday"] = "今天";
  }
  ///将获取到的日期格式化
  String dateFormat(String date) {
    date = "${date.substring(5, 7)}/${date.substring(8, 10)}";
    return date;
  }


  @override
  Widget build(BuildContext context) {
    return AppRetainWidget(child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              color: Colors.lightBlueAccent,
            ),
            SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 26, right: 15).r,
                            child: Image(
                                image: const AssetImage("asset/images/location.png"),
                                height: 32.w,
                                width: 32.w),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 0).r,
                              width: 100.w,
                              height: 30.h,
                              child: Text(currentLocation, style: textStyle20)),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 0).r,
                            child: IconButton(
                              onPressed: () async {
                                Map<String, String> result = {};

                                ///-----------------城市搜索按钮-------------------------
                                result = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                    builder: (context) => const CitySearch()))
                                    .then((result) => result);
                                currentLocation =
                                    result.putIfAbsent("name", () => "false");
                                updateWeather(
                                    result.putIfAbsent("id", () => "false"));
                                setState(() {});
                              },
                              icon: Image(
                                  image: const AssetImage("asset/images/exchange.png"),
                                  height: 32.w,
                                  width: 32.w),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 26, top: 20).r,
                              child: Text(currentTemperature, style: textStyle60)),
                          Padding(
                              padding: const EdgeInsets.only(left: 0, top: 40).r,
                              child: currentWeatherIcon)
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 26, top: 0).r,
                              child: Text(todayWeather, style: textStyle16)),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 26, top: 50, right: 18, bottom: 20).r,
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 0, bottom: 0, right: 12).r,
                                  child: Text(
                                      mapList[0]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 15, left: 0, top: 5, ).r,
                                  child: Text(
                                      mapList[0]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15, top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[0]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 16, top: 5, bottom: 40).r,
                                  child: Text(
                                      mapList[0]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 16, top: 5).r,
                                  child: Text(
                                      mapList[0]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15, top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[0]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),

                            //------------分割线--------------
                            SizedBox(
                              width: 1.w,
                              height: 200.h,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),

                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0).r,
                                  child: Text(
                                      mapList[1]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 15, left: 15, top: 5).r,
                                  child: Text(
                                      mapList[1]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[1]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 40, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[1]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[1]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[1]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),

                            //------------分割线--------------
                            SizedBox(
                              width: 1.w,
                              height: 200.h,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),

                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0).r,
                                  child: Text(
                                      mapList[2]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 15, left: 15, top: 5).r,
                                  child: Text(
                                      mapList[2]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[2]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 40, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[2]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[2]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[2]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),

                            //------------分割线--------------
                            SizedBox(
                              width: 1.w,
                              height: 200.h,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),

                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0).r,
                                  child: Text(
                                      mapList[3]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 15, left: 15, top: 5).r,
                                  child: Text(
                                      mapList[3]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[3]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 40, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[3]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[3]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[3]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),

                            //------------分割线--------------
                            SizedBox(
                              width: 1.w,
                              height: 200.h,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),

                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0).r,
                                  child: Text(
                                      mapList[4]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 15, left: 15, top: 5).r,
                                  child: Text(
                                      mapList[4]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[4]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 40, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[4]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[4]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[4]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),

                            //------------分割线--------------
                            SizedBox(
                              width: 1.w,
                              height: 200.r,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 0).r,
                                  child: Text(
                                      mapList[5]
                                          .putIfAbsent("date", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 10, left: 15, top: 5).r,
                                  child: Text(
                                      mapList[5]
                                          .putIfAbsent("weekday", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[5]
                                        .putIfAbsent("imageDay", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, bottom: 40, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[5]
                                          .putIfAbsent("maxTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5, left: 4, right: 4).r,
                                  child: Text(
                                      mapList[5]
                                          .putIfAbsent("minTemp", () => "-1")
                                          .toString(),
                                      style: textStyle16),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5).r,
                                  child: Image(
                                    image: AssetImage(mapList[5]
                                        .putIfAbsent("imageNight", () => "-1")
                                        .toString()),
                                    height: 32.w,
                                    width: 32.w,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, left: 30).r,
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      right: 5, top: 5).r,
                                  child: Image(
                                    image: const AssetImage("asset/images/wind.png"),
                                    width: 32.w,
                                    height: 32.w,
                                  ),
                                ),
                                Container(
                                    margin:
                                    const EdgeInsets.only(top: 30, right: 5).r,
                                    child: Image(
                                      image: const AssetImage("asset/images/kongqishidu.png"),
                                      width: 32.w,
                                      height: 32.w,
                                    )),
                                Container(
                                    margin:
                                    const EdgeInsets.only(top: 30, right: 5).r,
                                    child: Image(
                                      image: const AssetImage("asset/images/sun.png"),
                                      width: 32.w,
                                      height: 32.w,
                                    )),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text(windDirection, style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20).r,
                                  child: Text(windScale, style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text("相对湿度", style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 25).r,
                                  child: Text(relativeHumidity, style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text("紫外线强度等级", style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text(ultravioletIntensity,
                                      style: textStyle16),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, bottom: 0, top: 5, left: 50).r,
                                    child: Image(
                                      image: const AssetImage("asset/images/tiwenji.png"),
                                      width: 32.w,
                                      height: 32.w,
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 30, right: 5, left: 50).r,
                                    child: Image(
                                      image: const AssetImage("asset/images/jiduanjiangyu.png"),
                                      width: 32.w,
                                      height: 32.w,
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 30, right: 5, left: 50).r,
                                    child: Image(
                                      image: const AssetImage("asset/images/daolu-mian.png"),
                                      width: 32.w,
                                      height: 32.w,
                                    )),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text("体感温度", style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20).r,
                                  child:
                                  Text(apparentTemperature, style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text("降水量", style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 25).r,
                                  child: Text(precipitation, style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text("可见度", style: textStyle16),
                                ),
                                Container(
                                  margin: const EdgeInsets.only().r,
                                  child: Text(visibility, style: textStyle16),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 360,
                        alignment: Alignment.bottomLeft,
                        margin: const EdgeInsets.only(top: 30, left: 30).r,
                        child: Text(livingIndex,
                            style: textStyle16,
                            softWrap: true,
                            textAlign: TextAlign.left),
                      )
                    ]))
          ],
        )));
  }
}

///让应用可以保持后台
class AppRetainWidget extends StatelessWidget {
  const AppRetainWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  final _channel = const MethodChannel('life.qdu/app_retain');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return true;
          } else {
            _channel.invokeMethod('sendToBackground');
            return false;
          }
        } else {
          return true;
        }
      },
      child: child,
    );
  }
}
