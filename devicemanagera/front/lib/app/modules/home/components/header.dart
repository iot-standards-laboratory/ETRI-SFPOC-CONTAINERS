import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'style/colors.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, ctis) {
      return SizedBox(
        width: ctis.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Farm',
              style: GoogleFonts.sofia(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              width: ctis.maxWidth / 2.6,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding:
                              const EdgeInsets.only(left: 40.0, right: 5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: AppColors.white),
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: AppColors.black),
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                              color: AppColors.secondary, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset:
                              const Offset(7, 7), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: const Color.fromARGB(255, 25, 71, 223),
                        width: 100,
                        height: 52,
                        child: const Center(
                          child: Text(
                            "Container",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
