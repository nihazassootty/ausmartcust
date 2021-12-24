import 'package:flutter/material.dart';
import 'package:ausmart/Commons/TextStyles.dart';
import 'package:ausmart/Models/StoreModel.dart';
import 'package:ausmart/Screens/App/HomeInnerScreens/RestaurentDetails.dart';

Widget quickCard(
    {@required Quick item, @required branch, @required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurentDetail(item: item),
          ));
    },
    child: Stack(
      children: [
        Container(
          width: 160,
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
            image: DecorationImage(
              image: NetworkImage(item.storeBg.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              SizedBox(
                height: 220,
                width: 160,
                child: Image.asset(
                  'assets/images/Rectangle1.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: Text16white,
                        ),
                        Text(
                          item.location.address,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: kText12white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // child: Image.network(
          //   item.storeBg.image,
          //   fit: BoxFit.cover,
          // ),
        ),
      ],
    ),
  );
}
