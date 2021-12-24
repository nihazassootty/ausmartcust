import 'package:flutter/material.dart';
import 'package:ausmart/Commons/TextStyles.dart';
import 'package:ausmart/Commons/zerostate.dart';
import 'package:ausmart/Components/PopularCard.dart';
import 'package:ausmart/Providers/PopularProvider.dart';
import 'package:ausmart/Shimmers/categorydummy.dart';
import 'package:provider/provider.dart';

class PopularScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: "Popular",
              style: TextHeadGrey,
              children: <TextSpan>[
                TextSpan(
                  text: "\tFoods",
                  style: TextHeadGrey,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Consumer<PopularProvider>(
          builder: (context, data, child) => data.loading
              ? categoryShimmer()
              : data.category.count == 0
                  ? zerostate(
                      icon: 'assets/svg/norestaurant.svg',
                      head: 'Sorry!',
                      sub: 'No Restaurant is found')
                  : Container(
                      height: 220,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: data.category.count,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 4,
                                  crossAxisCount: 4),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: popularCard(
                                item: data.category.data[index],
                                context: context,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
