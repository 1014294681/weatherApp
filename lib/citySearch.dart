import 'package:flutter/material.dart';
import 'package:flutter_qweather/flutter_qweather.dart';
import 'package:flutter_qweather/models/geo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CitySearch extends StatefulWidget {
  const CitySearch({Key? key}) : super(key: key);

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  final FocusNode _focusNode = FocusNode();
  List<GeoPoiLocation> locationList = [];
  late String adm1;
  late String adm2;
  late String name;
  late String id;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 982),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () {
                hideKeyboard(context);
              },
              child: Container(
                //color: Colors.lightBlueAccent,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x9B91EAFF), Colors.blueGrey])),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20.h,bottom: 0.h,left: 0.w,right: 0.w),
                      height: 100.h,
                      child: SafeArea(
                          child: TextField(
                        //controller: _controller,
                        style: TextStyle(
                            color: Colors.blueGrey.shade700, fontSize: 25.sp),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding:
                                  EdgeInsets.only(top: 5.h, bottom: 5.h,left: 0.w,right: 0.w),
                              child: const Image(
                                  fit: BoxFit.contain,
                                  image: AssetImage("asset/images/search.png"),
                                  alignment: Alignment.center),
                            ),
                            fillColor: Colors.white70,
                            filled: true,
                            border: const OutlineInputBorder(),
                            labelText: "请输入",
                            labelStyle: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontSize: 20.sp)),
                        onChanged: (v) async {
                          GeoPoiLocationResp? locationResp =
                              await FlutterQweather.instance
                                  .geoCityLookup(v, number: 20, range: "cn");
                          locationList = locationResp!.locations;
                          for (var element in locationList) {
                            if (element.adm2 == element.name) {
                              element.adm2 = "";
                            }
                          }
                          setState(() {});
                        },
                      )),
                    ),
                    Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: const Radius.circular(3),
                          thickness: 6.h,

                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: locationList.length,
                            itemBuilder: (context, index) => _buildItem(
                                locationList[index].adm1,
                                locationList[index].adm2,
                                locationList[index].name,
                                locationList[index].id),
                      ),
                    ))
                  ],
                ),
              ),
            ));
      },
    );
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Widget _buildItem(String adm1, String adm2, String name, String id) {
    return GestureDetector(
      onTap: () {
        Map<String, String> map = {"name": name, "id": id};
        Navigator.pop(context, map);
      },
      child: Card(
          color: Colors.white70,
          elevation: 20.0,
          margin: EdgeInsets.only(top: 20.h,bottom: 0.h, left: 30.w, right: 30.w),
          child: Container(
            alignment: Alignment.center,
            height: 50.h,
            child: Text(
              "$adm1 $adm2 $name",
              style:
                  TextStyle(color: Colors.blueGrey.shade700, fontSize: 20.sp),
            ),
          )),
    );
  }
}
