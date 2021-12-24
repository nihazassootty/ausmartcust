// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ausmart/Commons/AppConstants.dart';
import 'package:ausmart/Commons/ColorConstants.dart';
import 'package:ausmart/Commons/SnackBar.dart';
import 'package:ausmart/Commons/TextStyles.dart';
import 'package:ausmart/Commons/zerostate.dart';
import 'package:ausmart/Components/ActiveMessageCard.dart';
import 'package:ausmart/Components/BannerCard.dart';
import 'package:ausmart/Components/CartBottomCard.dart';
import 'package:ausmart/Models/StoreModel.dart';
import 'package:ausmart/Providers/GetDataProvider.dart';
import 'package:ausmart/Providers/GroceryProvider.dart';
import 'package:ausmart/Providers/PopularProvider.dart';
import 'package:ausmart/Providers/StoreProvider.dart';
import 'package:ausmart/Screens/App/HomeScreen/BottomNav.dart';
import 'package:ausmart/Screens/App/HomeScreen/CategoryScreen.dart';
import 'package:ausmart/Screens/App/HomeScreen/NearbyScreen.dart';
import 'package:ausmart/Screens/App/HomeScreen/PopularScreen.dart';
import 'package:ausmart/Screens/App/HomeScreen/QuickScreen.dart';
import 'package:ausmart/Screens/App/HomeScreen/RecommendedScreen.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../saved_address.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  ScrollController _scrollController = ScrollController();
  // var getStore;
  // IO.Socket socket;

  Future _check() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return showSnackBar(
          duration: Duration(milliseconds: 10000),
          context: context,
          message: "Please Enable Location Permission");
    }
    if (permission == LocationPermission.denied) {
      LocationPermission newpermission = await Geolocator.requestPermission();
      if (newpermission == LocationPermission.deniedForever ||
          newpermission == LocationPermission.denied) {
        openAppSettings();
        return showSnackBar(
            duration: Duration(milliseconds: 10000),
            context: context,
            message: "Please Enable Location Permission");
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var addresses =
          await Geocoder.google(googleAPI).findAddressesFromCoordinates(
        Coordinates(position.latitude, position.longitude),
      );
      var check = {
        "address": 'Current Location',
        "latitude": position.latitude,
        "longitude": position.longitude,
        "fullAddress": addresses.first.addressLine
      };
      Provider.of<GetDataProvider>(context, listen: false)
          .setCustomerLocation(check);
      Provider.of<StoreProvider>(context, listen: false).fetchStores(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<GroceryProvider>(context, listen: false).fetchGrocery(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<PopularProvider>(context, listen: false).fetchCategory();
    }
    if (permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var addresses = await Geocoder.google(googleAPI)
          .findAddressesFromCoordinates(
              Coordinates(position.latitude, position.longitude));
      var check = {
        "address": 'Current Location',
        "latitude": position.latitude,
        "longitude": position.longitude,
        "fullAddress": addresses.first.addressLine
      };

      Provider.of<GetDataProvider>(context, listen: false)
          .setCustomerLocation(check);
      Provider.of<StoreProvider>(context, listen: false).fetchStores(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<GroceryProvider>(context, listen: false).fetchGrocery(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<PopularProvider>(context, listen: false).fetchCategory();
    }
    if (permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var addresses = await Geocoder.google(googleAPI)
          .findAddressesFromCoordinates(
              Coordinates(position.latitude, position.longitude));
      var check = {
        "address": 'Current Location',
        "latitude": position.latitude,
        "longitude": position.longitude,
        "fullAddress": addresses.first.addressLine
      };

      Provider.of<GetDataProvider>(context, listen: false)
          .setCustomerLocation(check);
      Provider.of<StoreProvider>(context, listen: false).fetchStores(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<GroceryProvider>(context, listen: false).fetchGrocery(
          latitude: position.latitude,
          longitude: position.longitude,
          context: context);
      Provider.of<PopularProvider>(context, listen: false).fetchCategory();
    }
  }

  // void connectSocket(id) {
  //   socket = IO.io(socketUrl, <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoConnect": false,
  //   });
  //   socket.connect();
  //   socket.onConnect(
  //         (data) => socket.emit('join', 'branch_$id'),
  //   );
  //   socket.onConnect(
  //         (data) => print('connected'),
  //   );
  //   socket.on('branch', (data) {
  //     getStore.message(data);
  //     //*MANAGE IN-APP MESSAGE
  //     // if (data["type"] == 'message') _message(data);
  //   });
  //
  // }
  Future _refreshStores() async {
    final customer = Provider.of<GetDataProvider>(context, listen: false);
    Provider.of<StoreProvider>(context, listen: false).fetchStores(
        latitude: customer.latitude,
        longitude: customer.longitude,
        context: context);
    Provider.of<GroceryProvider>(context, listen: false).fetchGrocery(
        latitude: customer.latitude,
        longitude: customer.longitude,
        context: context);
    Provider.of<PopularProvider>(context, listen: false).fetchCategory();
  }

  Future _loadMoreStores() async {
    final customer = Provider.of<GetDataProvider>(context, listen: false);
    final store = Provider.of<StoreProvider>(context, listen: false);
    if (store.isPagination)
      Provider.of<StoreProvider>(context, listen: false).loadMoreStores(
          latitude: customer.latitude, longitude: customer.longitude);
  }

  // getFCM() async {
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     messaging = FirebaseMessaging.instance;
  //     messaging.getToken().then((value) {
  //       Provider.of<GetDataProvider>(context, listen: false).updateFCM(value);
  //     });
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     messaging = FirebaseMessaging.instance;
  //     messaging.getToken().then((value) {
  //       Provider.of<GetDataProvider>(context, listen: false).updateFCM(value);
  //     });
  //   } else {
  //     print('User declined or has not accepted permission');
  //   }
  // }
  @override
  void initState() {
    // getStore = Provider.of<StoreProvider>(context, listen: false);
    // print(getStore.store.branch.id.toString());

    // connectSocket(getStore.store.branch.id);
    final customer = Provider.of<GetDataProvider>(context, listen: false);
    // getFCM();
    if (customer.currentAddress == 'Current Location') _check();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreStores();
      }
    });
    super.initState();
    // initializeFCM();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     print('notification:${message.notification.title}');
    //   }
    // }
    // );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      // appBar: new AppBar(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(32.0),
      //     ),
      //   ),
      //   backgroundColor: kPinkColor,
      //   elevation: 1,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   // leading: Padding(
      //   //   padding: const EdgeInsets.all(8.0),
      //   //   child: Icon(Icons.menu),
      //   // ),
      //   title: SvgPicture.asset(
      //     "assets/svg/logowhite.svg",
      //     height: 20,
      //   ),
      //   actions: <Widget>[
      //     new Padding(
      //       padding: const EdgeInsets.all(10.0),
      //       child: new Container(
      //         height: 150.0,
      //         width: 30.0,
      //         child: new IconButton(
      //           icon: new Icon(
      //             Icons.notifications_active_outlined,
      //             color: kWhiteColor,
      //           ),
      //           onPressed: null,
      //         ),
      //       ),
      //     ),
      //   ],
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(120),
      //     child: Column(
      //       children: [
      //         GestureDetector(
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => BottomNavigation(
      //                   index: 1,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Padding(
      //             padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      //             child: Container(
      //               padding: EdgeInsets.all(15),
      //               decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(15),
      //                 color: Colors.white,
      //               ),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Text(
      //                     'Search for hotels and dishes',
      //                     style: kTextgrey,
      //                   ),
      //                   Icon(
      //                     Icons.search,
      //                     size: 20,
      //                     color: kGreyLight,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 50),
      //           child: SizedBox(
      //             height: 50,
      //             child: Padding(
      //               padding: const EdgeInsets.symmetric(
      //                   horizontal: 10, vertical: 10),
      //               child: Consumer<GetDataProvider>(
      //                 builder: (context, details, child) => GestureDetector(
      //                   onTap: () {
      //                     Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => MapAddress(),
      //                       ),
      //                     );
      //                   },
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                     children: [
      //                       Icon(
      //                         Icons.location_on,
      //                         color: Colors.white,
      //                       ),
      //                       SizedBox(width: 8,),
      //                       Expanded(
      //                         child: Container(
      //                           child: Text(
      //                             details.fullAddress,
      //                             style: TextStyle(
      //                               fontFamily: PrimaryFontName,
      //                               fontWeight: FontWeight.w400,
      //                               color: Colors.white,
      //                               fontSize: 12,
      //                             ),
      //                             maxLines: 1,
      //                             overflow: TextOverflow.ellipsis,
      //                           ),
      //                         ),
      //                       ),
      //                       // SizedBox(width: 20,),
      //                       Icon(
      //                         Icons.arrow_drop_down,color: Colors.white,
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      bottomNavigationBar: cartBottomCard(),
      body: Consumer<StoreProvider>(
        builder: (context, data, child) => NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // SliverAppBar(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //       bottom: Radius.circular(22.0),
                //     ),
                //   ),
                //   automaticallyImplyLeading: false,
                //   actions: <Widget>[
                //     new Padding(
                //       padding: const EdgeInsets.only(
                //           left: 10.0, right: 18.0, bottom: 10.0, top: 10.0),
                //       child: new Container(
                //         height: 150.0,
                //         width: 30.0,
                //         child: new IconButton(
                //           icon: new Icon(
                //             Icons.notifications_active_outlined,
                //             color: kWhiteColor,
                //           ),
                //           onPressed: null,
                //         ),
                //       ),
                //     ),
                //   ],
                //   backgroundColor: kPinkColor,
                //   elevation: 1,
                //   title: SvgPicture.asset(
                //     "assets/svg/logowhite.svg",
                //     height: 20,
                //   ),
                //   centerTitle: true,
                //   pinned: true,
                //   expandedHeight: 180,
                //   floating: false,
                //   flexibleSpace: FlexibleSpaceBar(
                //     background: Column(
                //       children: [
                //         SizedBox(
                //           height: 90,
                //         ),
                //         Column(
                //           children: [
                //             GestureDetector(
                //               onTap: () {
                //                 Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) => BottomNavigation(
                //                       index: 1,
                //                     ),
                //                   ),
                //                 );
                //               },
                //               child: Padding(
                //                 padding:
                //                     const EdgeInsets.fromLTRB(18, 0, 18, 8),
                //                 child: Container(
                //                   padding: EdgeInsets.all(15),
                //                   decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.circular(15),
                //                     color: Colors.white,
                //                   ),
                //                   child: Row(
                //                     mainAxisAlignment:
                //                         MainAxisAlignment.spaceBetween,
                //                     children: [
                //                       Text(
                //                         'Search for hotels and dishes',
                //                         style: kTextgrey,
                //                       ),
                //                       Icon(
                //                         Icons.search,
                //                         size: 20,
                //                         color: kGreyLight,
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding:
                //                   const EdgeInsets.symmetric(horizontal: 50),
                //               child: SizedBox(
                //                 height: 50,
                //                 child: Padding(
                //                   padding: const EdgeInsets.symmetric(
                //                       horizontal: 10, vertical: 10),
                //                   child: Consumer<GetDataProvider>(
                //                     builder: (context, details, child) =>
                //                         GestureDetector(
                //                       onTap: () {
                //                         Navigator.push(
                //                           context,
                //                           MaterialPageRoute(
                //                             builder: (context) => SavedPage(),
                //                           ),
                //                         );
                //                       },
                //                       child: Row(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.spaceEvenly,
                //                         children: [
                //                           Icon(
                //                             Icons.location_on,
                //                             color: Colors.white,
                //                           ),
                //                           SizedBox(
                //                             width: 8,
                //                           ),
                //                           Expanded(
                //                             child: Container(
                //                               child: Text(
                //                                 details.fullAddress,
                //                                 style: TextStyle(
                //                                   fontFamily: PrimaryFontName,
                //                                   fontWeight: FontWeight.w400,
                //                                   color: Colors.white,
                //                                   fontSize: 12,
                //                                 ),
                //                                 maxLines: 1,
                //                                 overflow: TextOverflow.ellipsis,
                //                               ),
                //                             ),
                //                           ),
                //                           // SizedBox(width: 20,),
                //                           Icon(
                //                             Icons.arrow_drop_down,
                //                             color: Colors.white,
                //                           )
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ];
            },
            body: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: () => _refreshStores(),
              child: data.isServicable
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          QuickScreen(),
                          SizedBox(
                            height: 20,
                          ),
                          MessageCard(data: data.store.branch?.activeMessage),
                          SizedBox(
                            height: 20,
                          ),
                          PopularScreen(),
                          BannerScreen(),
                          SizedBox(
                            height: 18,
                          ),
                          CategoryScreen(),
                          SizedBox(
                            height: 20,
                          ),
                          RecommendedScreen(),
                          SizedBox(
                            height: 14,
                          ),
                          NearbyScreen(),
                        ],
                      ),
                    )
                  : data.errorCode == 100
                      ? zerostate(
                          size: 220,
                          icon: 'assets/svg/noavailable.svg',
                          head: 'Wish We Were Here!',
                          sub: "We don't currently deliver here yet.",
                        )
                      : zerostate(
                          size: 140,
                          icon: 'assets/svg/noservice.svg',
                          head: 'Dang!',
                          sub: "We are currently under maintenance",
                        ),
            )),
      ),
    );
  }
}
