import 'package:flutter/material.dart';
import 'package:flutter_qweather/flutter_qweather.dart';
import 'package:flutter_qweather/models/geo.dart';

class CitySearch extends StatefulWidget {
  const CitySearch({Key? key}) : super(key: key);

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  final FocusNode _focusNode = FocusNode();
  late ScrollController _controller;
  List<GeoPoiLocation> locationList = [];
  late String adm1;
  late String adm2;
  late String name;
  late String id;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.lightBlueAccent,
        child: Flex(
          direction: Axis.vertical,
          children: [
            SafeArea(
                child: TextField(
                  //controller: _controller,
                  style: const TextStyle(color: Colors.white,fontSize: 16),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "请输入",
                    labelStyle: TextStyle(color: Colors.white,fontSize: 16)
                  ),
                  onChanged: (v) async {
                    GeoPoiLocationResp? locationResp = await FlutterQweather.instance
                        .geoCityLookup(v, number: 20, range: "cn");
                    locationList = locationResp!.locations;
                    for (var element in locationList) {
                      if(element.adm2==element.name){
                        element.adm2="";
                      }
                    }
                    setState(() {});
                  },
                )
            ),
            SizedBox(
              height: 600,
              child: ListView.builder(
                controller: _controller,
                shrinkWrap: true,
                itemCount: locationList.length,
                itemBuilder: (context, index) =>
                    _buildItem(locationList[index].adm1, locationList[index].adm2,
                        locationList[index].name, locationList[index].id),),
            )
          ],
        ),
    ),);
  }

  Widget _buildItem(String adm1, String adm2, String name, String id){
    return GestureDetector(
      onTap: (){
        Map<String,String> map={
          "name":name,
          "id":id
        };
        Navigator.pop(context,map);
      },
      child: Container(
        width: 100,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          "$adm1 $adm2 $name",
          style: const TextStyle(color: Colors.white,fontSize: 20),
        ),
      ),
    );

  }


}